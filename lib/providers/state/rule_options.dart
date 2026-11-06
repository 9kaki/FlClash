part of '../state.dart';

/// What a config offers to switch, and where saving it goes.
sealed class RuleSwitchSet {
  const RuleSwitchSet({
    required this.values,
    required this.groups,
    required this.icons,
    this.locked = const <String>{},
  });

  final Map<String, bool> values;

  final List<String> groups;

  final Map<String, String> icons;

  final Set<String> locked;
}

/// The hosted script's defaults, which every merge is built with.
final class HostedRuleSwitches extends RuleSwitchSet {
  const HostedRuleSwitches({
    required super.values,
    required super.groups,
    required super.icons,
  });
}

/// The switches a subscription's own script declares.
final class ScriptRuleSwitches extends RuleSwitchSet {
  const ScriptRuleSwitches({
    required this.profileId,
    required this.script,
    required this.content,
    required super.values,
    required super.groups,
    required super.icons,
  });

  final int profileId;
  final Script script;
  final String content;
}

/// The policy groups a subscription's own config carries.
final class GroupRuleSwitches extends RuleSwitchSet {
  const GroupRuleSwitches({
    required this.profileId,
    required super.values,
    required super.groups,
    required super.icons,
    required super.locked,
  });

  final int profileId;
}

/// A config's own switches; null names the hosted script's defaults.
@riverpod
Future<RuleSwitchSet?> ruleSwitches(Ref ref, int? profileId) async {
  final profile = profileId == null
      ? null
      : ref.watch(
          profilesProvider.select((profiles) => profiles.getProfile(profileId)),
        );
  if (profileId != null && profile == null) {
    return null;
  }
  if (profile == null || profile.isBundle) {
    final hosted = await ref.watch(managedOptionsProvider.future);
    return HostedRuleSwitches(
      values: hosted.values,
      groups: hosted.groups,
      icons: hosted.icons,
    );
  }
  if (profile.extendType == ExtendType.script) {
    return _ownScriptSwitches(profile);
  }
  return _ownGroupSwitches(profile);
}

Future<RuleSwitchSet?> _ownScriptSwitches(Profile profile) async {
  final scriptId = profile.scriptId;
  if (scriptId == null) {
    return null;
  }
  final script = await database.scriptsDao.get(scriptId).getSingleOrNull();
  final content = await script?.content;
  if (script == null || content == null || content.trim().isEmpty) {
    return null;
  }
  final declared = await extractRuleOptions(content);
  if (declared.options.isEmpty) {
    return null;
  }
  return ScriptRuleSwitches(
    profileId: profile.id,
    script: script,
    content: content,
    values: {
      for (final entry in declared.options.entries)
        entry.key: script.customOptions[entry.key] ?? entry.value,
    },
    groups: declared.groups,
    icons: declared.icons,
  );
}

Future<RuleSwitchSet?> _ownGroupSwitches(Profile profile) async {
  final Map<Object?, Object?> config;
  try {
    final path = await appPath.getProfilePath(profile.id.toString());
    final source = await readTextFileTask(path);
    if (source == null) {
      return null;
    }
    final decoded = await decodeYamlTask(source);
    if (decoded is! Map) {
      return null;
    }
    config = decoded;
  } catch (error) {
    commonPrint.log('rule switches could not read the profile: $error');
    return null;
  }
  final groups = <String>[];
  final icons = <String, String>{};
  final rawGroups = config['proxy-groups'];
  if (rawGroups is List) {
    for (final group in rawGroups) {
      if (group is! Map) {
        continue;
      }
      final name = group['name'];
      if (name is! String || name.isEmpty) {
        continue;
      }
      groups.add(name);
      final icon = group['icon'];
      if (icon is String && icon.isNotEmpty) {
        icons[name] = icon;
      }
    }
  }
  if (groups.isEmpty) {
    return null;
  }
  final rawRules = config['rules'] ?? config['rule'];
  final locked = <String>{};
  if (rawRules is List) {
    final target = lastMatchTarget([
      for (final rule in rawRules)
        if (rule is String) rule,
    ]);
    if (target != null) {
      locked.add(target);
    }
  }
  return GroupRuleSwitches(
    profileId: profile.id,
    groups: groups,
    icons: icons,
    locked: locked,
    values: {
      for (final name in groups) name: !profile.disabledGroups.contains(name),
    },
  );
}
