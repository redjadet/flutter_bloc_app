import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart'
    as firebase_ui_google;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/features/auth/presentation/helpers/google_provider_helper.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock Firebase App for testing

class MockFirebaseApp extends FirebaseAppPlatform {
  MockFirebaseApp(super.name, super.options);
}

// Mock Firebase Platform implementation

class MockFirebasePlatform extends FirebasePlatform {
  FirebaseOptions? _options;

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    _options = options;

    return MockFirebaseApp(
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
    MockFirebaseApp(
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
  FirebaseAppPlatform app([String name = '[DEFAULT]']) {
    return MockFirebaseApp(
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

  Future<void> initializeCore() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('maybeCreateGoogleProvider', () {
    const String fakeAppId = 'fake-app-id';

    const String fakeAndroidClientId = 'fake-android-client-id';

    const String fakeIosClientId = 'fake-ios-client-id';

    setUp(() {
      FirebasePlatform.instance = MockFirebasePlatform();
    });

    test('returns null on unsupported platforms', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      await Firebase.initializeApp();

      expect(maybeCreateGoogleProvider(), isNull);

      debugDefaultTargetPlatformOverride = null;
    });

    test('returns GoogleProvider on Android with androidClientId', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'fake-api-key',

          appId: fakeAppId,

          messagingSenderId: 'fake-sender-id',

          projectId: 'fake-project-id',

          androidClientId: fakeAndroidClientId,
        ),
      );

      final provider = maybeCreateGoogleProvider();

      expect(provider, isA<firebase_ui_google.GoogleProvider>());

      expect(provider?.clientId, fakeAndroidClientId);

      debugDefaultTargetPlatformOverride = null;
    });

    test('returns GoogleProvider on iOS with iosClientId', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'fake-api-key',

          appId: fakeAppId,

          messagingSenderId: 'fake-sender-id',

          projectId: 'fake-project-id',

          iosClientId: fakeIosClientId,
        ),
      );

      final provider = maybeCreateGoogleProvider();

      expect(provider, isA<firebase_ui_google.GoogleProvider>());

      expect(provider?.clientId, fakeIosClientId);

      expect(provider?.iOSPreferPlist, isFalse);

      debugDefaultTargetPlatformOverride = null;
    });

    test('returns GoogleProvider on iOS with appId fallback', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'fake-api-key',

          appId: fakeAppId,

          messagingSenderId: 'fake-sender-id',

          projectId: 'fake-project-id',
        ),
      );

      final provider = maybeCreateGoogleProvider();

      expect(provider, isA<firebase_ui_google.GoogleProvider>());

      expect(provider?.clientId, fakeAppId);

      expect(provider?.iOSPreferPlist, isTrue);

      debugDefaultTargetPlatformOverride = null;
    });
  });
}
