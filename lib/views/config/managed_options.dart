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

/// Every entry that edits the hosted script's switches opens this page.
Future<void> showManagedOptions(BuildContext context) {
  return showExtend<void>(context, builder: (_) => const ManagedOptionsView());
}

/// What the hosted script lets a merge switch: the policy groups it can build,
/// then the settings that shape them.
class ManagedOptionsView extends ConsumerStatefulWidget {
  const ManagedOptionsView({super.key});

  @override
  ConsumerState<ManagedOptionsView> createState() => _ManagedOptionsViewState();
}

class _ManagedOptionsViewState extends ConsumerState<ManagedOptionsView> {
  Map<String, bool> _values = {};
  Map<String, bool> _saved = {};
  List<String> _groups = const [];
  Map<String, String> _icons = const {};
  var _isLoading = true;
  var _isSaving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final ManagedOptions options;
    try {
      options = await ref.read(managedOptionsProvider.future);
    } catch (error) {
      commonPrint.log('managed switches could not load: $error');
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _values = Map.of(options.values);
      _saved = Map.of(options.values);
      _groups = options.groups;
      _icons = options.icons;
      _isLoading = false;
    });
    unawaited(precacheTargetIcons(_icons.values.where(_isRemote)));
  }

  bool get _hasChanges => !mapEquals(_values, _saved);

  Future<void> _handleSave() async {
    if (_isSaving || !_hasChanges) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ManagedScript.setOptions(Map.of(_values));
      _saved = Map.of(_values);
      ref.invalidate(managedOptionsProvider);
      ref.read(bundlesActionProvider.notifier).generateAll();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildIcon(String name) {
    final src = _icons[name];
    final fallback = GroupMonogram(name);
    if (src == null || !_isRemote(src)) {
      return fallback;
    }
    return CommonTargetIcon(src: src, fallback: fallback);
  }

  Widget _buildGroup(String name) {
    return ListItem.toggle(
      leading: SizedBox.square(
        dimension: 24,
        child: Center(child: _buildIcon(name)),
      ),
      title: Text(name),
      value: _values[name] ?? false,
      onChanged: (value) => setState(() => _values[name] = value),
    );
  }

  Widget _buildOther(String name) {
    return ListItem.toggle(
      title: Text(name),
      value: _values[name] ?? false,
      onChanged: (value) => setState(() => _values[name] = value),
    );
  }

  Widget _buildContent() {
    final appLocalizations = context.appLocalizations;
    final declared = {for (final name in _groups) name};
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
            items: [for (final name in groupNames) _buildGroup(name)],
          ),
        if (otherNames.isNotEmpty)
          generateSection(
            title: appLocalizations.ruleOptionsOthers,
            items: [for (final name in otherNames) _buildOther(name)],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
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
        isEmpty: _values.isEmpty,
        nullStatus: NullStatus(
          label: appLocalizations.ruleOptionsEmpty,
          description: appLocalizations.ruleOptionsEmptyDesc,
          illustration: NullStatusIllustration.scripts,
        ),
        child: _values.isEmpty ? const SizedBox.shrink() : _buildContent(),
      ),
    );
  }
}
