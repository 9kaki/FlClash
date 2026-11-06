import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/profiles.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_paths.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

Profile _url(int id, String label) => Profile(
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

Profile _bundle(
  List<BundleMember> members, {
  bool collapsed = true,
  BundleReport report = const BundleReport(),
}) => Profile(
  id: 9,
  label: '合并订阅1',
  autoUpdateDuration: defaultUpdateDuration,
  lastUpdateDate: DateTime(2026, 11, 5),
  bundle: ProfileBundle(members: members, collapsed: collapsed, report: report),
);

void main() {
  late ProviderContainer container;

  setUpAll(() async {
    final home = Directory.systemTemp.createTempSync('profiles_bundle');
    addTearDown(() => home.deleteSync(recursive: true));
    await useAppPaths(home);
  });

  void setUpProfiles(
    WidgetTester tester,
    List<Profile> profiles, {
    Size size = const Size(1200, 1600),
  }) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles(profiles)),
        viewSizeProvider.overrideWithBuild((_, _) => size),
      ],
    );
    globalState.container = container;
    addTearDown(container.dispose);
  }

  Future<void> pumpProfiles(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ProfilesView()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a collapsed merge stands for its subscriptions', (tester) async {
    setUpProfiles(tester, [
      _url(1, '机场甲'),
      _url(2, '机场乙'),
      _bundle(const [BundleMember(id: 1), BundleMember(id: 2)]),
    ]);

    await pumpProfiles(tester);

    expect(find.text('合并订阅1'), findsOne);
    expect(find.text('机场甲'), findsNothing);
    expect(find.text('机场乙'), findsNothing);
    expect(
      find.textContaining(currentAppLocalizations.mergeMembersCount(2)),
      findsOne,
    );
    expect(tester.takeException(), null);
  });

  testWidgets('opening a merge lists the subscriptions in it', (tester) async {
    setUpProfiles(tester, [
      _url(1, '机场甲'),
      _url(2, '机场乙'),
      _bundle(const [BundleMember(id: 1), BundleMember(id: 2)]),
    ]);

    await pumpProfiles(tester);

    expect(find.text('机场甲'), findsNothing);
    await tester.tap(find.byTooltip(currentAppLocalizations.mergeExpand));
    await tester.pumpAndSettle();
    expect(find.text('机场甲'), findsOne);
    expect(find.text('机场乙'), findsOne);
    expect(tester.takeException(), null);
  });

  testWidgets('a phone keeps the merge card on one line', (tester) async {
    setUpProfiles(tester, [
      _url(1, '机场甲'),
      _url(2, '机场乙'),
      _bundle(const [BundleMember(id: 1), BundleMember(id: 2)]),
    ], size: const Size(400, 1600));

    await pumpProfiles(tester);

    expect(find.text('合并订阅1'), findsOne);
    expect(tester.takeException(), null);
  });

  testWidgets('tapping a subscription uses it on its own', (tester) async {
    setUpProfiles(tester, [
      _url(1, '机场甲'),
      _url(2, '机场乙'),
      _bundle(const [BundleMember(id: 1), BundleMember(id: 2)]),
    ]);

    await pumpProfiles(tester);
    expect(find.text('机场甲'), findsNothing);
    await tester.tap(find.byTooltip(currentAppLocalizations.mergeExpand));
    await tester.pumpAndSettle();
    await tester.tap(find.text('机场乙'));
    await tester.pump();

    expect(container.read(currentProfileIdProvider), 2);
    expect(tester.takeException(), null);
  });

  testWidgets('the merge card names the nodes the merge holds', (tester) async {
    setUpProfiles(tester, [
      _url(1, '机场甲'),
      _bundle(const [
        BundleMember(id: 1),
      ], report: const BundleReport(proxies: 292)),
    ]);

    await pumpProfiles(tester);

    expect(
      find.textContaining(currentAppLocalizations.mergeProxiesCount(292)),
      findsOne,
    );
    expect(tester.takeException(), null);
  });

  testWidgets('the merge reports the nodes once, not per member', (
    tester,
  ) async {
    setUpProfiles(tester, [
      _url(1, '机场甲'),
      _bundle(const [
        BundleMember(id: 1, proxies: 120),
      ], report: const BundleReport(proxies: 120)),
    ]);

    await pumpProfiles(tester);
    await tester.tap(find.byTooltip(currentAppLocalizations.mergeExpand));
    await tester.pumpAndSettle();

    expect(
      find.textContaining(currentAppLocalizations.mergeProxiesCount(120)),
      findsOne,
    );
    expect(tester.takeException(), null);
  });

  testWidgets('a merge that shows its members marks each one merged', (
    tester,
  ) async {
    setUpProfiles(tester, [
      _url(1, '机场甲'),
      _bundle(
        const [BundleMember(id: 1)],
        collapsed: false,
        report: const BundleReport(proxies: 10),
      ),
    ]);

    await pumpProfiles(tester);

    expect(find.text('机场甲'), findsOne);
    expect(find.text(currentAppLocalizations.mergedBadge), findsOne);
    expect(find.byTooltip(currentAppLocalizations.mergeExpand), findsNothing);
    expect(tester.takeException(), null);
  });

  testWidgets('a folded merge hides its members and the mark', (tester) async {
    setUpProfiles(tester, [
      _url(1, '机场甲'),
      _bundle(const [BundleMember(id: 1)], collapsed: true),
    ]);

    await pumpProfiles(tester);

    expect(find.text('机场甲'), findsNothing);
    expect(find.text(currentAppLocalizations.mergedBadge), findsNothing);
    expect(find.byTooltip(currentAppLocalizations.mergeExpand), findsOne);
    expect(tester.takeException(), null);
  });

  testWidgets('a member in use sits under its merge, alone checked', (
    tester,
  ) async {
    setUpProfiles(tester, [
      _url(1, '机场甲'),
      _url(2, '机场乙'),
      _bundle(const [BundleMember(id: 1), BundleMember(id: 2)]),
    ]);

    await pumpProfiles(tester);
    await tester.tap(find.byTooltip(currentAppLocalizations.mergeExpand));
    await tester.pumpAndSettle();
    await tester.tap(find.text('机场乙'));
    await tester.pumpAndSettle();

    expect(container.read(currentProfileIdProvider), 2);
    expect(find.text('机场乙'), findsOne);
    expect(find.text('机场甲'), findsNothing);
    expect(find.byType(SelectionBadge), findsOne);
  });

  testWidgets('long pressing a member opens the profile menu', (tester) async {
    setUpProfiles(tester, [
      _url(1, '机场甲'),
      _bundle(const [BundleMember(id: 1)]),
    ]);

    await pumpProfiles(tester);
    await tester.tap(find.byTooltip(currentAppLocalizations.mergeExpand));
    await tester.pumpAndSettle();
    await tester.longPress(find.text('机场甲'));
    await tester.pumpAndSettle();

    expect(find.text(currentAppLocalizations.extend), findsOne);
    expect(find.text(currentAppLocalizations.delete), findsOne);
    expect(tester.takeException(), null);
  });
}
