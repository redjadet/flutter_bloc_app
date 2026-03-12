import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(initializeIntegrationTestHarness);

  setUp(() async {
    await configureIntegrationTestDependencies();
  });

  tearDown(() async {
    await tearDownIntegrationTestDependencies();
  });

  group('Settings flow', () {
    testWidgets('opens settings and applies theme and locale changes', (
      final tester,
    ) async {
      await launchTestApp(tester);

      await pumpUntilFound(tester, find.byTooltip('Open settings'));
      await tester.tap(find.byTooltip('Open settings'));
      await pumpUntilFound(tester, find.text('Settings'));

      expect(find.text('Settings'), findsWidgets);

      await tester.tap(find.text('Dark'));
      await tester.pump(const Duration(milliseconds: 200));

      MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);

      await tester.scrollUntilVisible(
        find.text('Español'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Español'));
      await pumpUntilFound(tester, find.text('Configuración'));

      app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
      expect(find.text('Configuración'), findsWidgets);
    });
  });
}
