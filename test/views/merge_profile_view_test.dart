import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/merge.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

Profile _url(String label, int id) => Profile(
  id: id,
  type: ProfileType.url,
  label: label,
  url: 'https://$id.example.com/sub',
  autoUpdateDuration: defaultUpdateDuration,
  subscriptionInfo: const SubscriptionInfo(
    upload: 1 << 30,
    download: 1 << 30,
    total: 1 << 32,
  ),
);

Profile _bundle(List<BundleMember> members) => Profile(
  id: 9,
  label: '合并订阅1',
  autoUpdateDuration: defaultUpdateDuration,
  lastUpdateDate: DateTime(2026, 11, 5),
  bundle: ProfileBundle(
    members: members,
    report: const BundleReport(proxies: 12, duplicates: 3, groups: 4),
  ),
);

ProviderContainer _containerFor(WidgetTester tester, List<Profile> profiles) {
  const size = Size(1000, 1400);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer(
    overrides: [profilesProvider.overrideWith(() => TestProfiles(profiles))],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).update((_) => size);
  return container;
}

Future<void> _pump(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const TestApp(child: MergeProfileView(profileId: 9)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists the subscriptions a merge holds', (tester) async {
    final container = _containerFor(tester, [
      _url('机场甲', 1),
      _url('机场乙', 2),
      _bundle(const [BundleMember(id: 1), BundleMember(id: 2)]),
    ]);

    await _pump(tester, container);

    final l10n = currentAppLocalizations;
    expect(find.text(l10n.mergeMembers), findsOne);
    expect(find.text('机场甲'), findsOne);
    expect(find.text('机场乙'), findsOne);
    expect(find.text(l10n.mergeNodePrefixValue('机场')), findsNWidgets(2));
    expect(find.text('合并订阅1'), findsOne);
    expect(tester.takeException(), null);
  });

  testWidgets('offers the profiles that have not joined yet', (tester) async {
    final container = _containerFor(tester, [
      _url('机场甲', 1),
      _url('机场乙', 2),
      _url('机场丙', 3),
      _bundle(const [BundleMember(id: 1)]),
    ]);

    await _pump(tester, container);

    final l10n = currentAppLocalizations;
    expect(find.text(l10n.mergeAddMember), findsOne);
    expect(find.text('机场乙'), findsOne);
    expect(find.text('机场丙'), findsOne);
    expect(tester.takeException(), null);
  });

  testWidgets('reports what the last merge made of the members', (
    tester,
  ) async {
    final container = _containerFor(tester, [
      _url('机场甲', 1),
      _bundle(const [BundleMember(id: 1)]),
    ]);

    await _pump(tester, container);

    final l10n = currentAppLocalizations;
    expect(find.text(l10n.mergeLastGenerated), findsOne);
    expect(find.text(l10n.mergeReport(12, 3, 4)), findsOne);
    expect(tester.takeException(), null);
  });
}
