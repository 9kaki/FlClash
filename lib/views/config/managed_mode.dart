import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/managed_script.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/config/managed_options.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The managed script a merge runs, in the page every entry opens.
class ManagedModeView extends ConsumerStatefulWidget {
  const ManagedModeView({super.key});

  @override
  ConsumerState<ManagedModeView> createState() => _ManagedModeViewState();
}

class _ManagedModeViewState extends ConsumerState<ManagedModeView> {
  ManagedScriptState? _state;
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final state = await ManagedScript.state();
    if (!mounted) {
      return;
    }
    setState(() {
      _state = state;
      _isLoading = false;
    });
  }

  /// A change here reaches every reader of the script's switches.
  void _regenerate() {
    ref.invalidate(managedOptionsProvider);
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
          subtitle: switch (state.version) {
            final version? => Text(
              appLocalizations.managedScriptVersion(version),
            ),
            null => null,
          },
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

  Widget _buildOptions() {
    final appLocalizations = context.appLocalizations;
    final options = ref.watch(managedOptionsProvider).value?.values;
    if (options == null || options.isEmpty) {
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
                  _buildOptions(),
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
  const ManagedScriptSection({super.key, this.profileId});

  /// The config this section edits, whose own switches the row opens.
  final int? profileId;

  @override
  ConsumerState<ManagedScriptSection> createState() =>
      _ManagedScriptSectionState();
}

class _ManagedScriptSectionState extends ConsumerState<ManagedScriptSection> {
  ManagedScriptState? _state;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final state = await ManagedScript.state();
    if (!mounted) {
      return;
    }
    setState(() => _state = state);
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
          ref.invalidate(managedOptionsProvider);
          unawaited(_load());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final switches = ref.watch(ruleSwitchesProvider(widget.profileId)).value;
    return generateSection(
      title: appLocalizations.managedMode,
      footer: appLocalizations.managedModeDesc,
      items: [
        _buildRow(),
        if (switches != null && switches.values.isNotEmpty)
          ListItem(
            leading: const GlyphIcon(AppGlyphs.toggleOn),
            title: Text(appLocalizations.ruleOptions),
            subtitle: Text(
              appLocalizations.managedScriptOptionsCount(
                switches.values.length,
              ),
            ),
            onTap: () =>
                showManagedOptions(context, profileId: widget.profileId),
          ),
      ],
    );
  }
}
