import 'dart:convert';

import 'package:fl_clash/common/string.dart';
import 'package:fl_clash/models/models.dart';

/// One subscription's parsed config, and the label its proxies carry.
typedef MergeMember = ({
  String prefix,
  String label,
  Map<String, dynamic> config,
});

typedef MergeResult = ({
  Map<String, dynamic> config,
  BundleReport report,
  int conflicts,
});

const _reservedProxyNames = {
  'DIRECT',
  'REJECT',
  'REJECT-DROP',
  'PASS',
  'COMPATIBLE',
  'GLOBAL',
};

/// Keys the merge builds itself; everything else comes from the first member.
const _rebuiltKeys = {
  'proxies',
  'proxy-groups',
  'proxy-providers',
  'rule-providers',
  'rules',
  'rule',
  'dns',
  'hosts',
};

final _nameBlank = RegExp(r'[\r\n\t]+');
final _ruleModifiers = {'no-resolve', 'src'};

/// Merges several subscriptions into one config: proxies keep their order and
/// gain their member's prefix, groups of the same name join, and rules follow
/// member order with the references they name rewritten.
MergeResult mergeBundleConfigs(List<MergeMember> members) {
  if (members.isEmpty) {
    throw ArgumentError('no members to merge');
  }
  final usedNames = <String>{};
  for (final member in members) {
    for (final group in _maps(member.config['proxy-groups'])) {
      final name = _string(group['name']);
      if (name.isNotEmpty) {
        usedNames.add(name);
      }
    }
  }
  final fingerprints = <String, String>{};
  final proxies = <Object?>[];
  final groups = <String, Map<String, dynamic>>{};
  final groupOrders = <List<String>>[];
  final proxyProviders = <String, Object?>{};
  final ruleProviders = <String, Object?>{};
  final hosts = <String, Object?>{};
  final rules = <String>[];
  final ruleSet = <String>{};
  final fakeIpFilter = <Object?>[];
  final fakeIPSeen = <String>{};
  final serverNamePolicy = <String, Object?>{};
  final policyConflicts = <String>{};
  var dnsSource = <String, dynamic>{};
  var conflicts = 0;
  var duplicates = 0;
  var proxyCount = 0;

  for (final member in members) {
    final (renamedProxies, rename, kept) = _mergeProxies(
      member,
      usedNames,
      fingerprints,
    );
    duplicates += renamedProxies;
    proxyCount += kept.length;
    proxies.addAll(kept);

    final proxyProviderNames = _mergeProviders(
      member.config['proxy-providers'],
      member.label,
      proxyProviders,
    );
    final ruleProviderNames = _mergeProviders(
      member.config['rule-providers'],
      member.label,
      ruleProviders,
    );

    final order = <String>[];
    final ordered = <String>{};
    for (final group in _maps(member.config['proxy-groups'])) {
      final name = _string(group['name']);
      if (name.isEmpty) {
        continue;
      }
      if (ordered.add(name)) {
        order.add(name);
      }
      final references = _remapReferences(
        group['proxies'],
        rename,
        proxyProviderNames,
      );
      final use = _remapUse(group['use'], proxyProviderNames);
      final existing = groups[name];
      if (existing == null) {
        final copied = _copy(group);
        if (group.containsKey('proxies')) {
          copied['proxies'] = references;
        }
        if (use != null) {
          copied['use'] = use;
        }
        groups[name] = copied;
        continue;
      }
      if (references.isNotEmpty) {
        existing['proxies'] = _unionReferences(existing['proxies'], references);
      }
      if (use != null && use.isNotEmpty) {
        existing['use'] = _unionReferences(existing['use'], use);
      }
    }
    groupOrders.add(order);

    for (final rule in _strings(
      member.config['rules'] ?? member.config['rule'],
    )) {
      final merged = _remapRule(rule, rename, ruleProviderNames);
      if (ruleSet.add(merged)) {
        rules.add(merged);
      }
    }

    final memberDns = _map(member.config['dns']);
    if (memberDns != null) {
      if (dnsSource.isEmpty) {
        dnsSource = _copy(memberDns);
      }
      for (final pattern in _list(memberDns['fake-ip-filter'])) {
        if (fakeIPSeen.add('$pattern')) {
          fakeIpFilter.add(pattern);
        }
      }
      final policy = _map(memberDns['proxy-server-nameserver-policy']);
      for (final entry
          in policy?.entries ?? const <MapEntry<String, Object?>>[]) {
        final existing = serverNamePolicy[entry.key];
        if (existing == null) {
          serverNamePolicy[entry.key] = entry.value;
          continue;
        }
        if (_canonical(existing) != _canonical(entry.value)) {
          conflicts++;
          policyConflicts.add(entry.key);
        }
      }
    }

    for (final entry
        in _map(member.config['hosts'])?.entries ??
            const <MapEntry<String, Object?>>[]) {
      final existing = hosts[entry.key];
      if (existing == null) {
        hosts[entry.key] = entry.value;
        continue;
      }
      if (_canonical(existing) != _canonical(entry.value)) {
        conflicts++;
      }
    }
  }

  final merged = <String, dynamic>{};
  for (final entry in members.first.config.entries) {
    if (!_rebuiltKeys.contains(entry.key)) {
      merged[entry.key] = entry.value;
    }
  }
  merged['proxies'] = proxies;
  final order = _restoreGroupOrder(groupOrders);
  if (order.isNotEmpty) {
    merged['proxy-groups'] = [for (final name in order) groups[name]];
  }
  if (proxyProviders.isNotEmpty) {
    merged['proxy-providers'] = proxyProviders;
  }
  if (ruleProviders.isNotEmpty) {
    merged['rule-providers'] = ruleProviders;
  }
  if (rules.isNotEmpty) {
    merged['rules'] = rules;
  }
  if (dnsSource.isNotEmpty) {
    final dns = dnsSource;
    if (serverNamePolicy.isNotEmpty) {
      dns['proxy-server-nameserver-policy'] = serverNamePolicy;
    } else {
      dns.remove('proxy-server-nameserver-policy');
    }
    if (fakeIpFilter.isNotEmpty) {
      dns['fake-ip-filter'] = fakeIpFilter;
    }
    merged['dns'] = dns;
  }
  if (hosts.isNotEmpty) {
    merged['hosts'] = hosts;
  }
  return (
    config: merged,
    report: BundleReport(
      proxies: proxyCount,
      duplicates: duplicates,
      groups: order.length,
    ),
    conflicts: conflicts,
  );
}

/// Returns the duplicates skipped, the old to new proxy names, and the proxies
/// this member keeps under their new names.
(int, Map<String, String>, List<Map<String, dynamic>>) _mergeProxies(
  MergeMember member,
  Set<String> usedNames,
  Map<String, String> fingerprints,
) {
  final rename = <String, String>{};
  final kept = <Map<String, dynamic>>[];
  var duplicates = 0;
  for (final proxy in _maps(member.config['proxies'])) {
    final original = _string(proxy['name']).trim();
    final fingerprint = _fingerprint(proxy);
    final existing = fingerprints[fingerprint];
    if (existing != null) {
      if (!_isGeneratedProxy(proxy)) {
        duplicates++;
      }
      if (original.isNotEmpty) {
        rename[original] = existing;
      }
      continue;
    }
    final name = _allocateName(
      _sanitizeName(_prefixName(proxy, original, member.prefix)),
      usedNames,
    );
    fingerprints[fingerprint] = name;
    if (original.isNotEmpty) {
      rename[original] = name;
    }
    final copied = _copy(proxy)..['name'] = name;
    kept.add(copied);
  }
  for (final proxy in kept) {
    final dialer = proxy['dialer-proxy'];
    if (dialer is String && rename[dialer] != null) {
      proxy['dialer-proxy'] = rename[dialer];
    }
  }
  return (duplicates, rename, kept);
}

/// Adds a member's providers under names no earlier member took, and returns
/// the renames its groups and rules must follow.
Map<String, String> _mergeProviders(
  Object? source,
  String label,
  Map<String, Object?> into,
) {
  final renames = <String, String>{};
  final providers = _map(source);
  if (providers == null) {
    return renames;
  }
  for (final entry in providers.entries) {
    final existing = into[entry.key];
    if (existing == null) {
      into[entry.key] = entry.value;
      continue;
    }
    if (_canonical(existing) == _canonical(entry.value)) {
      continue;
    }
    var index = 2;
    var name = '${entry.key}-$index';
    while (into.containsKey(name)) {
      index++;
      name = '${entry.key}-$index';
    }
    into[name] = entry.value;
    renames[entry.key] = name;
  }
  return renames;
}

List<String> _restoreGroupOrder(List<List<String>> orders) {
  final nonEmpty = [
    for (final order in orders)
      if (order.isNotEmpty) order,
  ];
  if (nonEmpty.isEmpty) {
    return const [];
  }
  nonEmpty.sort((a, b) => b.length.compareTo(a.length));
  final result = [...nonEmpty.first];
  final placed = result.toSet();
  int position(String name) => result.indexOf(name);
  for (final order in nonEmpty.skip(1)) {
    for (var i = 0; i < order.length; i++) {
      final name = order[i];
      if (!placed.add(name)) {
        continue;
      }
      var insertAt = -1;
      for (var j = i - 1; j >= 0 && insertAt == -1; j--) {
        final index = position(order[j]);
        if (index != -1) {
          insertAt = index + 1;
        }
      }
      for (var j = i + 1; j < order.length && insertAt == -1; j++) {
        final index = position(order[j]);
        if (index != -1) {
          insertAt = index;
        }
      }
      result.insert(insertAt == -1 ? result.length : insertAt, name);
    }
  }
  return result;
}

String _prefixName(Map<String, dynamic> proxy, String original, String prefix) {
  final text = prefix.trim();
  if (text.isEmpty || original.isEmpty || _isGeneratedProxy(proxy)) {
    return original;
  }
  return '[ $text ] - $original';
}

String _sanitizeName(String name) =>
    name.replaceAll(_nameBlank, ' ').replaceAll(',', '，').trim();

String _allocateName(String name, Set<String> used) {
  final base = name.isEmpty ? 'Proxy' : name;
  if (!_reservedProxyNames.contains(base.toUpperCase()) && used.add(base)) {
    return base;
  }
  for (var index = 2; ; index++) {
    final candidate = '$base-$index';
    if (used.add(candidate)) {
      return candidate;
    }
  }
}

List<Object?> _remapReferences(
  Object? value,
  Map<String, String> rename,
  Map<String, String> providers,
) {
  final result = <Object?>[];
  for (final item in _list(value)) {
    if (item == null) {
      continue;
    }
    final name = '$item';
    result.add(rename[name] ?? providers[name] ?? name);
  }
  return result;
}

List<String>? _remapUse(Object? value, Map<String, String> providers) {
  if (value == null) {
    return null;
  }
  return [
    for (final item in _list(value))
      if (item != null) providers['$item'] ?? '$item',
  ];
}

String _remapRule(
  String rule,
  Map<String, String> rename,
  Map<String, String> providers,
) {
  if (rename.isEmpty && providers.isEmpty) {
    return rule;
  }
  final parts = rule.split(',');
  for (var index = 1; index < parts.length; index++) {
    final part = parts[index].trim();
    if (part.isEmpty || _ruleModifiers.contains(part.toLowerCase())) {
      continue;
    }
    final renamed = rename[part] ?? providers[part];
    if (renamed != null) {
      parts[index] = parts[index].replaceFirst(part, renamed);
    }
  }
  return parts.join(',');
}

List<Object?> _unionReferences(Object? current, List<Object?> incoming) {
  final result = <Object?>[];
  final seen = <String>{};
  for (final item in [..._list(current), ...incoming]) {
    final name = '$item';
    if (seen.add(name)) {
      result.add(item);
    }
  }
  return result;
}

bool _isGeneratedProxy(Map<String, dynamic> proxy) {
  final type = _string(proxy['type']).toLowerCase();
  return type == 'direct' || type == 'reject' || type == 'rematch';
}

String _fingerprint(Map<String, dynamic> proxy) {
  final content = _copy(proxy)..remove('name');
  return _canonical(content).toMd5();
}

/// JSON with sorted keys, so two maps that hold the same thing hash alike.
String _canonical(Object? value) {
  if (value is Map) {
    final keys = [for (final key in value.keys) '$key']..sort();
    return '{${[for (final key in keys) '${json.encode(key)}:${_canonical(value[key])}'].join(',')}}';
  }
  if (value is Iterable) {
    return '[${[for (final item in value) _canonical(item)].join(',')}]';
  }
  try {
    return json.encode(value);
  } catch (_) {
    return '$value';
  }
}

Map<String, dynamic> _copy(Map<String, dynamic> value) => {
  for (final entry in value.entries) entry.key: entry.value,
};

Map<String, dynamic>? _map(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return {for (final entry in value.entries) '${entry.key}': entry.value};
  }
  return null;
}

List<Object?> _list(Object? value) {
  if (value is List) {
    return value;
  }
  return const [];
}

List<Map<String, dynamic>> _maps(Object? value) {
  return [for (final item in _list(value)) ?_map(item)];
}

List<String> _strings(Object? value) {
  return [
    for (final item in _list(value))
      if (item is String && item.isNotEmpty) item,
  ];
}

String _string(Object? value) => value is String ? value : '';

/// The leading run of a subscription's label, which its proxies are marked
/// with: one or two Han characters, or the whole alphanumeric run before them.
String bundlePrefixOf(String label) {
  final text = label.trim();
  final start = _prefixStart.firstMatch(text);
  if (start == null) {
    return text;
  }
  return _prefixPattern.firstMatch(text.substring(start.start))?.group(0) ??
      text;
}

final _prefixStart = RegExp(r'[\p{L}\p{N}]', unicode: true);
final _prefixPattern = RegExp(
  r'^(?:\p{Script=Han}{1,2}|(?:(?!\p{Script=Han})[\p{L}\p{N}])+)',
  unicode: true,
);
