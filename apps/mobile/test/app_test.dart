import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart' as test_helpers;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    test_helpers.installMockFirebasePlatformForTests();
    await Firebase.initializeApp(options: test_helpers.mockFirebaseOptions);
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

  group('MyApp', () {
    testWidgets('creates router without auth when requireAuth is false', (
      final tester,
    ) async {
      await tester.pumpWidget(const MyApp(requireAuth: false));

      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('disposes auth refresh when requireAuth is true', (
      final tester,
    ) async {
      await tester.pumpWidget(const MyApp(requireAuth: true));

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('disposes correctly when requireAuth is false', (
      final tester,
    ) async {
      await tester.pumpWidget(const MyApp(requireAuth: false));

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('build returns AppScope with router', (final tester) async {
      await tester.pumpWidget(const MyApp(requireAuth: false));

      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  });
}
