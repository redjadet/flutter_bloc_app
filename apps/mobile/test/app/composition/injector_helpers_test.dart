import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/app/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('createRemoteRepositoryOrNull', () {
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      integrationTestOmitFirebaseRemoteRepositories = false;
      FirebaseBootstrapService.isIosSimulatorInDebug = false;
      FirebaseBootstrapService.isAndroidEmulatorInDebug = false;
    });

    test('skips Firebase remote repositories on macOS desktop debug', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      final Object? repository = createRemoteRepositoryOrNull<Object>(
        context: 'test repository',
        factory: () => Object(),
      );

      expect(shouldSkipFirebaseRemoteRepositories, isTrue);
      expect(repository, isNull);
    });

    test('skips Firebase remote repositories on iOS simulator debug', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      FirebaseBootstrapService.isIosSimulatorInDebug = true;

      final Object? repository = createRemoteRepositoryOrNull<Object>(
        context: 'test repository',
        factory: () => Object(),
      );

      expect(shouldSkipFirebaseRemoteRepositories, isTrue);
      expect(repository, isNull);
    });

    test('does not skip iOS debug remotes on physical device by default', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      expect(shouldSkipFirebaseRemoteRepositories, isFalse);
    });

    test('honors integration harness RTDB omit flag only when set', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      integrationTestOmitFirebaseRemoteRepositories = true;

      expect(shouldSkipFirebaseRemoteRepositories, isTrue);
    });
  });
}
