import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/app/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_helpers_firebase.dart';

const FirebaseOptions _testOptions = FirebaseOptions(
  apiKey: 'test-api-key',
  appId: '1:1234567890:android:abcdef',
  messagingSenderId: '1234567890',
  projectId: 'test-project-id',
  storageBucket: 'test-project-id.appspot.com',
  databaseURL: 'https://test-project-id.firebaseio.com',
  androidClientId: 'android-client-id',
  iosClientId: 'ios-client-id',
);

void _installFirebasePluginChannelMocks() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  Future<Object?> handler(final MethodCall call) async {
    // Tolerate both method-channel and pigeon-style invocations.
    return null;
  }

  for (final String channel in <String>[
    'plugins.flutter.io/firebase_app_check',
    'plugins.flutter.io/firebase_database',
    'plugins.flutter.io/firebase_crashlytics',
    'dev.flutter.pigeon.firebase_database_platform_interface.FirebaseDatabaseHostApi',
    'dev.flutter.pigeon.FAKESECRET_u2v3w4x5y6z7a8b9c0d1',
  ]) {
    messenger.setMockMethodCallHandler(MethodChannel(channel), handler);
  }

  messenger.setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/device_info'),
    (final MethodCall call) async {
      // Incomplete map forces fromMap to throw; ensureIosSimulatorDebugFlag
      // must stay best-effort and leave the flag false.
      return <String, dynamic>{};
    },
  );
}

void _clearFirebasePluginChannelMocks() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  for (final String channel in <String>[
    'plugins.flutter.io/firebase_app_check',
    'plugins.flutter.io/firebase_database',
    'plugins.flutter.io/firebase_crashlytics',
    'dev.flutter.pigeon.firebase_database_platform_interface.FirebaseDatabaseHostApi',
    'dev.flutter.pigeon.FAKESECRET_u2v3w4x5y6z7a8b9c0d1',
    'dev.fluttercommunity.plus/device_info',
  ]) {
    messenger.setMockMethodCallHandler(MethodChannel(channel), null);
  }
}

Future<void> _settleAsyncSideEffects() async {
  await Future<void>.delayed(const Duration(milliseconds: 50));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    _installFirebasePluginChannelMocks();
  });

  tearDownAll(() {
    _clearFirebasePluginChannelMocks();
    resetFirebaseTestDelegate();
  });

  setUp(() {
    installMockFirebasePlatformForTests(seedDefaultApp: false);
    FirebaseBootstrapService.resetInitializationForTest();
    FirebaseBootstrapService.resetIosSimulatorInDebugForTest();
  });

  tearDown(() async {
    debugDefaultTargetPlatformOverride = null;
    FirebaseBootstrapService.resetInitializationForTest();
    FirebaseBootstrapService.resetIosSimulatorInDebugForTest();
    await _settleAsyncSideEffects();
  });

  group('FirebaseBootstrapService', () {
    test('isFirebaseInitialized reflects Firebase.apps state', () {
      expect(FirebaseBootstrapService.isFirebaseInitialized, isFalse);
    });

    test('supportsDebugLocalGuestAuth is false in release test binding', () {
      expect(FirebaseBootstrapService.supportsDebugLocalGuestAuth, isFalse);
    });

    test('supportsDebugLocalGuestAuth is true on macOS debug', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(FirebaseBootstrapService.supportsDebugLocalGuestAuth, isTrue);
    });

    test('supportsDebugLocalGuestAuth is true on iOS simulator debug', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      FirebaseBootstrapService.isIosSimulatorInDebug = true;
      expect(FirebaseBootstrapService.supportsDebugLocalGuestAuth, isTrue);
    });

    test('supportsDebugLocalGuestAuth is true on Android emulator debug', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      FirebaseBootstrapService.isAndroidEmulatorInDebug = true;
      expect(FirebaseBootstrapService.supportsDebugLocalGuestAuth, isTrue);
    });

    test('configureFirebaseUI is safe when Firebase is not initialized', () {
      expect(FirebaseBootstrapService.isFirebaseInitialized, isFalse);
      FirebaseBootstrapService.configureFirebaseUI();
    });

    test('initializeFirebase skips unsupported desktop platforms', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      final initialized = await FirebaseBootstrapService.initializeFirebase();
      expect(initialized, isFalse);
    });

    test('ensureIosSimulatorDebugFlag is safe on non-iOS platforms', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      await FirebaseBootstrapService.ensureIosSimulatorDebugFlag();
      expect(FirebaseBootstrapService.isIosSimulatorInDebug, isFalse);
      expect(FirebaseBootstrapService.isAndroidEmulatorInDebug, isFalse);
    });

    test('initializeFirebase uses debug options override on android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      FirebaseBootstrapService.debugOptionsOverride = _testOptions;

      final bool initialized =
          await FirebaseBootstrapService.initializeFirebase();
      expect(initialized, isTrue);
      expect(FirebaseBootstrapService.isFirebaseInitialized, isTrue);
      await _settleAsyncSideEffects();

      final bool reused = await FirebaseBootstrapService.initializeFirebase();
      expect(reused, isTrue);
      await _settleAsyncSideEffects();
    });

    test(
      'initializeFirebase uses debug options override on iOS simulator',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        // Pre-mark simulator so App Check skip path is deterministic without a
        // full device_info_plus map.
        FirebaseBootstrapService.isIosSimulatorInDebug = true;
        FirebaseBootstrapService.debugOptionsOverride = _testOptions;

        final bool initialized =
            await FirebaseBootstrapService.initializeFirebase();
        expect(initialized, isTrue);
        expect(FirebaseBootstrapService.isIosSimulatorInDebug, isTrue);
        await _settleAsyncSideEffects();
      },
    );

    test('initializeFirebase uses debug options override on macOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      FirebaseBootstrapService.debugOptionsOverride = _testOptions;

      final bool initialized =
          await FirebaseBootstrapService.initializeFirebase();
      expect(initialized, isTrue);
      await _settleAsyncSideEffects();
    });

    test('configureFirebaseUI configures providers when initialized', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      FirebaseBootstrapService.debugOptionsOverride = _testOptions;
      await FirebaseBootstrapService.initializeFirebase();
      await _settleAsyncSideEffects();

      expect(
        () => FirebaseBootstrapService.configureFirebaseUI(),
        returnsNormally,
      );
    });

    test('registerCrashlyticsHandlers installs handlers', () {
      final previous = FlutterError.onError;
      FirebaseBootstrapService.registerCrashlyticsHandlers();
      expect(FlutterError.onError, isNotNull);
      FlutterError.onError = previous;
    });

    test(
      'initializeFirebase skips when required config fields are placeholders',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        FirebaseBootstrapService.debugOptionsOverride = const FirebaseOptions(
          apiKey: 'YOUR_ANDROID_API_KEY',
          appId: '1:000000000000:android:placeholder',
          messagingSenderId: '000000000000',
          projectId: 'your-project-id',
          storageBucket: 'your-project-id.appspot.com',
        );

        final bool initialized =
            await FirebaseBootstrapService.initializeFirebase();
        expect(initialized, isFalse);
      },
    );

    test(
      'ensureIosSimulatorDebugFlag tolerates device_info failures on iOS',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        await FirebaseBootstrapService.ensureIosSimulatorDebugFlag();
        expect(FirebaseBootstrapService.isIosSimulatorInDebug, isFalse);
      },
    );
  });
}
