// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubscriptionInfo _$SubscriptionInfoFromJson(Map<String, dynamic> json) =>
    _SubscriptionInfo(
      upload: (json['upload'] as num?)?.toInt() ?? 0,
      download: (json['download'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      expire: (json['expire'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SubscriptionInfoToJson(_SubscriptionInfo instance) =>
    <String, dynamic>{
      'upload': instance.upload,
      'download': instance.download,
      'total': instance.total,
      'expire': instance.expire,
    };

_BundleMember _$BundleMemberFromJson(Map<String, dynamic> json) =>
    _BundleMember(
      id: (json['id'] as num).toInt(),
      prefix: json['prefix'] as String?,
      proxies: (json['proxies'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$BundleMemberToJson(_BundleMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'prefix': instance.prefix,
      'proxies': instance.proxies,
    };

_BundleReport _$BundleReportFromJson(Map<String, dynamic> json) =>
    _BundleReport(
      proxies: (json['proxies'] as num?)?.toInt() ?? 0,
      duplicates: (json['duplicates'] as num?)?.toInt() ?? 0,
      groups: (json['groups'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$BundleReportToJson(_BundleReport instance) =>
    <String, dynamic>{
      'proxies': instance.proxies,
      'duplicates': instance.duplicates,
      'groups': instance.groups,
    };

_ProfileBundle _$ProfileBundleFromJson(Map<String, dynamic> json) =>
    _ProfileBundle(
      members:
          (json['members'] as List<dynamic>?)
              ?.map((e) => BundleMember.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <BundleMember>[],
      report: json['report'] == null
          ? const BundleReport()
          : BundleReport.fromJson(json['report'] as Map<String, dynamic>),
      failures:
          (json['failures'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(int.parse(k), e as String),
          ) ??
          const <int, String>{},
      collapsed: json['collapsed'] as bool? ?? false,
    );

Map<String, dynamic> _$ProfileBundleToJson(_ProfileBundle instance) =>
    <String, dynamic>{
      'members': instance.members,
      'report': instance.report,
      'failures': instance.failures.map((k, e) => MapEntry(k.toString(), e)),
      'collapsed': instance.collapsed,
    };

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: (json['id'] as num).toInt(),
  type:
      $enumDecodeNullable(_$ProfileTypeEnumMap, json['type']) ??
      ProfileType.file,
  label: json['label'] as String? ?? '',
  currentGroupName: json['currentGroupName'] as String?,
  url: json['url'] as String? ?? '',
  ageSecretKey: json['ageSecretKey'] as String? ?? '',
  lastUpdateDate: json['lastUpdateDate'] == null
      ? null
      : DateTime.parse(json['lastUpdateDate'] as String),
  autoUpdateDuration: Duration(
    microseconds: (json['autoUpdateDuration'] as num).toInt(),
  ),
  subscriptionInfo: json['subscriptionInfo'] == null
      ? null
      : SubscriptionInfo.fromJson(
          json['subscriptionInfo'] as Map<String, dynamic>,
        ),
  autoUpdate: json['autoUpdate'] as bool? ?? true,
  selectedMap:
      (json['selectedMap'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  unfoldSet:
      (json['unfoldSet'] as List<dynamic>?)?.map((e) => e as String).toSet() ??
      const {},
  extendType:
      $enumDecodeNullable(_$ExtendTypeEnumMap, json['extendType']) ??
      ExtendType.standard,
  scriptId: (json['scriptId'] as num?)?.toInt(),
  matchTarget: json['matchTarget'] as String?,
  order: (json['order'] as num?)?.toInt(),
  bundle: json['bundle'] == null
      ? null
      : ProfileBundle.fromJson(json['bundle'] as Map<String, dynamic>),
  disabledGroups:
      (json['disabledGroups'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toSet() ??
      const <String>{},
  overrides: json['overrides'] == null
      ? const ProfileOverrides()
      : ProfileOverrides.safeFromJson(
          json['overrides'] as Map<String, Object?>,
        ),
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$ProfileTypeEnumMap[instance.type]!,
  'label': instance.label,
  'currentGroupName': instance.currentGroupName,
  'url': instance.url,
  'ageSecretKey': instance.ageSecretKey,
  'lastUpdateDate': instance.lastUpdateDate?.toIso8601String(),
  'autoUpdateDuration': instance.autoUpdateDuration.inMicroseconds,
  'subscriptionInfo': instance.subscriptionInfo,
  'autoUpdate': instance.autoUpdate,
  'selectedMap': instance.selectedMap,
  'unfoldSet': instance.unfoldSet.toList(),
  'extendType': _$ExtendTypeEnumMap[instance.extendType]!,
  'scriptId': instance.scriptId,
  'matchTarget': instance.matchTarget,
  'order': instance.order,
  'bundle': instance.bundle,
  'disabledGroups': instance.disabledGroups.toList(),
  'overrides': instance.overrides,
};

const _$ProfileTypeEnumMap = {
  ProfileType.file: 'file',
  ProfileType.url: 'url',
  ProfileType.custom: 'custom',
};

const _$ExtendTypeEnumMap = {
  ExtendType.standard: 'standard',
  ExtendType.script: 'script',
};
