import 'dart:async';
import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/config/scripts.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

Future<void> showRuleOptionsSheet(BuildContext context) {
  return showSheet<void>(
    context: context,
    builder: (_) => const RuleOptionsSheet(),
  );
}

/// The switches the current profile's script declares, under the names the
/// script itself reads. They are stored on the script, so every profile that
/// extends it shares them.
class RuleOptionsSheet extends ConsumerStatefulWidget {
  const RuleOptionsSheet({super.key});

  @override
  ConsumerState<RuleOptionsSheet> createState() => _RuleOptionsSheetState();
}

class _RuleOptionsSheetState extends ConsumerState<RuleOptionsSheet> {
  Script? _script;
  String? _content;
  ScriptRuleOptions? _declared;
  int? _profileId;

  /// What the sheet shows, and what the script last accepted.
  Map<String, bool> _values = {};
  Map<String, bool> _saved = {};

  String? _loadFailure;
  bool _hasScript = false;
  bool _isLoading = true;
  bool _isApplying = false;

  /// Saves run one at a time and in order, so a burst of switches cannot have
  /// an earlier value win over a later one on its way to the database.
  Future<void> _saves = Future.value();

  /// Held here because a save started before the sheet closed still has to
  /// reach the database, and `ref` is gone by then.
  late final ScriptsAction _scriptsAction;

  @override
  void initState() {
    super.initState();
    _scriptsAction = ref.read(scriptsActionProvider.notifier);
    unawaited(_load());
  }

  Future<void> _load() async {
    final profile = ref.read(currentProfileProvider);
    final usesScript =
        profile != null &&
        profile.type != ProfileType.custom &&
        profile.extendType == ExtendType.script &&
        profile.scriptId != null;
    if (!usesScript) {
      setState(() {
        _hasScript = false;
        _isLoading = false;
      });
      return;
    }
    _profileId = profile.id;
    final script = (ref.read(scriptsProvider).value ?? const <Script>[]).get(
      profile.scriptId,
    );
    final content = await script?.content;
    if (!mounted) {
      return;
    }
    if (script == null || content == null || content.trim().isEmpty) {
      setState(() {
        _hasScript = true;
        _isLoading = false;
      });
      return;
    }
    final declared = await extractRuleOptions(content);
    if (!mounted) {
      return;
    }
    setState(() {
      _hasScript = true;
      _script = script;
      _content = content;
      _declared = declared;
      _values = {
        for (final entry in declared.options.entries)
          entry.key: script.customOptions[entry.key] ?? entry.value,
      };
      _saved = Map<String, bool>.of(_values);
      _loadFailure = declared.error;
      _isLoading = false;
    });
    unawaited(
      precacheTargetIcons(
        declared.icons.values.where(
          (src) => src.startsWith('http://') || src.startsWith('https://'),
        ),
      ),
    );
  }

  void _handleChanged(String name, bool value) {
    setState(() => _values[name] = value);
    // A save that throws must not leave the queue waiting on a dead future.
    _saves = _saves.then((_) => _save()).catchError((Object error) {
      commonPrint.log('rule options were not stored: $error');
    });
  }

  /// Proves the switches against the profile on disk before they are stored, so
  /// a script that rejects them never leaves the Core without a config.
  Future<String?> _validate(Map<String, bool> options) async {
    final content = _content;
    final profileId = _profileId;
    if (content == null || profileId == null) {
      return null;
    }
    final Map<String, dynamic> config;
    try {
      final path = await appPath.getProfilePath(profileId.toString());
      final source = await readTextFileTask(path);
      final decoded = source == null ? null : loadPlainYaml(source);
      if (decoded is! Map) {
        return null;
      }
      config = Map<String, dynamic>.from(decoded);
    } catch (_) {
      // An unreadable profile tells us nothing about the switches; the build
      // that follows reports it instead.
      return null;
    }
    if (config['rules'] == null && config['rule'] != null) {
      config['rules'] = config['rule'];
      config.remove('rule');
    }
    try {
      await handleEvaluate(content, config, customOptions: options);
      return null;
    } catch (error) {
      return '$error';
    }
  }

  Future<void> _save() async {
    final script = _script;
    if (script == null) {
      return;
    }
    final next = Map<String, bool>.of(_values);
    if (mapEquals(next, _saved)) {
      return;
    }
    if (mounted) {
      setState(() => _isApplying = true);
    }
    try {
      final failure = await _validate(next);
      if (failure != null) {
        if (!mounted) {
          return;
        }
        setState(() => _values = Map<String, bool>.of(_saved));
        unawaited(
          dialogs.showMessage(
            message: TextSpan(
              text:
                  '${context.appLocalizations.ruleOptionsRejected}\n\n'
                  '$failure',
            ),
            cancelable: false,
          ),
        );
        return;
      }
      final updated = script.copyWith(customOptions: next);
      _scriptsAction.putScript(updated);
      if (mounted) {
        setState(() {
          _script = updated;
          _saved = next;
        });
      } else {
        _script = updated;
        _saved = next;
      }
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }

  Widget _buildIcon(String name, {required bool isGroup}) {
    final src = _declared?.icons[name];
    final fallback = _buildFallbackIcon(name, isGroup: isGroup);
    if (src == null ||
        !(src.startsWith('http://') ||
            src.startsWith('https://') ||
            src.startsWith('data:'))) {
      return fallback;
    }
    return CommonTargetIcon(src: src, fallback: fallback);
  }

  Widget _buildFallbackIcon(String name, {required bool isGroup}) {
    if (isGroup) {
      return GroupMonogram(name);
    }
    return GlyphIcon(
      AppGlyphs.sliders,
      size: 20,
      color: context.colorScheme.onSurfaceVariant,
    );
  }

  Widget _buildRow(String name, {required bool isGroup, required int index}) {
    return _RuleOptionEntry(
      index: index,
      child: ListItem.toggle(
        leading: SizedBox.square(
          dimension: 24,
          child: Center(child: _buildIcon(name, isGroup: isGroup)),
        ),
        title: Text(name),
        value: _values[name] ?? false,
        onChanged: (value) => _handleChanged(name, value),
      ),
    );
  }

  Widget _buildContent() {
    final appLocalizations = context.appLocalizations;
    final script = _script;
    final declared = _declared;
    if (script == null || declared == null) {
      return NullStatus(
        illustration: NullStatusIllustration.scripts,
        label: _hasScript
            ? appLocalizations.ruleOptionsEmpty
            : appLocalizations.ruleOptionsNoScript,
        description: _hasScript
            ? appLocalizations.ruleOptionsEmptyDesc
            : appLocalizations.ruleOptionsNoScriptDesc,
        action: _hasScript
            ? null
            : FilledButton.tonal(
                onPressed: () {
                  showInSheet<void>(
                    context,
                    builder: (_) => const ScriptsView(),
                  );
                },
                child: Text(appLocalizations.goToConfigureScript),
              ),
      );
    }
    if (declared.options.isEmpty) {
      return NullStatus(
        illustration: NullStatusIllustration.scripts,
        label: _loadFailure == null
            ? appLocalizations.ruleOptionsEmpty
            : appLocalizations.ruleOptionsFailed,
        description: _loadFailure ?? appLocalizations.ruleOptionsEmptyDesc,
      );
    }
    final groups = {
      for (final name in declared.groups)
        if (declared.options.containsKey(name)) name,
    };
    final groupNames = [
      for (final name in declared.options.keys)
        if (groups.contains(name)) name,
    ];
    final otherNames = [
      for (final name in declared.options.keys)
        if (!groups.contains(name)) name,
    ];
    var index = 0;
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ).copyWith(top: context.contentTopPadding, bottom: 32),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            appLocalizations.ruleOptionsFromScript(script.label),
            style: context.listCaptionStyle,
          ),
        ),
        if (groupNames.isNotEmpty)
          generateSection(
            title: appLocalizations.ruleOptionsGroups,
            items: [
              for (final name in groupNames)
                _buildRow(name, isGroup: true, index: index++),
            ],
          ),
        if (otherNames.isNotEmpty)
          generateSection(
            title: appLocalizations.ruleOptionsOthers,
            items: [
              for (final name in otherNames)
                _buildRow(name, isGroup: false, index: index++),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: context.appLocalizations.ruleOptions,
      isLoading: _isApplying,
      body: NullStatusSwitcher(
        isLoading: _isLoading,
        isEmpty: false,
        child: _buildContent(),
      ),
    );
  }
}

/// Rows arrive one after another, so a long list reads as a list rather than
/// appearing all at once with the sheet.
class _RuleOptionEntry extends StatelessWidget {
  static const _duration = Duration(milliseconds: 420);
  static const _step = 0.045;
  static const _run = 0.5;

  final int index;
  final Widget child;

  const _RuleOptionEntry({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    final start = math.min(index * _step, 0.4);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: context.motionDuration(_duration),
      curve: Interval(
        start,
        math.min(start + _run, 1),
        curve: Curves.easeOutCubic,
      ),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 10),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
