import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart' as core_auth;
import 'package:flutter_bloc_app/core/auth/auth_user.dart';
import 'package:flutter_bloc_app/core/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_repository.dart';

/// Registers auth-related services.
///
/// [FirebaseAuth] is registered so that UI that requires the Firebase Auth
/// instance (e.g. Firebase UI) can obtain it from DI. [AuthRepository]
/// provides a Flutter-agnostic abstraction for routing and business logic.
void registerAuthServices() {
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
    () => firebaseAuth == null
        ? const _UnavailableAuthRepository()
        : FirebaseAuthRepository(firebaseAuth: firebaseAuth),
  );
  registerLazySingletonIfAbsent<core_auth.AuthRepository>(
    () => getIt<AuthRepository>(),
  );
}

class _UnavailableAuthRepository implements AuthRepository {
  const _UnavailableAuthRepository();

  @override
  AuthUser? get currentUser => null;

  @override
  Stream<AuthUser?> get authStateChanges => const Stream<AuthUser?>.empty();

  @override
  Future<void> signInAnonymously() async {}

  @override
  Future<void> signOut() async {}
}
