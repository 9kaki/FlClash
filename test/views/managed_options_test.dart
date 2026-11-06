import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/managed_script.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/managed_mode.dart';
import 'package:fl_clash/views/config/managed_options.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rust_api/rust_api.dart';

import '../helpers/app_paths.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

const _icon =
    'data:image/png;base64,'
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

const _script = '''
// @version 7
var ruleOptionsEnable = { "手动选择": true, "Emby": true, "极简模式": false };
function main(config) { return config; }
''';

/// The probe's own answer, as the script engine would hand it back.
String _probeAnswer({Map<String, String> icons = const {'Emby': _icon}}) {
  return json.encode({
    '__flclashRuleOptions': {
      'options': {'手动选择': true, 'Emby': true, '极简模式': false},
      'icons': icons,
      'groups': ['手动选择', 'Emby'],
    },
  });
}

void main() {
  late ProviderContainer container;

  setUp(() async {
    final home = Directory.systemTemp.createTempSync('managed_options');
    addTearDown(() {
      try {
        home.deleteSync(recursive: true);
      } on FileSystemException {
        // Windows holds the script file open a moment longer than the test.
      }
    });
    await useAppPaths(home);
    await ManagedScript.saveContent(_script);
    scriptEvaluator =
        ({required String script, required String config}) async =>
            _probeAnswer();
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles(const [])),
        viewSizeProvider.overrideWithBuild((_, _) => const Size(1000, 1200)),
      ],
    );
    globalState.container = container;
    addTearDown(container.dispose);
  });

  tearDown(() => scriptEvaluator = evaluateScript);

  void sizeView(WidgetTester tester, {Size size = const Size(1000, 1200)}) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpFrames(WidgetTester tester, {int frames = 12}) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> settle(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 40; i++) {
      if (finder.evaluate().isNotEmpty) {
        return;
      }
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
  }

  testWidgets('the switches are the ones the hosted script declares', (
    tester,
  ) async {
    sizeView(tester);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ManagedOptionsView()),
      ),
    );
    await settle(tester, find.text('Emby'));
    await tester.pumpAndSettle();

    final l10n = currentAppLocalizations;
    expect(find.text(l10n.ruleOptionsGroups), findsOne);
    expect(find.text(l10n.ruleOptionsOthers), findsOne);
    expect(find.text('手动选择'), findsOne);
    expect(find.text('Emby'), findsOne);
    expect(find.text('极简模式'), findsOne);
    expect(find.byType(CommonTargetIcon), findsOne);
    expect(find.byType(Switch), findsNWidgets(3));
    expect(tester.takeException(), null);
  });

  testWidgets('a merge editor opens the same switches', (tester) async {
    sizeView(tester, size: const Size(400, 900));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ManagedScriptSection()),
      ),
    );
    await settle(tester, find.text(currentAppLocalizations.ruleOptions));
    await pumpFrames(tester);

    await tester.tap(find.text(currentAppLocalizations.ruleOptions));
    await pumpFrames(tester);
    await settle(tester, find.text('手动选择'));
    await pumpFrames(tester);

    expect(find.byType(ManagedOptionsView), findsOne);
    expect(find.text('Emby'), findsOne);
    expect(tester.takeException(), null);
  });

  testWidgets('the page shows the switches the store holds', (tester) async {
    await tester.runAsync(() => ManagedScript.setOptions({'Emby': false}));
    container.invalidate(managedOptionsProvider);

    sizeView(tester);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ManagedOptionsView()),
      ),
    );
    await settle(tester, find.text('Emby'));
    await pumpFrames(tester);

    final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(switches, hasLength(3));
    expect(switches[0].value, isTrue);
    expect(switches[1].value, isFalse);
    expect(tester.takeException(), null);
  });

  test('an icon written into the script marks its group', () async {
    const written = '''
function main(config) { return config; }
var groups = [
  { name: "Emby", icon: "https://example.com/emby.png" },
];
''';
    scriptEvaluator =
        ({required String script, required String config}) async =>
            _probeAnswer(icons: const {});

    final declared = await extractRuleOptions(written);

    expect(declared.icons['Emby'], 'https://example.com/emby.png');
  });
}
