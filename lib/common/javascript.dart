import 'dart:convert';

import 'package:fl_clash/common/exception.dart';
import 'package:flutter/foundation.dart';
import 'package:rust_api/rust_api.dart';

typedef ScriptEvaluator =
    Future<String> Function({required String script, required String config});

@visibleForTesting
ScriptEvaluator scriptEvaluator = evaluateScript;

/// The switches a script declares, read out of the script itself.
typedef ScriptRuleOptions = ({
  Map<String, bool> options,
  Map<String, String> icons,
  List<String> groups,
  String? error,
});

const _probeKey = '__flclashRuleOptions';
const _optionsMarker = 'ruleOptionsEnable';

/// Appends the switches, so `main(config)` finds them before its first read.
/// One the script froze at the top level keeps that value, as in Bettbox.
String scriptWithRuleOptions(String script, Map<String, bool> options) {
  if (options.isEmpty) {
    return script;
  }
  final values = json.encode({
    for (final entry in options.entries) entry.key: entry.value,
  });
  return '$script\n'
      ';(function () {\n'
      '  if (typeof $_optionsMarker !== "undefined" && $_optionsMarker) {\n'
      '    Object.assign($_optionsMarker, $values);\n'
      '  }\n'
      '})();\n';
}

/// Replaces `main` inside a wrapper, so the probe finds it whether the script
/// declared it with `function main` or with `const main = () => {}`.
/// It also runs the script over an empty config, to read each group's icon.
String _ruleOptionsProbe(String script) {
  return '(function () {\n'
      '$script\n'
      ';var __flclashMain = typeof main === "function" ? main : null;\n'
      ';globalThis.main = function () {\n'
      '  var options = typeof $_optionsMarker !== "undefined" && '
      '$_optionsMarker && typeof $_optionsMarker === "object" '
      '? $_optionsMarker : {};\n'
      '  var icons = {};\n'
      '  if (__flclashMain) {\n'
      '    try {\n'
      '      var built = __flclashMain({ "proxies": [], "proxy-groups": [], '
      '"rules": [], "proxy-providers": {}, "rule-providers": {} });\n'
      '      if (built && Array.isArray(built["proxy-groups"])) {\n'
      '        for (var g = 0; g < built["proxy-groups"].length; g++) {\n'
      '          var group = built["proxy-groups"][g];\n'
      '          if (group && typeof group.name === "string" && '
      'typeof group.icon === "string" && !icons[group.name]) {\n'
      '            icons[group.name] = group.icon;\n'
      '          }\n'
      '        }\n'
      '      }\n'
      '    } catch (e) {}\n'
      '  }\n'
      '  if (typeof serviceConfigs !== "undefined" && '
      'Array.isArray(serviceConfigs)) {\n'
      '    for (var i = 0; i < serviceConfigs.length; i++) {\n'
      '      var service = serviceConfigs[i];\n'
      '      if (service && service.name && typeof service.icon === "string" '
      '&& !icons[service.name]) {\n'
      '        icons[service.name] = service.icon;\n'
      '      }\n'
      '    }\n'
      '  }\n'
      '  var groups = [];\n'
      '  if (typeof Compatible_With_Bettbox !== "undefined" && '
      'Compatible_With_Bettbox && '
      'Array.isArray(Compatible_With_Bettbox.policyGroupOptions)) {\n'
      '    var declared = Compatible_With_Bettbox.policyGroupOptions;\n'
      '    for (var j = 0; j < declared.length; j++) {\n'
      '      if (typeof declared[j] === "string") groups.push(declared[j]);\n'
      '    }\n'
      '  }\n'
      '  return { "$_probeKey": '
      '{ "options": options, "icons": icons, "groups": groups } };\n'
      '};\n'
      '})();\n';
}

final _iconField = RegExp(r"""icon\s*:\s*['\"]([^'\"]+)['\"]""");
final _nameField = RegExp(r"""name\s*:\s*['\"]([^'\"]+)['\"]""");
const _iconLookBehind = 320;

/// Icons written in the script, for groups the empty run never reached.
Map<String, String> _writtenIcons(String script) {
  final icons = <String, String>{};
  for (final icon in _iconField.allMatches(script)) {
    final from = icon.start - _iconLookBehind;
    final window = script.substring(from < 0 ? 0 : from, icon.start);
    String? name;
    for (final match in _nameField.allMatches(window)) {
      name = match.group(1);
    }
    if (name == null || name.isEmpty) {
      continue;
    }
    icons.putIfAbsent(name, () => icon.group(1)!);
  }
  return icons;
}

final _ruleOptionsCache = <String, ScriptRuleOptions>{};
const _ruleOptionsCacheSize = 8;

ScriptRuleOptions _parseRuleOptions(String source) {
  final Object? decoded;
  try {
    decoded = json.decode(source);
  } on FormatException {
    return _emptyRuleOptions(error: 'rule options were not a JSON object');
  }
  final payload = decoded is Map ? decoded[_probeKey] : null;
  if (payload is! Map) {
    return _emptyRuleOptions(error: 'rule options were not a JSON object');
  }
  final rawOptions = payload['options'];
  final rawIcons = payload['icons'];
  final rawGroups = payload['groups'];
  return (
    options: {
      if (rawOptions is Map)
        for (final entry in rawOptions.entries)
          entry.key.toString(): entry.value is bool
              ? entry.value as bool
              : true,
    },
    icons: {
      if (rawIcons is Map)
        for (final entry in rawIcons.entries)
          if (entry.value is String && (entry.value as String).isNotEmpty)
            entry.key.toString(): entry.value as String,
    },
    groups: [
      if (rawGroups is List)
        for (final item in rawGroups)
          if (item is String && item.isNotEmpty) item,
    ],
    error: null,
  );
}

ScriptRuleOptions _emptyRuleOptions({String? error}) {
  return (options: const {}, icons: const {}, groups: const [], error: error);
}

/// Runs the script once with a stub config to list what it declares.
Future<ScriptRuleOptions> extractRuleOptions(String script) async {
  final cached = _ruleOptionsCache[script];
  if (cached != null) {
    return cached;
  }
  final String source;
  try {
    source = await scriptEvaluator(
      script: _ruleOptionsProbe(script),
      config: '{}',
    );
  } catch (error) {
    return _emptyRuleOptions(error: '$error');
  }
  final parsed = _parseRuleOptions(source);
  if (parsed.error != null) {
    return parsed;
  }
  final declared = (
    options: parsed.options,
    icons: {..._writtenIcons(script), ...parsed.icons},
    groups: parsed.groups,
    error: parsed.error,
  );
  if (_ruleOptionsCache.length >= _ruleOptionsCacheSize) {
    _ruleOptionsCache.remove(_ruleOptionsCache.keys.first);
  }
  return _ruleOptionsCache[script] = declared;
}

Future<Map<String, dynamic>> handleEvaluate(
  String scriptContent,
  Map<String, dynamic> config, {
  Map<String, bool> customOptions = const {},
}) async {
  if (config['proxy-providers'] == null) {
    config['proxy-providers'] = {};
  }
  final String result;
  try {
    result = await scriptEvaluator(
      script: scriptWithRuleOptions(scriptContent, customOptions),
      config: json.encode(config),
    );
  } catch (e) {
    throw MessageException(e.toString());
  }
  final decoded = json.decode(result);
  if (decoded is! Map<String, dynamic>) {
    throw const MessageException(
      'script did not return a configuration object',
    );
  }
  return decoded;
}
