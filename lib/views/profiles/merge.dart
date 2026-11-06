import 'dart:async';

import 'package:fl_clash/common/bundle_merge.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/config/managed_mode.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const maxBundleMembers = 8;

/// Creates a bundle, or edits the members, name and collapse of one that
/// exists.
class MergeProfileView extends ConsumerStatefulWidget {
  const MergeProfileView({super.key, this.profileId});

  final int? profileId;

  @override
  ConsumerState<MergeProfileView> createState() => _MergeProfileViewState();
}

class _MergeProfileViewState extends ConsumerState<MergeProfileView> {
  late final TextEditingController _labelController;
  final _members = <BundleMember>[];
  var _collapsed = true;
  var _saving = false;

  bool get _isNew => widget.profileId == null;

  Profile? get _profile =>
      ref.read(profilesProvider).getProfile(widget.profileId);

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profilesProvider).getProfile(widget.profileId);
    _labelController = TextEditingController(text: profile?.label ?? '');
    _members.addAll(profile?.bundleMembers ?? const <BundleMember>[]);
    _collapsed = profile?.bundle?.collapsed ?? true;
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  String _defaultLabel() {
    final labels = {
      for (final profile in ref.read(profilesProvider)) profile.label,
    };
    final appLocalizations = context.appLocalizations;
    var index = 1;
    while (labels.contains(appLocalizations.mergedSubscriptionLabel(index))) {
      index++;
    }
    return appLocalizations.mergedSubscriptionLabel(index);
  }

  bool _reachedLimit() {
    if (_members.length < maxBundleMembers) {
      return false;
    }
    dialogs.showBanner(
      context.appLocalizations.mergeMemberLimit(maxBundleMembers),
      level: BannerLevel.warning,
    );
    return true;
  }

  Future<void> _handleAddUrl() async {
    if (_reachedLimit()) {
      return;
    }
    final appLocalizations = context.appLocalizations;
    final url = await dialogs.showUrlInput(title: appLocalizations.mergeAddUrl);
    if (url == null || !mounted) {
      return;
    }
    final profile = await globalState.loadingRun(
      () => Profile.normal(url: url.trim()).update(
        validate: (path, key) =>
            ref.read(coreHandlerProvider).validateProfile(path, key),
      ),
      tag: LoadingTag.profiles,
      title: appLocalizations.mergeAddUrl,
    );
    if (profile == null || !mounted) {
      return;
    }
    ref.read(profilesActionProvider.notifier).putProfile(profile);
    setState(() => _members.add(BundleMember(id: profile.id)));
  }

  Future<void> _handleEditPrefix(BundleMember member, String label) async {
    final appLocalizations = context.appLocalizations;
    final fallback = bundlePrefixOf(label);
    final value = await dialogs.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.mergeNodePrefix,
        value: member.prefix ?? fallback,
        resetValue: fallback,
        hintText: appLocalizations.mergeNodePrefixNone,
      ),
    );
    if (value == null || !mounted) {
      return;
    }
    final prefix = value.trim();
    final index = _members.indexWhere((item) => item.id == member.id);
    if (index == -1) {
      return;
    }
    setState(() {
      _members[index] = member.copyWith(
        prefix: prefix == fallback || prefix.isEmpty ? null : prefix,
      );
    });
  }

  void _handleSave() {
    if (_saving) {
      return;
    }
    final appLocalizations = context.appLocalizations;
    if (_members.isEmpty) {
      dialogs.showBanner(
        appLocalizations.mergeNoMembers,
        level: BannerLevel.warning,
      );
      return;
    }
    final text = _labelController.text.trim();
    final label = text.isEmpty ? _defaultLabel() : text;
    setState(() => _saving = true);
    unawaited(_save(label, appLocalizations));
  }

  Future<void> _save(String label, AppLocalizations appLocalizations) async {
    try {
      final current = _profile;
      if (current == null) {
        final created = await globalState.loadingRun(
          () => ref
              .read(bundlesActionProvider.notifier)
              .createBundle(
                label: label,
                members: List.of(_members),
                collapsed: _collapsed,
              ),
          tag: LoadingTag.profiles,
          title: appLocalizations.subscriptionMerge,
        );
        if (created != null && mounted) {
          Navigator.of(context).pop();
        }
        return;
      }
      final changed =
          !listEquals(_members, current.bundleMembers) ||
          current.label != label ||
          current.bundle?.collapsed != _collapsed;
      ref
          .read(profilesProvider.notifier)
          .updateProfile(
            current.id,
            (profile) => profile.copyWith(
              label: label,
              bundle: profile.bundle?.copyWith(
                members: List.of(_members),
                collapsed: _collapsed,
              ),
            ),
          );
      if (changed) {
        await globalState.loadingRun(
          () => ref
              .read(bundlesActionProvider.notifier)
              .generateBundle(current.id),
          tag: LoadingTag.profiles,
          title: appLocalizations.subscriptionMerge,
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _handleReorder(int oldIndex, int newIndex) {
    if (oldIndex >= _members.length) {
      return;
    }
    final target = newIndex.clamp(0, _members.length - 1);
    if (oldIndex == target) {
      return;
    }
    setState(() => _members.insert(target, _members.removeAt(oldIndex)));
  }

  String _memberSubtitle(BundleMember member, String prefix, String? failure) {
    final appLocalizations = context.appLocalizations;
    if (failure != null) {
      return appLocalizations.mergeMemberFailed(failure);
    }
    final mark = prefix.isEmpty
        ? appLocalizations.mergeNodePrefixNone
        : appLocalizations.mergeNodePrefixValue(prefix);
    if (member.proxies <= 0) {
      return mark;
    }
    return '$mark · ${appLocalizations.mergeProxiesCount(member.proxies)}';
  }

  Widget _buildMemberRow(int index, List<Profile> profiles) {
    final member = _members[index];
    final label = profiles.getProfile(member.id)?.realLabel ?? '';
    final prefix = member.prefix ?? bundlePrefixOf(label);
    final failure = _profile?.bundle?.failures[member.id];
    final appLocalizations = context.appLocalizations;
    return ReorderDragStartListener(
      key: ValueKey(member.id),
      index: index,
      child: ItemPositionProvider(
        position: ItemPosition.get(index, _members.length + 1),
        child: ListItem(
          leading: const GlyphIcon(AppGlyphs.sort),
          title: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            _memberSubtitle(member, prefix, failure),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: failure == null
                ? null
                : TextStyle(color: context.colorScheme.error),
          ),
          trailing: PopupAnchor(
            targetBuilder: (open) => IconButton(
              onPressed: open,
              icon: const GlyphIcon(AppGlyphs.moreCircle),
              tooltip: appLocalizations.more,
            ),
            popupBuilder: (_) => PopupMenu(
              items: [
                PopupMenuItem(
                  glyph: AppGlyphs.layers,
                  label: appLocalizations.mergeNodePrefix,
                  onPressed: () => _handleEditPrefix(member, label),
                ),
                PopupMenuItem(
                  danger: true,
                  glyph: AppGlyphs.removeCircle,
                  label: appLocalizations.delete,
                  onPressed: () => setState(() => _members.removeAt(index)),
                ),
              ],
            ),
          ),
          onTap: () => _handleEditPrefix(member, label),
        ),
      ),
    );
  }

  Widget _buildMemberHeader() {
    return ListHeader(title: context.appLocalizations.mergeMembers);
  }

  Widget _buildMemberFooter() {
    return ListFooter(text: context.appLocalizations.mergeMembersDesc);
  }

  Widget _buildAddRow() {
    final appLocalizations = context.appLocalizations;
    return ListItem(
      leading: const GlyphIcon(AppGlyphs.link),
      title: Text(appLocalizations.mergeAddUrl),
      subtitle: Text(appLocalizations.mergeAddUrlDesc),
      onTap: _handleAddUrl,
    );
  }

  Widget _buildMemberSliver(List<Profile> profiles) {
    return SliverPrismReorderableList(
      itemCount: _members.length + 1,
      itemBuilder: (context, index) => index == _members.length
          ? KeyedSubtree(
              key: const ValueKey('merge_add_link'),
              child: ItemPositionProvider(
                position: _members.isEmpty
                    ? ItemPosition.startAndEnd
                    : ItemPosition.end,
                child: _buildAddRow(),
              ),
            )
          : _buildMemberRow(index, profiles),
      onReorderItem: _handleReorder,
      proxyDecorator: (child, index, animation) =>
          commonProxyDecorator(child, index, animation),
    );
  }

  Widget _buildCandidateSection(List<Profile> profiles) {
    final taken = {for (final member in _members) member.id};
    final candidates = [
      for (final profile in profiles)
        if (profile.hasOwnConfig &&
            profile.type != ProfileType.custom &&
            !taken.contains(profile.id))
          profile,
    ];
    if (candidates.isEmpty) {
      return const SizedBox.shrink();
    }
    return generateSection(
      title: context.appLocalizations.mergeAddMember,
      items: [
        for (final profile in candidates)
          ListItem(
            leading: const GlyphIcon(AppGlyphs.addCircle),
            title: Text(
              profile.realLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              if (_reachedLimit()) {
                return;
              }
              setState(() => _members.add(BundleMember(id: profile.id)));
            },
          ),
      ],
    );
  }

  Widget _buildIdentitySection() {
    final appLocalizations = context.appLocalizations;
    return generateSection(
      items: [
        FormRow(
          title: appLocalizations.name,
          trailing: FormRowTextField(
            controller: _labelController,
            hintText: _defaultLabel(),
            textInputAction: TextInputAction.done,
            inputFormatters: TextInputLimits.limit(TextInputLimits.name),
            onChanged: (_) => setState(() {}),
          ),
        ),
        ListItem.toggle(
          title: Text(appLocalizations.mergeCollapse),
          subtitle: Text(appLocalizations.mergeCollapseDesc),
          value: _collapsed,
          onChanged: (value) => setState(() => _collapsed = value),
        ),
        ?_buildReportRow(),
      ],
    );
  }

  Widget? _buildReportRow() {
    final appLocalizations = context.appLocalizations;
    final profile = _profile;
    final report = profile?.bundle?.report;
    final generated = profile?.lastUpdateDate;
    if (profile == null || report == null || generated == null) {
      return null;
    }
    return ListItem(
      title: Text(appLocalizations.mergeLastGenerated),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appLocalizations.mergeReport(
              report.proxies,
              report.duplicates,
              profile.bundleMembers.length,
            ),
          ),
          LastUpdateTimeText(lastUpdateDate: generated),
        ],
      ),
      trailing: IconButton(
        onPressed: () => unawaited(
          globalState.loadingRun(
            () => ref
                .read(bundlesActionProvider.notifier)
                .generateBundle(profile.id, refresh: true),
            tag: LoadingTag.profiles,
            title: appLocalizations.sync,
          ),
        ),
        tooltip: appLocalizations.sync,
        icon: const GlyphIcon(AppGlyphs.sync),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final profiles = ref.watch(profilesProvider);
    return Scaffold(
      title: _isNew
          ? appLocalizations.subscriptionMerge
          : appLocalizations.edit,
      confirmationAction: IconButtonData(
        glyph: AppGlyphs.check,
        tooltip: appLocalizations.save,
        isLoading: _saving,
        onPressed: _saving ? null : _handleSave,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
              top: context.sectionsTopPadding,
              bottom: 16 + context.bottomInset,
            ),
            sliver: SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(child: _buildIdentitySection()),
                SliverToBoxAdapter(child: _buildMemberHeader()),
                _buildMemberSliver(profiles),
                SliverToBoxAdapter(child: _buildMemberFooter()),
                SliverToBoxAdapter(child: _buildCandidateSection(profiles)),
                const SliverToBoxAdapter(child: ManagedScriptSection()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
