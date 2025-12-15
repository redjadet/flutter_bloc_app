// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'test_helpers.dart' as test_helpers;

// Import waitForCounterCubitsToLoad directly
import 'test_helpers.dart' show waitForCounterCubitsToLoad;

void main() {
  setUpAll(() async {
    await test_helpers.setupHiveForTesting();
  });

  setUp(() async {
    await test_helpers.setupTestDependencies(
      const test_helpers.TestSetupOptions(
        overrideCounterRepository: true,
        setFlavorToProd: true,
      ),
    );
  });

  tearDown(() async {
    await test_helpers.tearDownTestDependencies();
  });

  testWidgets('Counter increments and decrements using Bloc', (
    WidgetTester tester,
  ) async {
    await initializeDateFormatting('en');
    await tester.pumpWidget(const MyApp(requireAuth: false));
    // Wait for initial build
    await tester.pump();
    await waitForCounterCubitsToLoad(tester);

    final Finder incrementFinder = find.widgetWithIcon(
      FloatingActionButton,
      Icons.add,
    );

    // Wait for widget to appear and loading to complete
    // In dev mode, there's a skeleton delay (1s) + Hive load time
    final Duration maxWait = const Duration(seconds: 4);
    const Duration step = Duration(milliseconds: 100);
    Duration waited = Duration.zero;

    // Wait for FAB to appear
    while (!tester.any(incrementFinder) && waited < maxWait) {
      await tester.pump(step);
      waited += step;
    }
    expect(incrementFinder, findsOneWidget);

    // Wait for loading to complete (FAB enabled)
    // Reset wait time for the second loop
    waited = Duration.zero;
    FloatingActionButton? incrementFab;
    while (waited < maxWait) {
      await tester.pump(step);
      waited += step;
      try {
        incrementFab = tester.widget<FloatingActionButton>(incrementFinder);
        if (incrementFab.onPressed != null) {
          break;
        }
      } catch (_) {
        // Widget might not be ready yet, continue waiting
      }
    }
    expect(
      incrementFab?.onPressed,
      isNotNull,
      reason: 'FAB should be enabled after repository loads',
    );

    // There may be multiple '0' texts in UI; rely on semantics by tapping FABs
    expect(find.text('0'), findsWidgets);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('1'), findsWidgets);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();

    expect(find.text('0'), findsWidgets);
  });
}
