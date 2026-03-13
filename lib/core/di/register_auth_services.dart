import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart' as core_auth;
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
  registerLazySingletonIfAbsent<FirebaseAuth>(() => FirebaseAuth.instance);
  registerLazySingletonIfAbsent<AuthRepository>(
    () => FirebaseAuthRepository(firebaseAuth: getIt<FirebaseAuth>()),
  );
  registerLazySingletonIfAbsent<core_auth.AuthRepository>(
    () => getIt<AuthRepository>(),
  );
}
