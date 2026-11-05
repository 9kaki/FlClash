import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/managed_script.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showManagedOptions(BuildContext context) {
  return showExtend<void>(context, builder: (_) => const ManagedOptionsView());
}

/// The managed script a merge runs, in the page every entry opens.
class ManagedModeView extends ConsumerStatefulWidget {
  const ManagedModeView({super.key});

  @override
  ConsumerState<ManagedModeView> createState() => _ManagedModeViewState();
}

class _ManagedModeViewState extends ConsumerState<ManagedModeView> {
  ManagedScriptState? _state;
  ScriptRuleOptions? _declared;
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final state = await ManagedScript.state();
    final content = await ManagedScript.content();
    final declared = content == null ? null : await extractRuleOptions(content);
    if (!mounted) {
      return;
    }
    setState(() {
      _state = state;
      _declared = declared;
      _isLoading = false;
    });
  }

  void _regenerate() {
    ref.read(bundlesActionProvider.notifier).generateAll();
  }

  Future<void> _handleEditSource() async {
    final appLocalizations = context.appLocalizations;
    final url = await dialogs.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.managedScriptSource,
        value: _state?.source ?? '',
        hintText: 'https://',
        labelText: appLocalizations.managedScriptSource,
        resetValue: '',
        inputFormatters: TextInputLimits.limit(TextInputLimits.url),
        validator: (value) {
          final text = value?.trim() ?? '';
          if (text.isEmpty || text.isUrl) {
            return null;
          }
          return appLocalizations.managedScriptSourceInvalid;
        },
      ),
    );
    if (url == null || !mounted) {
      return;
    }
    await ManagedScript.setSource(url);
    if (!mounted) {
      return;
    }
    unawaited(_load());
    _regenerate();
  }

  Future<void> _handleSync() async {
    final appLocalizations = context.appLocalizations;
    if (_state?.source == null) {
      unawaited(_handleEditSource());
      return;
    }
    final version = await globalState.loadingRun(
      ManagedScript.sync,
      tag: LoadingTag.scripts,
      title: appLocalizations.managedScriptSync,
    );
    if (version == null || !mounted) {
      return;
    }
    unawaited(_load());
    _regenerate();
    if (!mounted) {
      return;
    }
    dialogs.showBanner(
      appLocalizations.managedScriptSynced(version),
      level: BannerLevel.success,
    );
  }

  Future<void> _handleEdit() async {
    final appLocalizations = context.appLocalizations;
    final content = await ManagedScript.readContent();
    if (!mounted) {
      return;
    }
    unawaited(
      BaseNavigator.push<void>(
        context,
        EditorPage(
          title: appLocalizations.managedMode,
          language: Language.javaScript,
          load: () async =>
              CodeForgeDocument.fromText(content ?? managedScriptTemplate),
          onSave: (_, _, editorContent) async {
            await ManagedScript.saveContent(await editorContent.readText());
            if (!mounted) {
              return;
            }
            unawaited(_load());
            _regenerate();
          },
        ),
      ),
    );
  }

  Future<void> _handleRestore() async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.managedScriptRestore,
      message: TextSpan(text: appLocalizations.managedScriptRestoreTip),
      destructive: true,
      confirmText: appLocalizations.managedScriptRestore,
    );
    if (res != true || !mounted) {
      return;
    }
    await ManagedScript.restore();
    if (!mounted) {
      return;
    }
    unawaited(_load());
    _regenerate();
  }

  Widget _buildScript(ManagedScriptState state) {
    final appLocalizations = context.appLocalizations;
    final enabled = state.source != null || state.hasContent;
    return generateSection(
      title: appLocalizations.managedScript,
      items: [
        ListItem(
          leading: const GlyphIcon(AppGlyphs.link),
          title: Text(appLocalizations.managedScriptSource),
          subtitle: Text(state.source ?? appLocalizations.managedScriptUnset),
          trailing: const GlyphIcon(AppGlyphs.chevronForward),
          onTap: _handleEditSource,
        ),
        ListItem(
          leading: const GlyphIcon(AppGlyphs.code),
          title: Text(
            state.hasContent
                ? appLocalizations.managedScriptLocal
                : appLocalizations.managedScriptEmpty,
          ),
          subtitle: Text(
            state.version == null
                ? appLocalizations.managedScriptVersionNone
                : appLocalizations.managedScriptVersion(state.version!),
          ),
          trailing: const GlyphIcon(AppGlyphs.chevronForward),
          onTap: _handleEdit,
        ),
        ListItem(
          leading: const GlyphIcon(AppGlyphs.sync),
          title: Text(
            enabled
                ? appLocalizations.managedScriptSync
                : appLocalizations.managedScriptEnable,
          ),
          subtitle: Text(appLocalizations.managedScriptSyncDesc),
          onTap: _handleSync,
        ),
        if (state.hasContent || state.source != null)
          ListItem(
            leading: const GlyphIcon(AppGlyphs.removeCircle),
            title: Text(appLocalizations.managedScriptRestore),
            onTap: _handleRestore,
          ),
      ],
    );
  }

  Widget _buildOptions(ScriptRuleOptions? declared) {
    final appLocalizations = context.appLocalizations;
    final options = declared?.options ?? const <String, bool>{};
    if (options.isEmpty) {
      return const SizedBox.shrink();
    }
    return generateSection(
      title: appLocalizations.managedScriptOptions,
      items: [
        ListItem(
          leading: const GlyphIcon(AppGlyphs.toggleOn),
          title: Text(appLocalizations.ruleOptions),
          subtitle: Text(
            appLocalizations.managedScriptOptionsCount(options.length),
          ),
          trailing: const GlyphIcon(AppGlyphs.chevronForward),
          onTap: () => showManagedOptions(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final state = _state;
    return Scaffold(
      title: appLocalizations.managedMode,
      body: NullStatusSwitcher(
        isLoading: _isLoading,
        isEmpty: state == null,
        nullStatus: NullStatus(
          label: appLocalizations.managedScriptEmpty,
          illustration: NullStatusIllustration.scripts,
        ),
        child: state == null
            ? const SizedBox.shrink()
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
                  top: context.contentTopPadding,
                  bottom: 16 + context.bottomInset,
                ),
                children: [
                  ListFooter(text: appLocalizations.managedModeDesc),
                  _buildScript(state),
                  _buildOptions(_declared),
                  generateSection(
                    items: [
                      ListItem(
                        leading: const GlyphIcon(AppGlyphs.refresh),
                        title: Text(appLocalizations.managedScriptRegenerate),
                        subtitle: Text(
                          appLocalizations.managedScriptRegenerateDesc,
                        ),
                        onTap: _regenerate,
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

/// The merge page's own view of the script, so the two entries agree.
class ManagedScriptSection extends ConsumerStatefulWidget {
  const ManagedScriptSection({super.key});

  @override
  ConsumerState<ManagedScriptSection> createState() =>
      _ManagedScriptSectionState();
}

class _ManagedScriptSectionState extends ConsumerState<ManagedScriptSection> {
  ManagedScriptState? _state;
  ScriptRuleOptions? _declared;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final state = await ManagedScript.state();
    final content = await ManagedScript.content();
    final declared = content == null ? null : await extractRuleOptions(content);
    if (!mounted) {
      return;
    }
    setState(() {
      _state = state;
      _declared = declared;
    });
  }

  Widget _buildRow() {
    final appLocalizations = context.appLocalizations;
    final state = _state;
    final subtitle = state == null
        ? null
        : state.source ?? appLocalizations.managedScriptUnset;
    return ListItem(
      leading: const GlyphIcon(AppGlyphs.code),
      title: Text(appLocalizations.managedMode),
      subtitle: state == null
          ? null
          : Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const GlyphIcon(AppGlyphs.chevronForward),
      onTap: () async {
        await BaseNavigator.push<void>(context, const ManagedModeView());
        if (mounted) {
          unawaited(_load());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = _declared?.options ?? const <String, bool>{};
    return generateSection(
      title: context.appLocalizations.managedMode,
      footer: context.appLocalizations.managedModeDesc,
      items: [
        _buildRow(),
        if (options.isNotEmpty)
          ListItem(
            leading: const GlyphIcon(AppGlyphs.toggleOn),
            title: Text(context.appLocalizations.ruleOptions),
            subtitle: Text(
              context.appLocalizations.managedScriptOptionsCount(
                options.length,
              ),
            ),
            onTap: () => showManagedOptions(context),
          ),
      ],
    );
  }
}

/// The switches the managed script declares, saved where a merge reads them.
class ManagedOptionsView extends ConsumerStatefulWidget {
  const ManagedOptionsView({super.key});

  @override
  ConsumerState<ManagedOptionsView> createState() => _ManagedOptionsViewState();
}

class _ManagedOptionsViewState extends ConsumerState<ManagedOptionsView> {
  Map<String, bool> _values = {};
  Map<String, bool> _saved = {};
  ScriptRuleOptions? _declared;
  var _isLoading = true;
  var _isSaving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final content = await ManagedScript.content();
    final declared = content == null ? null : await extractRuleOptions(content);
    final stored = await ManagedScript.options();
    if (!mounted) {
      return;
    }
    final declaredOptions = declared?.options ?? const <String, bool>{};
    final values = {
      for (final entry in declaredOptions.entries)
        entry.key: stored[entry.key] ?? entry.value,
    };
    setState(() {
      _declared = declared;
      _values = Map.of(values);
      _saved = Map.of(values);
      _isLoading = false;
    });
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

  Widget _buildContent() {
    final appLocalizations = context.appLocalizations;
    final groups = _declared?.groups ?? const <String>[];
    final groupNames = [
      for (final name in _values.keys)
        if (groups.contains(name)) name,
    ];
    final otherNames = [
      for (final name in _values.keys)
        if (!groups.contains(name)) name,
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
                ListItem.toggle(
                  title: Text(name),
                  value: _values[name] ?? false,
                  onChanged: (value) => setState(() => _values[name] = value),
                ),
            ],
          ),
        if (otherNames.isNotEmpty)
          generateSection(
            title: appLocalizations.ruleOptionsOthers,
            items: [
              for (final name in otherNames)
                ListItem.toggle(
                  title: Text(name),
                  value: _values[name] ?? false,
                  onChanged: (value) => setState(() => _values[name] = value),
                ),
            ],
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
