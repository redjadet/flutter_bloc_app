import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart' as core_auth;
import 'package:flutter_bloc_app/core/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/register_auth_services.dart';
import 'package:flutter_bloc_app/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_repository.dart'
    as feature_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  setUp(() async {
    FirebaseBootstrapService.isIosSimulatorInDebug = false;
    await getIt.reset(dispose: true);
  });

  tearDown(() async {
    FirebaseBootstrapService.isIosSimulatorInDebug = false;
    debugDefaultTargetPlatformOverride = null;
    await getIt.reset(dispose: true);
  });

  group('registerAuthServices', () {
    test(
      'registers the core auth contract as the same singleton as feature auth',
      () {
        getIt.registerSingleton<FirebaseAuth>(_MockFirebaseAuth());

        registerAuthServices();

        final feature_auth.AuthRepository featureRepository =
            getIt<feature_auth.AuthRepository>();
        final core_auth.AuthRepository coreRepository =
            getIt<core_auth.AuthRepository>();

        expect(featureRepository, isA<FirebaseAuthRepository>());
        expect(identical(coreRepository, featureRepository), isTrue);
      },
    );

    test('registers a safe fallback auth repository without Firebase', () {
      registerAuthServices();

      final feature_auth.AuthRepository featureRepository =
          getIt<feature_auth.AuthRepository>();
      final core_auth.AuthRepository coreRepository =
          getIt<core_auth.AuthRepository>();

      expect(featureRepository, isNot(isA<FirebaseAuthRepository>()));
      expect(identical(coreRepository, featureRepository), isTrue);
      expect(featureRepository.currentUser, isNull);
      expect(featureRepository.authStateChanges, emitsDone);
    });

    test(
      'iOS debug registers FirebaseAuthRepository without local guest wrapper',
      () {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        getIt.registerSingleton<FirebaseAuth>(_MockFirebaseAuth());

        registerAuthServices();

        final repository = getIt<feature_auth.AuthRepository>();
        expect(repository.runtimeType, FirebaseAuthRepository);
      },
    );

    test('iOS debug propagates Firebase anonymous sign-in failures', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final firebaseAuth = _MockFirebaseAuth();
      when(() => firebaseAuth.currentUser).thenReturn(null);
      when(
        () => firebaseAuth.authStateChanges(),
      ).thenAnswer((_) => const Stream<User?>.empty());
      when(() => firebaseAuth.signInAnonymously()).thenThrow(
        FirebaseAuthException(
          code: 'internal-error',
          message: 'An internal error has occurred.',
        ),
      );
      getIt.registerSingleton<FirebaseAuth>(firebaseAuth);

      registerAuthServices();

      final repository = getIt<feature_auth.AuthRepository>();

      FirebaseAuthException? caught;
      try {
        await repository.signInAnonymously();
      } on FirebaseAuthException catch (error) {
        caught = error;
      }

      expect(caught, isNotNull);
      expect(caught!.code, 'internal-error');
      expect(repository.currentUser, isNull);
    });

    test(
      'iOS simulator debug fallback creates local guest on Keychain failure',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        FirebaseBootstrapService.isIosSimulatorInDebug = true;
        final firebaseAuth = _MockFirebaseAuth();
        when(() => firebaseAuth.currentUser).thenReturn(null);
        when(
          () => firebaseAuth.authStateChanges(),
        ).thenAnswer((_) => const Stream<User?>.empty());
        when(() => firebaseAuth.signInAnonymously()).thenThrow(
          FirebaseAuthException(
            code: 'keychain-error',
            message: 'An error occurred when accessing the keychain.',
          ),
        );
        getIt.registerSingleton<FirebaseAuth>(firebaseAuth);

        registerAuthServices();

        final repository = getIt<feature_auth.AuthRepository>();
        await repository.signInAnonymously();

        expect(repository, isA<FirebaseAuthRepository>());
        expect(repository.currentUser?.id, 'ios-simulator-debug-local-guest');
        expect(repository.currentUser?.isAnonymous, isTrue);
      },
    );

    test(
      'macOS debug fallback creates local guest on Keychain failure',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        final firebaseAuth = _MockFirebaseAuth();
        when(() => firebaseAuth.currentUser).thenReturn(null);
        when(
          () => firebaseAuth.authStateChanges(),
        ).thenAnswer((_) => const Stream<User?>.empty());
        when(() => firebaseAuth.signInAnonymously()).thenThrow(
          FirebaseAuthException(
            code: 'unknown',
            message: 'SecItemAdd (-34018)',
          ),
        );
        getIt.registerSingleton<FirebaseAuth>(firebaseAuth);

        registerAuthServices();

        final repository = getIt<feature_auth.AuthRepository>();
        await repository.signInAnonymously();

        expect(repository, isA<FirebaseAuthRepository>());
        expect(repository.currentUser?.id, 'macos-debug-local-guest');
        expect(repository.currentUser?.isAnonymous, isTrue);
      },
    );

    test(
      'macOS debug fallback recognizes Firebase Auth Keychain message',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        final firebaseAuth = _MockFirebaseAuth();
        when(() => firebaseAuth.currentUser).thenReturn(null);
        when(
          () => firebaseAuth.authStateChanges(),
        ).thenAnswer((_) => const Stream<User?>.empty());
        when(() => firebaseAuth.signInAnonymously()).thenThrow(
          FirebaseAuthException(
            code: 'unknown',
            message:
                'An error occurred when accessing the keychain. The '
                'NSLocalizedFailureReasonErrorKey field in the '
                'NSError.userInfo dictionary will contain more information '
                'about the error encountered',
          ),
        );
        getIt.registerSingleton<FirebaseAuth>(firebaseAuth);

        registerAuthServices();

        final repository = getIt<feature_auth.AuthRepository>();
        await repository.signInAnonymously();

        expect(repository.currentUser?.id, 'macos-debug-local-guest');
        expect(repository.currentUser?.isAnonymous, isTrue);
      },
    );
  });
}
