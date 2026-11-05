import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/managed_mode.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_paths.dart';
import '../helpers/test_app.dart';

void main() {
  late ProviderContainer container;

  setUpAll(() async {
    final home = Directory.systemTemp.createTempSync('managed_mode');
    addTearDown(() => home.deleteSync(recursive: true));
    await useAppPaths(home);
  });

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    await tester.runAsync(() async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(child: ManagedModeView()),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
  }

  testWidgets('a hosted script with no source still offers to set one', (
    tester,
  ) async {
    await pump(tester);

    final l10n = currentAppLocalizations;
    expect(find.text(l10n.managedScriptSource), findsOne);
    expect(find.text(l10n.managedScriptUnset), findsOne);
    expect(find.text(l10n.managedScriptEmpty), findsOne);
    expect(find.text(l10n.managedScriptEnable), findsOne);
    expect(tester.takeException(), null);
  });
}
