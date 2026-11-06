import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widgets/profile_detail.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_paths.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

Profile _url(int id, String label, int upload, int total) => Profile(
  id: id,
  type: ProfileType.url,
  label: label,
  url: 'https://$id.example.com/sub',
  autoUpdateDuration: defaultUpdateDuration,
  subscriptionInfo: SubscriptionInfo(upload: upload, total: total),
);

Profile _bundle(List<BundleMember> members) => Profile(
  id: 9,
  label: '合并订阅1',
  autoUpdateDuration: defaultUpdateDuration,
  lastUpdateDate: DateTime(2026, 11, 6),
  subscriptionInfo: const SubscriptionInfo(upload: 1 << 30, total: 1 << 32),
  bundle: ProfileBundle(
    members: members,
    report: const BundleReport(proxies: 287),
  ),
);

void main() {
  setUpAll(() async {
    final home = Directory.systemTemp.createTempSync('detail_bundle');
    addTearDown(() => home.deleteSync(recursive: true));
    await useAppPaths(home);
  });

  testWidgets('a merge detail lists its subscriptions one by one', (
    tester,
  ) async {
    const size = Size(420, 1200);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(
          () => TestProfiles([
            _url(1, '机场甲', 1 << 30, 1 << 32),
            _url(2, '机场乙', 1 << 29, 1 << 31),
            _bundle(const [BundleMember(id: 1), BundleMember(id: 2)]),
          ]),
        ),
        currentProfileIdProvider.overrideWithBuild((_, _) => 9),
        viewSizeProvider.overrideWithBuild((_, _) => size),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ProfileDetailSheet()),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = currentAppLocalizations;
    expect(find.text(l10n.mergeMembers), findsOne);
    expect(find.text('机场甲'), findsOne);
    expect(find.text('机场乙'), findsOne);
    expect(find.text(l10n.mergeProxiesCount(287)), findsNothing);
    expect(tester.takeException(), null);
  });
}
