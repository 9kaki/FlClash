import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/profiles/custom/custom.dart';
import 'package:fl_clash/views/profiles/extend/extend.dart';
import 'package:fl_clash/views/profiles/merge.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'add.dart';
import 'edit.dart';
import 'preview.dart';

const _infoGap = 4.0;

const _memberGap = 2.0;

double get _profileItemDetailHeight {
  final measure = globalState.measure;
  return measure.textHeight(AppTextStyle.footnote) + _infoGap;
}

double get _profileItemHeight {
  final measure = globalState.measure;
  return measure.textHeight(AppTextStyle.headline) +
      _infoGap +
      measure.textHeight(AppTextStyle.footnote) +
      2 * listRowVerticalPadding;
}

class ProfilesView extends ConsumerStatefulWidget {
  const ProfilesView({super.key, this.picker = false});

  /// Clears the bar and opens at the top, for switching profiles from a sheet.
  final bool picker;

  @override
  ConsumerState<ProfilesView> createState() => _ProfilesViewState();
}

class _ProfilesViewState extends ConsumerState<ProfilesView> {
  bool _isUpdating = false;

  Future<void> _updateProfiles(List<Profile> profiles) async {
    if (_isUpdating == true) {
      return;
    }
    _isUpdating = true;
    final appLocalizations = context.appLocalizations;
    final profilesAction = ref.read(profilesActionProvider.notifier);
    final bundlesAction = ref.read(bundlesActionProvider.notifier);
    final List<UpdatingMessage> messages = [];
    // A member rides on its bundle's sync, which updates it on the way.
    final memberIds = {
      for (final profile in profiles)
        ...?profile.bundle?.members.map((m) => m.id),
    };
    final updateProfiles = profiles.map<Future>((profile) async {
      if (memberIds.contains(profile.id)) return;
      if (!profile.isBundle && profile.type != ProfileType.url) return;
      try {
        if (profile.isBundle) {
          await bundlesAction.generateBundle(profile.id, refresh: true);
        } else {
          await profilesAction.updateProfile(profile, showLoading: true);
        }
      } catch (e) {
        messages.add(
          UpdatingMessage(
            label: profile.realLabel,
            message: userFacingErrorMessage(e, appLocalizations),
          ),
        );
      }
    });
    await Future.wait(updateProfiles);
    dialogs.showFailures(messages);
    _isUpdating = false;
  }

  List<IconButtonData> _buildActions(List<Profile> profiles) {
    return profiles.isNotEmpty
        ? [
            IconButtonData(
              glyph: AppGlyphs.sync,
              onPressed: () {
                _updateProfiles(profiles);
              },
              tooltip: context.appLocalizations.update,
            ),
            IconButtonData(
              glyph: AppGlyphs.sort,
              onPressed: () {
                showSheet(
                  context: context,
                  builder: (_) {
                    return ReorderableProfilesSheet(profiles: profiles);
                  },
                );
              },
              tooltip: context.appLocalizations.profilesSort,
            ),
          ]
        : [];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, _) {
        final appLocalizations = context.appLocalizations;
        final isLoading = ref.watch(loadingProvider(LoadingTag.profiles));
        final state = ref.watch(profilesStateProvider);
        final spacing = cardSpacingOf(context, ref.watch(viewModeProvider));
        final picker = widget.picker;
        return Scaffold(
          isLoading: isLoading,
          title: appLocalizations.profiles,
          iconActions: picker ? const [] : _buildActions(state.profiles),
          actions: state.profiles.isEmpty || picker
              ? null
              : [
                  AddProfileMenu(
                    builder: (open) => IconButton(
                      tooltip: appLocalizations.addProfile,
                      onPressed: open,
                      icon: const GlyphIcon(AppGlyphs.addCircle),
                    ),
                  ),
                ],
          body: NullStatusSwitcher(
            isEmpty: state.profiles.isEmpty,
            nullStatus: NullStatus(
              label: appLocalizations.nullTip(appLocalizations.profiles),
              description: appLocalizations.nullProfileDesc,
              illustration: NullStatusIllustration.profile,
              action: AddProfileMenu(
                builder: (open) => TonalButton(
                  size: TonalButtonSize.bar,
                  glyph: AppGlyphs.addCircle,
                  label: appLocalizations.addProfile,
                  onPressed: open,
                ),
              ),
            ),
            child: _ProfilesGrid(
              profiles: state.profiles,
              currentProfileId: state.currentProfileId,
              spacing: spacing,
              revealsSelected: !picker,
            ),
          ),
        );
      },
    );
  }
}

class _ProfilesGrid extends ConsumerStatefulWidget {
  const _ProfilesGrid({
    required this.profiles,
    required this.currentProfileId,
    required this.spacing,
    required this.revealsSelected,
  });

  final List<Profile> profiles;
  final int? currentProfileId;
  final double spacing;
  final bool revealsSelected;

  @override
  ConsumerState<_ProfilesGrid> createState() => _ProfilesGridState();
}

class _ProfilesGridState extends ConsumerState<_ProfilesGrid> {
  static const _horizontalPadding = 16.0;

  late final ScrollController _controller;
  var _revealed = false;
  int? _expandedBundleId;

  @override
  void initState() {
    super.initState();
    _controller = sheetScrollController(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_revealed ||
        !widget.revealsSelected ||
        !PageActivityScope.isActiveOf(context)) {
      return;
    }
    _revealed = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealSelected());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  EdgeInsets get _padding => EdgeInsets.only(
    left: _horizontalPadding,
    right: _horizontalPadding,
    top: context.contentTopPadding,
    bottom: 16 + context.bottomInset,
  );

  int _columnsFor(double width) => getProfilesColumns(
    width - _horizontalPadding * 2,
    spacing: widget.spacing,
    minItemWidth: profileItemMinWidth.ap(context),
  );

  /// The profiles the grid draws. A collapsed merge stands for its members,
  /// even the one in use, which stays inside the merge's own card.
  List<Profile> get _visibleProfiles {
    final collapsed = widget.profiles.collapsedMemberIds;
    return [
      for (final profile in widget.profiles)
        if (!collapsed.contains(profile.id)) profile,
    ];
  }

  void _revealSelected() {
    if (!mounted || !_controller.hasClients) {
      return;
    }
    var index = _visibleProfiles.indexWhere(
      (profile) => profile.id == widget.currentProfileId,
    );
    // A member in use hides inside its merge's card, so reveal that instead.
    if (index == -1) {
      index = _visibleProfiles.indexWhere(
        (profile) =>
            profile.bundle?.collapsed == true &&
            profile.bundleMembers.any(
              (member) => member.id == widget.currentProfileId,
            ),
      );
    }
    if (index == -1) {
      return;
    }
    final position = _controller.position;
    final padding = _padding;
    final height = _profileItemHeight;
    final row = index ~/ _columnsFor(context.size!.width);
    final atTop = row * (height + widget.spacing);
    final atBottom =
        atTop + padding.vertical + height - position.viewportDimension;
    if (position.pixels >= atBottom && position.pixels <= atTop) {
      return;
    }
    _controller.jumpTo(
      ((atTop + atBottom) / 2).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      ),
    );
  }

  bool _isMergedVisible(Profile profile) => widget.profiles.any(
    (item) =>
        item.bundle?.collapsed == false &&
        item.bundleMembers.any((member) => member.id == profile.id),
  );

  void _toggleExpand(int? id) {
    setState(() => _expandedBundleId = _expandedBundleId == id ? null : id);
  }

  /// One column: the card itself, whose own body grows when a merge opens.
  Widget _buildCell(List<Profile> rowProfiles, int index, double rowHeight) {
    if (index >= rowProfiles.length) {
      return const SizedBox.shrink();
    }
    final profile = rowProfiles[index];
    final expanded = profile.id == _expandedBundleId;
    final panel = profile.isBundle && (profile.bundle?.collapsed ?? false)
        ? BundleMembers(
            key: ValueKey('bundle_members_${profile.id}'),
            profile: profile,
            expanded: expanded,
            currentProfileId: widget.currentProfileId,
            onSelect: (profileId) {
              ref.read(currentProfileIdProvider.notifier).value = profileId;
            },
          )
        : null;
    return ProfileItem(
      key: ValueKey(profile.id),
      profile: profile,
      groupValue: widget.currentProfileId,
      merged: _isMergedVisible(profile),
      isExpanded: expanded,
      headerHeight: rowHeight,
      footer: panel,
      onToggleExpand: () => _toggleExpand(profile.id),
      onChanged: (profileId) {
        ref.read(currentProfileIdProvider.notifier).value = profileId;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profiles = _visibleProfiles;
    return WidthBuilder(
      builder: (_, width) {
        final columns = _columnsFor(width);
        final rows = (profiles.length + columns - 1) ~/ columns;
        return PrismListView(
          key: profilesStoreKey,
          controller: _controller,
          padding: _padding,
          itemCount: rows,
          itemBuilder: (context, row) {
            final start = row * columns;
            final end = start + columns > profiles.length
                ? profiles.length
                : start + columns;
            final rowProfiles = profiles.sublist(start, end);
            final rowHeight = rowProfiles.any((profile) => profile.isBundle)
                ? _profileItemHeight + _profileItemDetailHeight
                : _profileItemHeight;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: widget.spacing,
                  children: [
                    for (var index = 0; index < columns; index++)
                      Expanded(
                        child: _buildCell(rowProfiles, index, rowHeight),
                      ),
                  ],
                ),
                if (row != rows - 1) SizedBox(height: widget.spacing),
              ],
            );
          },
        );
      },
    );
  }
}

class ProfileItem extends ConsumerWidget {
  final Profile profile;
  final int? groupValue;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;
  final void Function(int? value) onChanged;

  /// A second line under the quota, for what a merge adds up to.
  final String? detail;

  /// Marks a card that a merge also uses, when the merge shows its members.
  final bool merged;

  /// Draws the row on the surface below it, as a merge lists its members.
  final bool flat;

  final ShapeDecoration? decoration;

  final EdgeInsets? padding;

  /// Draws a row inside a merge a little smaller than a card of its own.
  final bool compact;

  final double? headerHeight;
  final Widget? footer;
  final Widget? leading;

  final double radius;

  const ProfileItem({
    super.key,
    required this.profile,
    required this.groupValue,
    required this.onChanged,
    this.isExpanded = false,
    this.onToggleExpand,
    this.detail,
    this.merged = false,
    this.flat = false,
    this.compact = false,
    this.decoration,
    this.padding,
    this.headerHeight,
    this.footer,
    this.leading,
    this.radius = AppCorner.xl,
  });

  Future<void> _handleDeleteProfile(BuildContext context, WidgetRef ref) async {
    final profilesAction = ref.read(profilesActionProvider.notifier);
    final appLocalizations = context.appLocalizations;
    final users = await profilesAction.providerUsers(profile);
    final bundles = ref.read(profilesProvider).bundlesOf(profile.id);
    final res = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: bundles.isNotEmpty
            ? appLocalizations.mergedDeleteMemberTip(bundles.first.realLabel)
            : users.isEmpty
            ? appLocalizations.deleteTip(appLocalizations.profile)
            : appLocalizations.providerInUse(
                profile.realLabel,
                users.map((item) => item.realLabel).join(', '),
              ),
      ),
      destructive: true,
      confirmText: appLocalizations.delete,
    );
    if (res != true) {
      return;
    }
    await profilesAction.deleteProfile(profile.id);
  }

  Future<void> _handlePreview(BuildContext context) async {
    unawaited(
      BaseNavigator.push<String>(context, PreviewProfileView(profile: profile)),
    );
  }

  Future updateProfile(WidgetRef ref) async {
    if (profile.type != ProfileType.url) return;
    await globalState.loadingRun(() async {
      await ref
          .read(profilesActionProvider.notifier)
          .updateProfile(profile, showLoading: true);
    }, tag: LoadingTag.profiles);
  }

  void _handleShowEditExtendPage(BuildContext context) {
    showExtend(
      context,
      builder: (context) => EditProfileView(profile: profile),
    );
  }

  SubscriptionInfo? get _subscriptionInfo =>
      profile.type == ProfileType.url || profile.isBundle
      ? profile.subscriptionInfo
      : null;

  String _subtitle(BuildContext context) {
    final bundle = profile.bundle;
    if (bundle != null) {
      final appLocalizations = context.appLocalizations;
      final info = profile.subscriptionInfo;
      final usage = info != null && info.usage != null
          ? '${(info.upload + info.download).traffic.show} / '
                '${info.total.traffic.show}'
          : null;
      final text =
          usage ?? appLocalizations.mergeMembersCount(bundle.members.length);
      return merged ? _marked(context, text) : text;
    }
    final info = _subscriptionInfo;
    final appLocalizations = context.appLocalizations;
    final text = info != null && info.usage != null
        ? '${(info.upload + info.download).traffic.show} / '
              '${info.total.traffic.show}'
        : switch (profile.type) {
            ProfileType.url => appLocalizations.remote,
            ProfileType.file => appLocalizations.local,
            ProfileType.custom => appLocalizations.custom,
          };
    return merged ? _marked(context, text) : text;
  }

  String _marked(BuildContext context, String text) =>
      '$text · ${context.appLocalizations.mergedBadge}';

  String? _detail(BuildContext context) {
    final bundle = profile.bundle;
    final report = bundle?.report;
    if (bundle == null || report == null || report.proxies <= 0) {
      return null;
    }
    return context.appLocalizations.mergeSummary(
      bundle.members.length,
      report.proxies,
    );
  }

  Widget _buildTrailing(BuildContext context, {required bool isUpdating}) {
    if (profile.isBundle && (profile.bundle?.collapsed ?? false)) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          AnimatedRotation(
            turns: isExpanded ? 0.5 : 0,
            duration: context.motionDuration(const Duration(milliseconds: 250)),
            curve: Curves.easeOutBack,
            child: IconButton(
              onPressed: onToggleExpand,
              icon: const GlyphIcon(AppGlyphs.chevronDown, size: 18),
              tooltip: context.appLocalizations.mergeExpand,
            ),
          ),
          _buildUpdateTime(context, isUpdating: isUpdating),
        ],
      );
    }
    return _buildUpdateTime(context, isUpdating: isUpdating);
  }

  Widget _buildUpdateTime(BuildContext context, {required bool isUpdating}) {
    return AnimatedSwitcher(
      duration: context.motionDuration(commonDuration),
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: AlignmentDirectional.centerEnd,
        children: [...previousChildren, ?currentChild],
      ),
      child: isUpdating
          ? const ActivityIndicator(key: ValueKey('updating'), size: 24)
          : LastUpdateTimeText(
              key: const ValueKey('lastUpdate'),
              lastUpdateDate: profile.lastUpdateDate,
              style: AppTextStyle.footnote.of(context).toLighter,
              compact: true,
            ),
    );
  }

  Future<void> _handleCopyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: profile.url));
    if (context.mounted) {
      dialogs.showBanner(
        context.appLocalizations.copySuccess,
        level: BannerLevel.success,
      );
    }
  }

  Future<void> _handleExportFile(BuildContext context) async {
    final appLocalizations = context.appLocalizations;
    final res = await globalState.safeRun<bool>(() async {
      final mFile = await profile.file;
      final value = await picker.saveFile(
        profile.exportFileName,
        mFile.readAsBytesSync(),
      );
      if (value == null) return false;
      return true;
    }, title: appLocalizations.tip);
    if (res == true && context.mounted) {
      dialogs.showBanner(
        appLocalizations.exportSuccess,
        level: BannerLevel.success,
      );
    }
  }

  void _handlePushGenProfilePage(BuildContext context, int id) {
    BaseNavigator.push(context, ExtendView(profileId: id));
  }

  void _handlePushCustomProfilePage(BuildContext context, int id) {
    BaseNavigator.push(context, CustomProfileView(profileId: id));
  }

  void _handleEdit(BuildContext context) {
    if (profile.isBundle) {
      unawaited(
        BaseNavigator.push<void>(
          context,
          MergeProfileView(profileId: profile.id),
        ),
      );
      return;
    }
    if (profile.type == ProfileType.custom) {
      _handlePushCustomProfilePage(context, profile.id);
    } else {
      _handleShowEditExtendPage(context);
    }
  }

  List<PopupMenuItem> _menuItems(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final isUrl = profile.type == ProfileType.url;
    final isCustom = profile.type == ProfileType.custom;
    final isBundle = profile.isBundle;
    return [
      PopupMenuItem(
        glyph: AppGlyphs.edit,
        label: appLocalizations.edit,
        onPressed: () => _handleEdit(context),
      ),
      if (isBundle) ...[
        PopupMenuItem(
          glyph: AppGlyphs.sync,
          label: appLocalizations.sync,
          onPressed: () {
            unawaited(
              globalState.loadingRun(
                () => ref
                    .read(bundlesActionProvider.notifier)
                    .generateBundle(profile.id, refresh: true),
                tag: LoadingTag.profiles,
                title: appLocalizations.sync,
              ),
            );
          },
        ),
      ] else if (isCustom) ...[
        PopupMenuItem(
          glyph: AppGlyphs.textShort,
          label: appLocalizations.rename,
          onPressed: () {
            renameProfile(context, ref, profile);
          },
        ),
        PopupMenuItem(
          glyph: AppGlyphs.eye,
          label: appLocalizations.runtimeConfig,
          onPressed: () {
            _handlePreview(context);
          },
        ),
      ] else
        PopupMenuItem(
          glyph: AppGlyphs.puzzle,
          label: appLocalizations.extend,
          onPressed: () {
            _handlePushGenProfilePage(context, profile.id);
          },
        ),

      if (isUrl)
        PopupMenuItem(
          glyph: AppGlyphs.sync,
          label: appLocalizations.sync,
          onPressed: () {
            updateProfile(ref);
          },
        ),
      if (!isCustom)
        PopupMenuItem(
          glyph: AppGlyphs.moreCircle,
          label: appLocalizations.more,
          subItems: [
            PopupMenuItem(
              glyph: AppGlyphs.eye,
              label: appLocalizations.runtimeConfig,
              onPressed: () {
                _handlePreview(context);
              },
            ),
            if (isUrl)
              PopupMenuItem(
                glyph: AppGlyphs.copy,
                label: appLocalizations.copyLink,
                onPressed: () {
                  _handleCopyLink(context);
                },
              ),
            if (isUrl)
              PopupMenuItem(
                glyph: AppGlyphs.qrCode,
                label: appLocalizations.qrcode,
                onPressed: () {
                  dialogs.showQrCode(
                    title: profile.realLabel,
                    data: profile.url,
                    message: appLocalizations.shareQrcodeTip,
                  );
                },
              ),
            PopupMenuItem(
              glyph: AppGlyphs.export,
              label: appLocalizations.exportFile,
              onPressed: () {
                _handleExportFile(context);
              },
            ),
          ],
        ),
      PopupMenuItem(
        danger: true,
        glyph: AppGlyphs.delete,
        label: appLocalizations.delete,
        onPressed: () {
          _handleDeleteProfile(context, ref);
        },
      ),
    ];
  }

  /// A flat row on a surface of its own, clipped to its corners so a press
  /// never spills past them.
  Widget _buildFlat(Widget row) {
    final decoration = this.decoration;
    if (decoration == null) {
      return row;
    }
    return ClipPath(
      clipper: ShapeBorderClipper(shape: decoration.shape),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(decoration: decoration, child: row),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUpdating = ref.watch(isUpdatingProvider(profile.updatingKey));
    final subscriptionInfo = _subscriptionInfo;
    final isSelected = profile.id == groupValue;
    final row = ListItem(
      key: Key(profile.id.toString()),
      leading: leading,
      minTileHeight: flat ? 0 : _profileItemHeight,
      minVerticalPadding: flat ? 0 : listRowVerticalPadding,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      onTap: flat ? () => onChanged(profile.id) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          if (profile.type == ProfileType.custom)
            _GroupsCountChip(profileId: profile.id)
          else
            _buildTrailing(context, isUpdating: isUpdating),
          if (isSelected) const SelectionBadge(size: 24),
        ],
      ),
      title: _ProfileCardTitle(
        profile: profile,
        expire: subscriptionInfo?.expireDate,
        // A subscription that reported a quota and no expiry never ends.
        permanent: (subscriptionInfo?.total ?? 0) > 0,
        subtitle: _subtitle(context),
        detail: _detail(context),
        compact: compact,
      ),
    );
    return ContextMenuRegion(
      menuItems: isUpdating ? null : _menuItems(context, ref),
      child: flat
          ? _buildFlat(row)
          : Card(
              enterActionsOnRight: true,
              radius: radius,
              isSelected: isSelected,
              onPressed: () {
                onChanged(profile.id);
              },
              child: ClipPath(
                clipper: ShapeBorderClipper(shape: AppShape.all(radius)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (headerHeight case final height?)
                      SizedBox(height: height, child: row)
                    else
                      row,
                    ?footer,
                  ],
                ),
              ),
            ),
    );
  }
}

class _ProfileCardTitle extends StatelessWidget {
  const _ProfileCardTitle({
    required this.profile,
    required this.expire,
    required this.permanent,
    required this.subtitle,
    this.detail,
    this.compact = false,
  });

  final Profile profile;
  final DateTime? expire;
  final bool permanent;
  final String subtitle;
  final String? detail;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChipTitle(
          title: profile.realLabel,
          expire: expire,
          permanent: permanent,
          expireStyle: compact
              ? AppTextStyle.caption2.of(context, emphasized: true)
              : null,
          style: compact
              ? AppTextStyle.custom(
                  context,
                  size: AppTextStyle.headline.size - 2.5,
                  leading: AppTextStyle.headline.leading - 3,
                  weight: FontWeight.w600,
                )
              : AppTextStyle.headline.of(context),
        ),
        SizedBox(height: compact ? _memberGap : _infoGap),
        Text(
          subtitle,
          style: AppTextStyle.footnote.of(context).toLighter,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (detail case final detail?) ...[
          const SizedBox(height: _infoGap),
          Text(
            detail,
            style: AppTextStyle.footnote.of(context).toLighter,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

/// Square-cornered so a lone digit never reads as a second [SelectionBadge].
class _GroupsCountChip extends ConsumerWidget {
  const _GroupsCountChip({required this.profileId});

  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(profileGroupsCountProvider(profileId)).value;
    if (count == null) {
      return const SizedBox.shrink();
    }
    final colorScheme = context.colorScheme;
    return Tooltip(
      message: context.appLocalizations.proxyGroupsCount(count, count.compact),
      child: TonalChip(
        label: count.compact,
        color: colorScheme.primary.opacity15,
        foregroundColor: colorScheme.primary,
      ),
    );
  }
}

class ReorderableProfilesSheet extends ConsumerStatefulWidget {
  final List<Profile> profiles;

  const ReorderableProfilesSheet({super.key, required this.profiles});

  @override
  ConsumerState<ReorderableProfilesSheet> createState() =>
      _ReorderableProfilesSheetState();
}

class _ReorderableProfilesSheetState
    extends ConsumerState<ReorderableProfilesSheet> {
  late List<Profile> profiles;

  @override
  void initState() {
    super.initState();
    profiles = List.from(widget.profiles);
  }

  Widget _buildItem(int index) {
    final position = ItemPosition.get(index, profiles.length);
    final profile = profiles[index];
    return ReorderDragStartListener(
      key: Key(profile.id.toString()),
      index: index,
      child: ItemPositionProvider(
        position: position,
        child: DecorationListItem(
          contentPadding: const EdgeInsets.only(left: 16),
          trailing: SortHandle(index: index),
          title: Text(profile.realLabel),
        ),
      ),
    );
  }

  void _handleSave() {
    Navigator.of(context).pop();
    final latest = ref.read(profilesProvider);
    final ids = {for (final profile in profiles) profile.id};
    ref.read(profilesProvider.notifier).reorder([
      for (final profile in profiles) ?latest.getProfile(profile.id),
      for (final profile in latest)
        if (!ids.contains(profile.id)) profile,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return Scaffold(
      confirmationAction: IconButtonData(
        glyph: AppGlyphs.check,
        onPressed: _handleSave,
        tooltip: context.appLocalizations.save,
      ),
      body: PrismReorderableListView(
        padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
          top: context.contentTopPadding,
          bottom: 32 + context.bottomInset,
        ),
        proxyDecorator: (child, index, animation) {
          return commonProxyDecorator(_buildItem(index), index, animation);
        },
        onReorderItem: (oldIndex, newIndex) {
          setState(() {
            profiles = profiles.copyAndReorder(oldIndex, newIndex);
          });
        },
        itemBuilder: (_, index) {
          return _buildItem(index);
        },
        itemCount: profiles.length,
      ),
      title: appLocalizations.profilesSort,
    );
  }
}

/// The subscriptions a merge folds away, drawn inside the merge's own card.
class BundleMembers extends ConsumerStatefulWidget {
  const BundleMembers({
    super.key,
    required this.profile,
    required this.expanded,
    required this.currentProfileId,
    required this.onSelect,
  });

  final Profile profile;
  final bool expanded;
  final int? currentProfileId;
  final ValueChanged<int> onSelect;

  @override
  ConsumerState<BundleMembers> createState() => _BundleMembersState();
}

class _BundleMembersState extends ConsumerState<BundleMembers>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 260);

  bool get _panelShown =>
      widget.expanded ||
      widget.profile.bundleMembers.any(
        (member) => member.id == widget.currentProfileId,
      );

  /// The rows the last frame drew. Folding away keeps them, so the card only
  /// ever shrinks from what it showed rather than jumping to the full list.
  List<int> _shownIds = const [];

  late final _controller = AnimationController(
    vsync: this,
    duration: _duration,
    value: _panelShown ? 1 : 0,
  );
  late final _size = UnfoldEntryTransition.curveOf(_controller);
  late final _fade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.25, 1, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((_) => setState(() {}));
  }

  @override
  void didUpdateWidget(BundleMembers oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_panelShown) {
      if (!_controller.isCompleted) {
        _controller.duration = context.motionDuration(_duration);
        _controller.forward();
      }
      return;
    }
    if (!_controller.isDismissed) {
      _controller.duration = context.motionDuration(_duration);
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _size.dispose();
    _fade.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildMember(BuildContext context, Profile profile) {
    final colorScheme = context.colorScheme;
    return ProfileItem(
      key: ValueKey('bundle_member_${profile.id}'),
      profile: profile,
      groupValue: widget.currentProfileId,
      flat: true,
      compact: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: ShapeDecoration(
        color: colorScheme.brightness == Brightness.dark
            ? SurfaceLevel.block.colorOf(colorScheme)
            : colorScheme.surfaceContainerLow,
        shape: AppShape.all(AppCorner.xl),
      ),
      onChanged: (profileId) {
        if (profileId != null) {
          widget.onSelect(profileId);
        }
      },
    );
  }

  List<int> _idsToShow(List<Profile> members) {
    if (widget.expanded) {
      return [for (final member in members) member.id];
    }
    final active = widget.currentProfileId;
    if (members.any((member) => member.id == active)) {
      return [active!];
    }
    return _controller.isDismissed ? const [] : _shownIds;
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(profilesProvider);
    final members = [
      for (final member in widget.profile.bundleMembers)
        ?profiles.getProfile(member.id),
    ];
    if (members.isEmpty) {
      return const SizedBox.shrink();
    }
    final ids = _idsToShow(members);
    _shownIds = ids;
    if (ids.isEmpty) {
      return const SizedBox.shrink();
    }
    final visible = [
      for (final member in members)
        if (ids.contains(member.id)) member,
    ];
    return SizeTransition(
      sizeFactor: _size,
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: _fade,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 12),
          child: AnimatedSize(
            duration: context.motionDuration(_duration),
            curve: Curves.fastOutSlowIn,
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                for (final member in visible) _buildMember(context, member),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
