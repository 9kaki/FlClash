import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/managed_script.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

bool _isRemote(String src) =>
    src.startsWith('http://') ||
    src.startsWith('https://') ||
    src.startsWith('data:');

/// Opens the switches of one config: a profile's own when [profileId] names
/// one, the hosted defaults when it does not.
Future<void> showManagedOptions(BuildContext context, {int? profileId}) {
  return showExtend<void>(
    context,
    builder: (_) => ManagedOptionsView(profileId: profileId),
  );
}

/// The switches a config offers, read from that config alone: a merge answers
/// with the hosted defaults, a subscription with what its own file or script
/// declares, so using one subscription never inherits a merge's switches.
class ManagedOptionsView extends ConsumerStatefulWidget {
  const ManagedOptionsView({super.key, this.profileId});

  final int? profileId;

  @override
  ConsumerState<ManagedOptionsView> createState() => _ManagedOptionsViewState();
}

class _ManagedOptionsViewState extends ConsumerState<ManagedOptionsView> {
  RuleSwitchSet? _switches;
  Map<String, bool> _values = {};
  Map<String, bool> _saved = {};
  var _isLoading = true;
  var _isSaving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void didUpdateWidget(ManagedOptionsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profileId == oldWidget.profileId) {
      return;
    }
    setState(() => _isLoading = true);
    unawaited(_load());
  }

  Future<void> _load() async {
    final RuleSwitchSet? switches;
    try {
      switches = await ref.read(ruleSwitchesProvider(widget.profileId).future);
    } catch (error) {
      commonPrint.log('rule switches could not load: $error');
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _switches = switches;
      _values = Map.of(switches?.values ?? const {});
      _saved = Map.of(_values);
      _isLoading = false;
    });
    unawaited(
      precacheTargetIcons(
        (switches?.icons.values ?? const <String>[]).where(_isRemote),
      ),
    );
  }

  bool get _hasChanges => _switches != null && !mapEquals(_values, _saved);

  Future<String?> _validateScript(
    int profileId,
    String content,
    Map<String, bool> options,
  ) async {
    final Map<Object?, Object?> config;
    try {
      final path = await appPath.getProfilePath(profileId.toString());
      final source = await readTextFileTask(path);
      final decoded = source == null ? null : await decodeYamlTask(source);
      if (decoded is! Map) {
        return null;
      }
      config = decoded;
    } catch (_) {
      return null;
    }
    final raw = Map<String, dynamic>.from(config);
    if (raw['rules'] == null && raw['rule'] != null) {
      raw['rules'] = raw['rule'];
      raw.remove('rule');
    }
    try {
      await handleEvaluate(content, raw, customOptions: options);
      return null;
    } catch (error) {
      return '$error';
    }
  }

  Future<void> _applyIfCurrent(int profileId) async {
    if (ref.read(currentProfileIdProvider) != profileId) {
      return;
    }
    await ref.read(setupActionProvider.notifier).applyProfile(silence: true);
  }

  Future<void> _handleSave() async {
    final switches = _switches;
    if (switches == null || _isSaving) {
      return;
    }
    final next = Map<String, bool>.of(_values);
    if (mapEquals(next, _saved)) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      switch (switches) {
        case HostedRuleSwitches():
          await ManagedScript.setOptions(next);
          ref.invalidate(managedOptionsProvider);
          ref.invalidate(ruleSwitchesProvider);
          ref.read(bundlesActionProvider.notifier).generateAll();
        case ScriptRuleSwitches():
          final failure = await _validateScript(
            switches.profileId,
            switches.content,
            next,
          );
          if (failure != null) {
            _handleRejected(failure);
            return;
          }
          ref
              .read(scriptsActionProvider.notifier)
              .putScript(switches.script.copyWith(customOptions: next));
          ref.invalidate(ruleSwitchesProvider);
          await _applyIfCurrent(switches.profileId);
        case GroupRuleSwitches():
          ref
              .read(profilesProvider.notifier)
              .updateProfile(
                switches.profileId,
                (profile) => profile.copyWith(
                  disabledGroups: {
                    for (final entry in next.entries)
                      if (!entry.value) entry.key,
                  },
                ),
              );
          ref.invalidate(ruleSwitchesProvider);
          await _applyIfCurrent(switches.profileId);
      }
      _saved = next;
    } catch (error) {
      commonPrint.log('rule switches were not applied: $error');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleRejected(String failure) {
    if (!mounted) {
      return;
    }
    setState(() => _values = Map<String, bool>.of(_saved));
    unawaited(
      dialogs.showAlert(
        message: TextSpan(
          text: '${context.appLocalizations.ruleOptionsRejected}\n\n$failure',
        ),
      ),
    );
  }

  Widget _buildIcon(String name, Map<String, String> icons) {
    final src = icons[name];
    final fallback = GroupMonogram(name);
    if (src == null || !_isRemote(src)) {
      return fallback;
    }
    return CommonTargetIcon(src: src, fallback: fallback);
  }

  Widget _buildSwitch({
    required String name,
    required Map<String, String> icons,
    required bool asGroup,
  }) {
    final locked = _switches?.locked.contains(name) ?? false;
    return ListItem.toggle(
      leading: asGroup
          ? SizedBox.square(
              dimension: 24,
              child: Center(child: _buildIcon(name, icons)),
            )
          : null,
      title: Text(name),
      subtitle: locked
          ? Text(context.appLocalizations.ruleOptionsLockedGroup)
          : null,
      value: _values[name] ?? false,
      onChanged: locked
          ? null
          : (value) => setState(() => _values[name] = value),
    );
  }

  Widget _buildContent(RuleSwitchSet switches) {
    final appLocalizations = context.appLocalizations;
    final declared = {for (final name in switches.groups) name};
    final groupNames = [
      for (final name in _values.keys)
        if (declared.contains(name)) name,
    ];
    final otherNames = [
      for (final name in _values.keys)
        if (!declared.contains(name)) name,
    ];
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
        top: context.contentTopPadding,
        bottom: 16 + context.bottomInset,
      ),
      children: [
        if (groupNames.isNotEmpty)
          generateSection(
            title: appLocalizations.ruleOptionsGroups,
            items: [
              for (final name in groupNames)
                _buildSwitch(name: name, icons: switches.icons, asGroup: true),
            ],
          ),
        if (otherNames.isNotEmpty)
          generateSection(
            title: appLocalizations.ruleOptionsOthers,
            items: [
              for (final name in otherNames)
                _buildSwitch(name: name, icons: switches.icons, asGroup: false),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final switches = _switches;
    return Scaffold(
      title: appLocalizations.ruleOptions,
      confirmationAction: _hasChanges || _isSaving
          ? IconButtonData(
              glyph: AppGlyphs.check,
              tooltip: appLocalizations.save,
              isLoading: _isSaving,
              onPressed: _isSaving ? null : () => unawaited(_handleSave()),
            )
          : null,
      body: NullStatusSwitcher(
        isLoading: _isLoading,
        isEmpty: switches == null,
        nullStatus: NullStatus(
          label: appLocalizations.ruleOptionsEmpty,
          description: appLocalizations.ruleOptionsEmptyDesc,
          illustration: NullStatusIllustration.scripts,
        ),
        child: switches == null
            ? const SizedBox.shrink()
            : _buildContent(switches),
      ),
    );
  }
}

/// The row that opens a profile's own switches, on the page that edits it.
class RuleOptionsItem extends ConsumerWidget {
  const RuleOptionsItem({super.key, required this.profileId});

  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final switches = ref.watch(ruleSwitchesProvider(profileId)).value;
    if (switches == null || switches.values.isEmpty) {
      return const SizedBox.shrink();
    }
    return generateSection(
      items: [
        ListItem(
          leading: const GlyphIcon(AppGlyphs.toggleOn),
          title: Text(appLocalizations.ruleOptions),
          subtitle: Text(
            appLocalizations.managedScriptOptionsCount(switches.values.length),
          ),
          trailing: const GlyphIcon(AppGlyphs.chevronForward),
          onTap: () => showManagedOptions(context, profileId: profileId),
        ),
      ],
    );
  }
}
