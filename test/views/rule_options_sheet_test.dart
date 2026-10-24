import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:fl_clash/views/proxies/rule_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/app_paths.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

void main() {
  late ProviderContainer container;

  const config = '''
proxy-groups:
  - name: Group A
    type: select
    proxies: [DIRECT]
  - name: Group B
    type: select
    proxies: [DIRECT]
''';

  setUp(() async {
    final home = Directory.systemTemp.createTempSync('rule_options');
    addTearDown(() => home.deleteSync(recursive: true));
    await useAppPaths(home);
    final path = await appPath.getProfilePath('1');
    await File(path).create(recursive: true);
    await File(path).writeAsString(config);

    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(
          () => TestProfiles(const [
            Profile(
              id: 1,
              label: 'sub',
              url: 'https://example.com/sub',
              type: ProfileType.url,
              autoUpdateDuration: Duration.zero,
            ),
          ]),
        ),
        viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 1000)),
      ],
    );
    globalState.container = container;
    container.listen(currentProfileIdProvider, (_, _) {});
    container.read(currentProfileIdProvider.notifier).value = 1;
    addTearDown(container.dispose);
  });

  /// The switches read and parse the profile off the UI isolate, which only
  /// runs in real time.
  Future<void> pumpSheet(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: Scaffold(body: RuleOptionsSheet())),
      ),
    );
    for (var i = 0; i < 40; i++) {
      if (find.text('Group A').evaluate().isNotEmpty) {
        break;
      }
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
  }

  testWidgets('a switch waits for the check before it is stored', (
    tester,
  ) async {
    await pumpSheet(tester);

    expect(find.text('Group A'), findsOneWidget);
    expect(find.byTooltip(currentAppLocalizations.save), findsNothing);

    await tester.tap(find.byType(CommonSwitch).first);
    await tester.pumpAndSettle();

    expect(find.byTooltip(currentAppLocalizations.save), findsOneWidget);
    expect(container.read(profilesProvider).single.disabledGroups, isEmpty);
  });

  testWidgets('turning a switch back leaves nothing to save', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.byType(CommonSwitch).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CommonSwitch).first);
    await tester.pumpAndSettle();

    expect(find.byTooltip(currentAppLocalizations.save), findsNothing);
  });
}
