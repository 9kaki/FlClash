import 'dart:io';
import 'dart:typed_data';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'clash_config.dart';

part 'generated/profile.freezed.dart';
part 'generated/profile.g.dart';

/// Why the config at the path cannot be used, or null.
typedef ValidateConfig =
    Future<String?> Function(String path, String ageSecretKey);

@freezed
abstract class SubscriptionInfo with _$SubscriptionInfo {
  const factory SubscriptionInfo({
    @Default(0) int upload,
    @Default(0) int download,
    @Default(0) int total,
    @Default(0) int expire,
  }) = _SubscriptionInfo;

  factory SubscriptionInfo.fromJson(Map<String, Object?> json) =>
      _$SubscriptionInfoFromJson(json);

  factory SubscriptionInfo.formHString(String? info) {
    if (info == null) return const SubscriptionInfo();
    final Map<String, int> map = {};
    for (final field in info.split(';')) {
      final separator = field.indexOf('=');
      if (separator == -1) continue;
      final value = _parseCount(field.substring(separator + 1).trim());
      if (value != null) {
        map[field.substring(0, separator).trim().toLowerCase()] = value;
      }
    }
    return SubscriptionInfo(
      upload: map['upload'] ?? 0,
      download: map['download'] ?? 0,
      total: map['total'] ?? 0,
      expire: map['expire'] ?? 0,
    );
  }

  static int? _parseCount(String value) {
    final count = int.tryParse(value);
    if (count != null) return count;
    final decimal = double.tryParse(value);
    return decimal != null && decimal.isFinite ? decimal.truncate() : null;
  }
}

extension SubscriptionInfoExt on SubscriptionInfo {
  double? get usage =>
      total > 0 ? ((upload + download) / total).clamp(0.0, 1.0) : null;

  DateTime? get expireDate =>
      expire > 0 ? DateTime.fromMillisecondsSinceEpoch(expire * 1000) : null;

  /// Whether the server reported anything at all.
  bool get hasUsage => upload + download + total > 0;
}

@freezed
abstract class BundleMember with _$BundleMember {
  const factory BundleMember({
    required int id,

    /// What this member's proxies are labelled with; null takes the label's
    /// own prefix, as the merge page shows it.
    String? prefix,
  }) = _BundleMember;

  factory BundleMember.fromJson(Map<String, Object?> json) =>
      _$BundleMemberFromJson(json);
}

@freezed
abstract class BundleReport with _$BundleReport {
  const factory BundleReport({
    @Default(0) int proxies,
    @Default(0) int duplicates,
    @Default(0) int groups,
  }) = _BundleReport;

  factory BundleReport.fromJson(Map<String, Object?> json) =>
      _$BundleReportFromJson(json);
}

/// The subscriptions a bundle merges, and what the last merge made of them.
@freezed
abstract class ProfileBundle with _$ProfileBundle {
  const factory ProfileBundle({
    @Default(<BundleMember>[]) List<BundleMember> members,
    @Default(BundleReport()) BundleReport report,

    /// Member id to why its config could not join the last merge.
    @Default(<int, String>{}) Map<int, String> failures,
    @Default(false) bool collapsed,
  }) = _ProfileBundle;

  factory ProfileBundle.fromJson(Map<String, Object?> json) =>
      _$ProfileBundleFromJson(json);
}

@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required int id,
    @Default(ProfileType.file) ProfileType type,
    @Default('') String label,
    String? currentGroupName,
    @Default('') String url,
    @Default('') String ageSecretKey,
    DateTime? lastUpdateDate,
    required Duration autoUpdateDuration,
    SubscriptionInfo? subscriptionInfo,
    @Default(true) bool autoUpdate,
    @Default({}) Map<String, String> selectedMap,
    @Default({}) Set<String> unfoldSet,
    @Default(ExtendType.standard) ExtendType extendType,
    int? scriptId,
    String? matchTarget,
    int? order,

    /// What this profile merges; null for one that carries its own config.
    ProfileBundle? bundle,

    /// Policy groups the reader switched off in the YAML rule switches. The
    /// build drops them, the groups that name them, and the rules that point
    /// at them.
    @Default(<String>{}) Set<String> disabledGroups,
    @Default(ProfileOverrides())
    @JsonKey(fromJson: ProfileOverrides.safeFromJson)
    ProfileOverrides overrides,
  }) = _Profile;

  factory Profile.fromJson(Map<String, Object?> json) =>
      _$ProfileFromJson(json);

  factory Profile.normal({String? label, String url = ''}) {
    final id = snowflake.id;
    return Profile(
      type: url.isEmpty ? ProfileType.file : ProfileType.url,
      label: label ?? '',
      url: url,
      id: id,
      autoUpdateDuration: defaultUpdateDuration,
    );
  }

  factory Profile.custom({String? label}) {
    return Profile(
      id: snowflake.id,
      type: ProfileType.custom,
      label: label ?? '',
      lastUpdateDate: DateTime.now(),
      autoUpdate: false,
      autoUpdateDuration: defaultUpdateDuration,
    );
  }

  factory Profile.bundle({
    required String label,
    required List<BundleMember> members,
    bool collapsed = true,
  }) {
    return Profile(
      id: snowflake.id,
      label: label,
      lastUpdateDate: DateTime.now(),
      autoUpdate: false,
      autoUpdateDuration: defaultUpdateDuration,
      bundle: ProfileBundle(members: members, collapsed: collapsed),
    );
  }
}

/// A profile leaving out one of the global rules its extension would add.
@freezed
abstract class DisabledRule with _$DisabledRule {
  const factory DisabledRule({required int profileId, required int ruleId}) =
      _DisabledRule;
}

extension ProfilesExt on List<Profile> {
  Profile? getProfile(int? profileId) {
    final index = indexWhere((profile) => profile.id == profileId);
    return index == -1 ? null : this[index];
  }

  /// The ids a collapsed bundle hides from the list.
  Set<int> get collapsedMemberIds => {
    for (final profile in this)
      if (profile.bundle case final bundle? when bundle.collapsed)
        for (final member in bundle.members) member.id,
  };

  /// The bundles a member's config feeds.
  List<Profile> bundlesOf(int memberId) => [
    for (final profile in this)
      if (profile.bundle?.members.any((member) => member.id == memberId) ??
          false)
        profile,
  ];

  Profile optimizeLabel(Profile profile) {
    return profile.copyWith(
      label: uniqueLabelFor(
        profile.label,
        fallback: profile.defaultLabel,
        taken: (label) =>
            any((item) => item.label == label && item.id != profile.id),
      ),
    );
  }
}

extension BundleMembersExt on List<BundleMember> {
  bool containsProfile(int profileId) =>
      any((member) => member.id == profileId);
}

extension SubscriptionInfosExt on Iterable<SubscriptionInfo> {
  /// One meter's worth of several plans: what they carry is added up, and the
  /// deadline that comes first is the one worth warning about.
  SubscriptionInfo? get combined {
    var upload = 0;
    var download = 0;
    var total = 0;
    var expire = 0;
    for (final info in this) {
      if (!info.hasUsage && info.expire <= 0) {
        continue;
      }
      upload += info.upload;
      download += info.download;
      total += info.total;
      if (info.expire > 0 && (expire == 0 || info.expire < expire)) {
        expire = info.expire;
      }
    }
    if (upload + download + total + expire <= 0) {
      return null;
    }
    return SubscriptionInfo(
      upload: upload,
      download: download,
      total: total,
      expire: expire,
    );
  }
}

extension ProfileExtension on Profile {
  bool get realAutoUpdate => type == ProfileType.url && autoUpdate;

  bool get isBundle => bundle != null;

  List<BundleMember> get bundleMembers => bundle?.members ?? const [];

  /// A profile that points at its own config file, which a bundle does not.
  bool get hasOwnConfig => bundle == null;

  String get realLabel => label.takeFirstValid([defaultLabel]);

  String get defaultLabel => url.webUri?.host ?? id.toString();

  String get fileName => '$id.yaml';

  String get exportFileName {
    final label = realLabel;
    final lower = label.toLowerCase();
    if (lower.endsWith('.yaml') || lower.endsWith('.yml')) {
      return label;
    }
    return '$label.yaml';
  }

  String get updatingKey => 'profile_$id';

  Future<Profile?> checkAndUpdateAndCopy({
    required ValidateConfig validate,
  }) async {
    if (type != ProfileType.url) {
      return null;
    }
    final mFile = await _getFile(false);
    if (await mFile.exists()) {
      return null;
    }
    return update(validate: validate);
  }

  Future<File> _getFile([bool autoCreate = true]) async {
    final path = await appPath.getProfilePath(id.toString());
    final file = File(path);
    final isExists = await file.exists();
    if (!isExists && autoCreate) {
      return file.create(recursive: true);
    }
    return file;
  }

  Future<File> get file async {
    return _getFile();
  }

  Future<Profile> update({required ValidateConfig validate}) async {
    final response = await request.getFileResponseForUrl(url);
    final disposition = response.headers.value('content-disposition');
    final userinfo = response.headers.value('subscription-userinfo');
    return copyWith(
      label: label.takeFirstValid([
        getFileNameForDisposition(disposition),
        defaultLabel,
      ]),
      subscriptionInfo: SubscriptionInfo.formHString(userinfo),
    ).saveFile(
      decompressUnlabeled(response.data ?? Uint8List(0)),
      validate: validate,
    );
  }

  Future<Profile> saveFile(
    Uint8List bytes, {
    required ValidateConfig validate,
  }) async {
    final path = await appPath.tempFilePath;
    final tempFile = File(path);
    await tempFile.safeWriteAsBytes(bytes);
    if (await validate(path, ageSecretKey) case final issue?) {
      throw MessageException(issue);
    }
    final mFile = await file;
    await tempFile.copy(mFile.path);
    await tempFile.safeDelete();
    return copyWith(lastUpdateDate: DateTime.now());
  }
}
