// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app.dart';
import 'package:flutter_bloc_app/core/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Counter increments and decrements using Bloc', (
    WidgetTester tester,
  ) async {
    await initializeDateFormatting('en');
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    final Finder incrementFinder = find.widgetWithIcon(
      FloatingActionButton,
      Icons.add,
    );
    FloatingActionButton incrementFab = tester.widget<FloatingActionButton>(
      incrementFinder,
    );
    if (incrementFab.onPressed == null) {
      // Wait for repository load to finish and enable the controls.
      final Duration maxWait =
          AppConstants.devSkeletonDelay + const Duration(milliseconds: 400);
      const Duration step = Duration(milliseconds: 100);
      Duration waited = Duration.zero;
      while (incrementFab.onPressed == null && waited < maxWait) {
        await tester.pump(step);
        waited += step;
        incrementFab = tester.widget<FloatingActionButton>(incrementFinder);
      }
    }
    expect(incrementFab.onPressed, isNotNull);

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
