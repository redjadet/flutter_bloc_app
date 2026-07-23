import 'package:auth/auth.dart' as core_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/app/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/app/composition/features/register_auth_services.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/config/backend_availability.dart';
import 'package:flutter_bloc_app/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_bloc_app/features/auth/data/guest_auth_fallback_repositories.dart';
import 'package:flutter_bloc_app/features/auth/data/sign_out_aware_auth_repository.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_repository.dart'
    as feature_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

void _stubFirebaseAuthStreams(final FirebaseAuth firebaseAuth) {
  when(() => firebaseAuth.currentUser).thenReturn(null);
  when(
    () => firebaseAuth.authStateChanges(),
  ).thenAnswer((_) => const Stream<User?>.empty());
}

feature_auth.AuthRepository _unwrapAuthRepository(
  final feature_auth.AuthRepository repository,
) {
  if (repository is SignOutAwareAuthRepository) {
    return repository.delegate;
  }
  return repository;
}

void main() {
  setUp(() async {
    FirebaseBootstrapService.isIosSimulatorInDebug = false;
    FirebaseBootstrapService.isAndroidEmulatorInDebug = false;
    await getIt.reset(dispose: true);
  });

  tearDown(() async {
    FirebaseBootstrapService.isIosSimulatorInDebug = false;
    FirebaseBootstrapService.isAndroidEmulatorInDebug = false;
    debugDefaultTargetPlatformOverride = null;
    await getIt.reset(dispose: true);
  });

  group('registerAuthServices', () {
    test(
      'registers the core auth contract as the same singleton as feature auth',
      () {
        final firebaseAuth = _MockFirebaseAuth();
        _stubFirebaseAuthStreams(firebaseAuth);
        getIt.registerSingleton<FirebaseAuth>(firebaseAuth);

        registerAuthServices();

        final feature_auth.AuthRepository featureRepository =
            getIt<feature_auth.AuthRepository>();
        final core_auth.AuthRepository coreRepository =
            getIt<core_auth.AuthRepository>();

        expect(featureRepository, isA<SignOutAwareAuthRepository>());
        expect(
          _unwrapAuthRepository(featureRepository),
          isA<FirebaseAuthRepository>(),
        );
        expect(identical(coreRepository, featureRepository), isTrue);
      },
    );

    test('registers a safe fallback auth repository without Firebase', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      registerAuthServices();

      final feature_auth.AuthRepository featureRepository =
          getIt<feature_auth.AuthRepository>();
      final core_auth.AuthRepository coreRepository =
          getIt<core_auth.AuthRepository>();

      expect(featureRepository, isNot(isA<FirebaseAuthRepository>()));
      expect(
        _unwrapAuthRepository(featureRepository),
        isA<UnavailableAuthRepository>(),
      );
      expect(identical(coreRepository, featureRepository), isTrue);
      expect(featureRepository.currentUser, isNull);
      // Gated session-ready stream seeds currentUser (null) and stays open.
      expect(featureRepository.authStateChanges, emits(null));
    });

    test(
      'does not enable local guest auth when web no-backend mode is false',
      () async {
        getIt.registerSingleton<BackendAvailability>(
          const BackendAvailability(
            firebaseInitialized: false,
            supabaseInitialized: false,
            webNoBackendMode: false,
            allowWebLocalGuestAuth: false,
            allowLocalChatFallback: false,
          ),
        );

        registerAuthServices();

        final repository = getIt<feature_auth.AuthRepository>();
        await repository.signInAnonymously();

        expect(repository, isNot(isA<FirebaseAuthRepository>()));
        expect(repository.currentUser, isNull);
        expect(
          _unwrapAuthRepository(repository),
          isA<UnavailableAuthRepository>(),
        );
      },
    );

    test(
      'uses local guest auth when web no-backend policy is enabled',
      () async {
        getIt.registerSingleton<BackendAvailability>(
          const BackendAvailability(
            firebaseInitialized: false,
            supabaseInitialized: false,
            webNoBackendMode: true,
            allowWebLocalGuestAuth: true,
            allowLocalChatFallback: true,
          ),
        );

        registerAuthServices();

        final repository = getIt<feature_auth.AuthRepository>();
        await repository.signInAnonymously();

        expect(repository, isNot(isA<FirebaseAuthRepository>()));
        expect(
          _unwrapAuthRepository(repository),
          isA<LocalGuestOnlyAuthRepository>(),
        );
        expect(repository.currentUser?.id, 'web-local-guest');
        expect(repository.currentUser?.isAnonymous, isTrue);
      },
    );

    test(
      'iOS simulator debug without Firebase uses local-only guest repository',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        FirebaseBootstrapService.isIosSimulatorInDebug = true;

        registerAuthServices();

        final repository = getIt<feature_auth.AuthRepository>();
        expect(repository, isNot(isA<FirebaseAuthRepository>()));
        expect(
          _unwrapAuthRepository(repository),
          isA<LocalGuestOnlyAuthRepository>(),
        );

        await repository.signInAnonymously();
        expect(repository.currentUser?.id, 'ios-simulator-debug-local-guest');
        expect(repository.currentUser?.isAnonymous, isTrue);
      },
    );

    test(
      'iOS debug registers FirebaseAuthRepository without local guest wrapper',
      () {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        final firebaseAuth = _MockFirebaseAuth();
        _stubFirebaseAuthStreams(firebaseAuth);
        getIt.registerSingleton<FirebaseAuth>(firebaseAuth);

        registerAuthServices();

        final feature_auth.AuthRepository repository =
            getIt<feature_auth.AuthRepository>();
        expect(repository, isA<SignOutAwareAuthRepository>());
        expect(
          _unwrapAuthRepository(repository),
          isA<FirebaseAuthRepository>(),
        );
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

        expect(
          _unwrapAuthRepository(repository),
          isA<DebugKeychainGuestAuthRepository>(),
        );
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

        expect(
          _unwrapAuthRepository(repository),
          isA<DebugKeychainGuestAuthRepository>(),
        );
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
