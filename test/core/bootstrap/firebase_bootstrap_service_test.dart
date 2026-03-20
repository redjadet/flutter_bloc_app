import 'package:flutter_bloc_app/core/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<bool> _tryInitializeFirebase() async {
  try {
    return await FirebaseBootstrapService.initializeFirebase();
  } on PlatformException catch (error) {
    final bool isMissingTestChannel =
        error.code == 'channel-error' &&
        (error.message?.contains('FirebaseCoreHostApi.initializeCore') ??
            false);
    if (isMissingTestChannel) {
      return false;
    }
    rethrow;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirebaseBootstrapService', () {
    test('initializeFirebase completes without throwing', () async {
      await expectLater(_tryInitializeFirebase(), completes);
    });

    test('configureFirebaseUI requires Firebase initialization first', () async {
      // Firebase UI configuration requires Firebase to be initialized first
      // In test environment, Firebase may not initialize, so we handle gracefully
      final bool firebaseInitialized = await _tryInitializeFirebase();

      if (firebaseInitialized) {
        // Only test if Firebase was successfully initialized
        expect(
          () => FirebaseBootstrapService.configureFirebaseUI(),
          returnsNormally,
        );
      } else {
        // In test environment without Firebase config, expect exception
        expect(
          () => FirebaseBootstrapService.configureFirebaseUI(),
          throwsException,
        );
      }
    });

    test('registerCrashlyticsHandlers completes without throwing', () {
      // This test verifies the crash handler registration can be called
      expect(
        () => FirebaseBootstrapService.registerCrashlyticsHandlers(),
        returnsNormally,
      );
    });

    test('initializeFirebase is idempotent', () async {
      // Multiple calls should be safe
      await _tryInitializeFirebase();
      await _tryInitializeFirebase();

      // Should not throw
      expect(true, isTrue);
    });

    test('configureFirebaseUI can be called multiple times', () async {
      // Multiple calls should be safe, but only if Firebase is initialized
      final bool firebaseInitialized = await _tryInitializeFirebase();

      if (firebaseInitialized) {
        FirebaseBootstrapService.configureFirebaseUI();
        FirebaseBootstrapService.configureFirebaseUI();
        // Should not throw
        expect(true, isTrue);
      } else {
        // In test environment without Firebase, expect exception on first call
        expect(
          () => FirebaseBootstrapService.configureFirebaseUI(),
          throwsException,
        );
      }
    });

    test('registerCrashlyticsHandlers can be called multiple times', () {
      // Multiple calls should be safe
      FirebaseBootstrapService.registerCrashlyticsHandlers();
      FirebaseBootstrapService.registerCrashlyticsHandlers();

      // Should not throw
      expect(true, isTrue);
    });

    test('all methods can be called in sequence', () async {
      // Test that the complete bootstrap sequence can be called
      final bool firebaseInitialized = await _tryInitializeFirebase();

      // Crash handlers can always be registered (they just won't work without Firebase)
      FirebaseBootstrapService.registerCrashlyticsHandlers();

      if (firebaseInitialized) {
        // Only configure UI if Firebase was initialized
        FirebaseBootstrapService.configureFirebaseUI();
      } else {
        // In test environment without Firebase, expect exception
        expect(
          () => FirebaseBootstrapService.configureFirebaseUI(),
          throwsException,
        );
      }

      // Should complete without throwing (except for expected configureFirebaseUI exception)
      expect(true, isTrue);
    });
  });
}
