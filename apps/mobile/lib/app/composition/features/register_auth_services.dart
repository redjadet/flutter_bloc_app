import 'package:auth/auth.dart' as core_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/app/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/app/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/app/config/backend_availability.dart';
import 'package:flutter_bloc_app/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_bloc_app/features/auth/data/guest_auth_fallback_repositories.dart';
import 'package:flutter_bloc_app/features/auth/data/sign_out_aware_auth_repository.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_repository.dart';

/// Registers auth-related services.
///
/// [FirebaseAuth] is registered so that UI that requires the Firebase Auth
/// instance (e.g. Firebase UI) can obtain it from DI. [AuthRepository]
/// provides a Flutter-agnostic abstraction for routing and business logic.
void registerAuthServices() {
  registerLazySingletonIfAbsent<SessionLifecycleCoordinator>(
    SessionLifecycleCoordinatorImpl.new,
    dispose: (final coordinator) async {
      if (coordinator is SessionLifecycleCoordinatorImpl) {
        await coordinator.dispose();
      }
    },
  );
  registerLazySingletonIfAbsent<core_auth.TokenRepository>(
    core_auth.InMemoryTokenRepository.new,
  );
  getIt<SessionLifecycleCoordinator>().bindTokenRepository(
    getIt<core_auth.TokenRepository>(),
  );

  FirebaseAuth? firebaseAuth = getIt.isRegistered<FirebaseAuth>()
      ? getIt<FirebaseAuth>()
      : null;

  if (firebaseAuth == null && FirebaseBootstrapService.isFirebaseInitialized) {
    try {
      firebaseAuth = FirebaseAuth.instance;
    } on Object {
      firebaseAuth = null;
    }
  }

  if (firebaseAuth != null) {
    final availableFirebaseAuth = firebaseAuth;
    registerLazySingletonIfAbsent<FirebaseAuth>(() => availableFirebaseAuth);
  }

  registerLazySingletonIfAbsent<AuthRepository>(
    () {
      final AuthRepository inner = _createInnerAuthRepository(
        firebaseAuth: firebaseAuth,
      );
      final SessionLifecycleCoordinator coordinator =
          getIt<SessionLifecycleCoordinator>()
            // Attach the undecorated stream first so cleanup can gate
            // publication without deadlocking on session-ready auth changes.
            ..attachAuthRepository(inner);
      return SignOutAwareAuthRepository(
        delegate: inner,
        coordinator: coordinator,
      );
    },
    dispose: (final repository) async {
      final AuthRepository inner = repository is SignOutAwareAuthRepository
          ? repository.delegate
          : repository;
      switch (inner) {
        case final DebugKeychainGuestAuthRepository fallback:
          await fallback.dispose();
        case final LocalGuestOnlyAuthRepository localOnly:
          await localOnly.dispose();
        default:
          break;
      }
    },
  );
  registerLazySingletonIfAbsent<core_auth.AuthRepository>(
    () => getIt<AuthRepository>(),
  );
}

AuthRepository _createInnerAuthRepository({
  required final FirebaseAuth? firebaseAuth,
}) {
  if (firebaseAuth == null) {
    final bool allowWebLocalGuestAuth =
        getIt.isRegistered<BackendAvailability>() &&
        getIt<BackendAvailability>().allowWebLocalGuestAuth;
    if (allowWebLocalGuestAuth) {
      return LocalGuestOnlyAuthRepository(
        localGuestIdOverride: 'web-local-guest',
      );
    }
    if (FirebaseBootstrapService.supportsDebugLocalGuestAuth) {
      return LocalGuestOnlyAuthRepository();
    }
    return const UnavailableAuthRepository();
  }
  if (_shouldUseDebugKeychainGuestFallback) {
    return DebugKeychainGuestAuthRepository(firebaseAuth: firebaseAuth);
  }
  return FirebaseAuthRepository(firebaseAuth: firebaseAuth);
}

bool get _shouldUseDebugKeychainGuestFallback {
  if (kIsWeb || kReleaseMode) {
    return false;
  }
  if (defaultTargetPlatform == TargetPlatform.macOS) {
    return true;
  }
  return defaultTargetPlatform == TargetPlatform.iOS &&
      FirebaseBootstrapService.isIosSimulatorInDebug;
}
