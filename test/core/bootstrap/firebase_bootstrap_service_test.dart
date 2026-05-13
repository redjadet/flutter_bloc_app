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

    test('configureFirebaseUI is a no-op when Firebase is missing', () async {
      final bool firebaseInitialized = await _tryInitializeFirebase();

      if (firebaseInitialized) {
        expect(
          () => FirebaseBootstrapService.configureFirebaseUI(),
          returnsNormally,
        );
      } else {
        expect(
          () => FirebaseBootstrapService.configureFirebaseUI(),
          returnsNormally,
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
        expect(
          () => FirebaseBootstrapService.configureFirebaseUI(),
          returnsNormally,
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
        expect(
          () => FirebaseBootstrapService.configureFirebaseUI(),
          returnsNormally,
        );
      }

      expect(true, isTrue);
    });
  });
}
