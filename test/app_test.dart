import 'dart:io';

import 'package:flutter_bloc_app/app.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/counter/presentation/pages/counter_page.dart';
import 'package:flutter_bloc_app/shared/storage/shared_preferences_migration_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize Hive for testing
    final Directory testDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(testDir.path);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await getIt.reset(dispose: true);
    await configureDependencies();
    // Run migration to avoid delays during widget test
    await getIt<SharedPreferencesMigrationService>().migrateIfNeeded();
  });

  tearDown(() async {
    await getIt.reset(dispose: true);
  });

  testWidgets('MyApp renders counter page when auth not required', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp(requireAuth: false));
    // Wait for initial build and async operations
    await tester.pump();
    // Allow time for cubits to initialize
    await tester.pump(const Duration(milliseconds: 100));
    // Wait for any pending timers/async operations
    await tester.pump(const Duration(seconds: 1));
    // Check without waiting for all animations to settle
    expect(find.byType(CounterPage), findsOneWidget);
  });
}
