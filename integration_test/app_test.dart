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

  group('App launch', () {
    testWidgets('launches to the counter page and updates the count', (
      final tester,
    ) async {
      await launchTestApp(tester);

      expect(find.text('Home Page'), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
      await pumpUntilFound(tester, find.text('0'));
      expect(find.text('0'), findsWidgets);

      await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.add));
      await pumpUntilFound(tester, find.text('1'));
      expect(find.text('1'), findsWidgets);

      await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.remove));
      await pumpUntilFound(tester, find.text('0'));
      expect(find.text('0'), findsWidgets);
    });
  });
}
