import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(initializeIntegrationTestHarness);

  setUp(() async {
    await configureIntegrationTestDependencies(
      overrideCounterRepository: false,
    );
  });

  tearDown(() async {
    await tearDownIntegrationTestDependencies();
  });

  group('Counter persistence', () {
    testWidgets('restores the saved count after rebuilding the app', (
      final tester,
    ) async {
      await launchTestApp(tester);

      final Finder incrementButton = find.widgetWithIcon(
        FloatingActionButton,
        Icons.add,
      );

      await tester.tap(incrementButton);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(incrementButton);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('2'), findsWidgets);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      await tearDownIntegrationTestDependencies();
      await configureIntegrationTestDependencies(
        overrideCounterRepository: false,
      );
      await launchTestApp(tester);

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('2'), findsWidgets);
    });
  });
}
