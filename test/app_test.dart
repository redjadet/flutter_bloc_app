import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart' as test_helpers;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    FirebasePlatform.instance = _MockFirebasePlatform();
    await Firebase.initializeApp();
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

      // Should not throw
      expect(tester.takeException(), isNull);

      // Clean up
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('disposes auth refresh when requireAuth is true', (
      final tester,
    ) async {
      await tester.pumpWidget(const MyApp(requireAuth: true));

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      // Should not throw
      expect(tester.takeException(), isNull);
    });

    testWidgets('disposes correctly when requireAuth is false', (
      final tester,
    ) async {
      await tester.pumpWidget(const MyApp(requireAuth: false));

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      // Should not throw
      expect(tester.takeException(), isNull);
    });

    testWidgets('build returns AppScope with router', (final tester) async {
      await tester.pumpWidget(const MyApp(requireAuth: false));

      // Should render without errors
      expect(tester.takeException(), isNull);

      // Clean up by disposing the widget
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  });
}

class _MockFirebasePlatform extends FirebasePlatform {
  FirebaseOptions? _options;

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    _options = options;
    return _MockFirebaseApp(
      name ?? '[DEFAULT]',
      options ??
          const FirebaseOptions(
            apiKey: 'fake-api-key',
            appId: 'fake-app-id',
            messagingSenderId: 'fake-sender-id',
            projectId: 'fake-project-id',
          ),
    );
  }

  @override
  List<FirebaseAppPlatform> get apps => [
    _MockFirebaseApp(
      '[DEFAULT]',
      _options ??
          const FirebaseOptions(
            apiKey: 'fake-api-key',
            appId: 'fake-app-id',
            messagingSenderId: 'fake-sender-id',
            projectId: 'fake-project-id',
          ),
    ),
  ];

  @override
  FirebaseAppPlatform app([String name = '[DEFAULT]']) => _MockFirebaseApp(
    name,
    _options ??
        const FirebaseOptions(
          apiKey: 'fake-api-key',
          appId: 'fake-app-id',
          messagingSenderId: 'fake-sender-id',
          projectId: 'fake-project-id',
        ),
  );
}

class _MockFirebaseApp extends FirebaseAppPlatform {
  _MockFirebaseApp(super.name, super.options);
}
