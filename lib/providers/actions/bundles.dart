part of '../action.dart';

@Riverpod(keepAlive: true)
class BundlesAction extends _$BundlesAction {
  final _debouncer = Debouncer();
  final _pending = <int>{};
  final _running = <int>{};

  CoreController get _core => ref.read(coreHandlerProvider);

  @override
  void build() {}

  Future<Profile> createBundle({
    required String label,
    required List<BundleMember> members,
    bool collapsed = true,
  }) async {
    final profile = Profile.bundle(
      label: label,
      members: members,
      collapsed: collapsed,
    );
    ref.read(profilesActionProvider.notifier).putProfile(profile);
    await generateBundle(profile.id);
    return ref.read(profilesProvider).getProfile(profile.id) ?? profile;
  }

  /// Merges the members into the bundle's own config file.
  Future<void> generateBundle(int id, {bool refresh = false}) async {
    if (!_running.add(id)) {
      return;
    }
    final updatingKeys = ref.read(updatingKeysProvider.notifier);
    final key =
        ref.read(profilesProvider).getProfile(id)?.updatingKey ?? 'profile_$id';
    final operation = updatingKeys.start(key);
    try {
      await _generate(id, refresh: refresh);
    } finally {
      updatingKeys.stop(key, operation);
      _running.remove(id);
    }
  }

  Future<void> _generate(int id, {required bool refresh}) async {
    final profile = ref.read(profilesProvider).getProfile(id);
    final bundle = profile?.bundle;
    if (profile == null || bundle == null) {
      return;
    }
    if (refresh) {
      await _refreshMembers(bundle.members);
    }
    final profiles = ref.read(profilesProvider);
    final script = await ManagedScript.content();
    final options = await ManagedScript.options();
    final inputs = <MergeMember>[];
    final failures = <int, String>{};
    final counts = <int, int>{};
    for (final member in bundle.members) {
      final target = profiles.getProfile(member.id);
      if (target == null || target.type == ProfileType.custom) {
        continue;
      }
      try {
        final config = await _memberConfig(target, script, options);
        counts[member.id] = bundleProxyCount(config);
        inputs.add((
          prefix: member.prefix ?? bundlePrefixOf(target.realLabel),
          label: target.realLabel,
          config: config,
        ));
      } catch (error) {
        failures[member.id] = compactError(error);
      }
    }
    if (inputs.isEmpty) {
      throw MessageException(
        [for (final entry in failures.entries) entry.value].join('\n'),
      );
    }
    final result = mergeBundleConfigs(inputs);
    final yaml = await encodeYamlTask(result.config);
    final issue = await _core.validateConfigWithData(utf8.encode(yaml));
    if (issue != null) {
      throw MessageException(issue);
    }
    final path = await appPath.getProfilePath(profile.id.toString());
    await File(path).safeWriteAsString(yaml);
    if (!ref.mounted) {
      return;
    }
    final latest = ref.read(profilesProvider).getProfile(id);
    if (latest == null) {
      return;
    }
    // Members were deleted while the merge ran; the bundle is no longer theirs.
    ref
        .read(profilesProvider.notifier)
        .updateProfile(
          id,
          (item) => item.copyWith(
            lastUpdateDate: DateTime.now(),
            subscriptionInfo: _usageOf(latest.bundleMembers),
            bundle: item.bundle?.copyWith(
              report: result.report,
              failures: failures,
              members: [
                for (final member
                    in item.bundle?.members ?? const <BundleMember>[])
                  member.copyWith(proxies: counts[member.id] ?? 0),
              ],
            ),
          ),
        );
    if (id == ref.read(currentProfileIdProvider)) {
      ref
          .read(setupActionProvider.notifier)
          .applyProfileDebounce(silence: true);
    }
  }

  /// The config a member contributes: its own script first, then the hosted
  /// script, both on the file the member holds.
  Future<Map<String, dynamic>> _memberConfig(
    Profile profile,
    String? script,
    Map<String, bool> options,
  ) async {
    var config = await _core.readConfig(profile.id);
    final memberScript = await _memberScript(profile);
    if (memberScript != null) {
      config = await handleEvaluate(
        memberScript.content,
        config,
        customOptions: memberScript.options,
      );
    }
    if (script == null) {
      return config;
    }
    try {
      return await handleEvaluate(script, config, customOptions: options);
    } catch (error) {
      // A hosted script that cannot run costs its transform, not the merge.
      commonPrint.log('hosted script skipped for ${profile.realLabel}: $error');
      return config;
    }
  }

  Future<({String content, Map<String, bool> options})?> _memberScript(
    Profile profile,
  ) async {
    final scriptId = profile.scriptId;
    if (profile.extendType != ExtendType.script || scriptId == null) {
      return null;
    }
    final script = await database.scriptsDao.get(scriptId).getSingleOrNull();
    final content = await script?.content;
    if (script == null || content == null || content.trim().isEmpty) {
      return null;
    }
    return (content: content, options: script.customOptions);
  }

  SubscriptionInfo? _usageOf(List<BundleMember> members) {
    final profiles = ref.read(profilesProvider);
    return [
      for (final member in members)
        ?profiles.getProfile(member.id)?.subscriptionInfo,
    ].combined;
  }

  Future<void> _refreshMembers(List<BundleMember> members) async {
    final action = ref.read(profilesActionProvider.notifier);
    for (final member in members) {
      final target = ref.read(profilesProvider).getProfile(member.id);
      if (target == null || target.type != ProfileType.url) {
        continue;
      }
      try {
        await action.updateProfile(target);
      } catch (error) {
        commonPrint.log(
          'bundle member ${target.realLabel} did not update: $error',
        );
      }
    }
  }

  /// Merges wait for the edit that triggered them, so a burst of changes runs
  /// once.
  void scheduleGenerate(Iterable<int> ids) {
    _pending.addAll(ids);
    if (_pending.isEmpty) {
      return;
    }
    _debouncer.call('bundles', _flush, duration: const Duration(seconds: 1));
  }

  Future<void> _flush() async {
    final ids = _pending.toList();
    _pending.clear();
    for (final id in ids) {
      try {
        await generateBundle(id);
      } catch (error) {
        commonPrint.log('bundle $id did not regenerate: $error');
      }
    }
  }

  /// Bundles a member's config feeds, so an edit or an update reaches them.
  void generateBundlesOf(int memberId) {
    final ids = [
      for (final bundle in ref.read(profilesProvider).bundlesOf(memberId))
        bundle.id,
    ];
    if (ids.isNotEmpty) {
      scheduleGenerate(ids);
    }
  }

  /// A bundle whose file is gone, after a restore or a failed first merge,
  /// builds again the next time the app opens.
  Future<void> generateMissing() async {
    for (final profile in ref.read(profilesProvider)) {
      if (!profile.isBundle) {
        continue;
      }
      final path = await appPath.getProfilePath(profile.id.toString());
      if (await File(path).exists()) {
        continue;
      }
      try {
        await generateBundle(profile.id);
      } catch (error) {
        commonPrint.log('bundle ${profile.realLabel} did not build: $error');
      }
    }
  }

  void generateAll() {
    final ids = [
      for (final profile in ref.read(profilesProvider))
        if (profile.isBundle) profile.id,
    ];
    if (ids.isNotEmpty) {
      scheduleGenerate(ids);
    }
  }

  /// A deleted profile leaves every bundle that named it.
  void detachMember(int memberId) {
    final profiles = ref.read(profilesProvider);
    final regenerate = <int>[];
    for (final bundle in profiles.bundlesOf(memberId)) {
      final members = [
        for (final member in bundle.bundleMembers)
          if (member.id != memberId) member,
      ];
      ref
          .read(profilesProvider.notifier)
          .updateProfile(
            bundle.id,
            (item) => item.copyWith(
              bundle: item.bundle?.copyWith(
                members: members,
                failures: {...?item.bundle?.failures}..remove(memberId),
              ),
            ),
          );
      if (members.isNotEmpty) {
        regenerate.add(bundle.id);
      }
    }
    if (regenerate.isNotEmpty) {
      scheduleGenerate(regenerate);
    }
  }
}
