import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
    () {
      if (firebaseAuth == null) {
        return const _UnavailableAuthRepository();
      }
      if (_shouldUseMacOsDebugGuestFallback) {
        return _MacOsDebugGuestAuthRepository(firebaseAuth: firebaseAuth);
      }
      return FirebaseAuthRepository(firebaseAuth: firebaseAuth);
    },
    dispose: (final repository) async {
      if (repository case final _MacOsDebugGuestAuthRepository fallback) {
        await fallback.dispose();
      }
    },
  );
  registerLazySingletonIfAbsent<core_auth.AuthRepository>(
    () => getIt<AuthRepository>(),
  );
}

bool get _shouldUseMacOsDebugGuestFallback =>
    !kIsWeb && !kReleaseMode && defaultTargetPlatform == TargetPlatform.macOS;

class _MacOsDebugGuestAuthRepository extends FirebaseAuthRepository {
  _MacOsDebugGuestAuthRepository({required super.firebaseAuth}) {
    _firebaseSubscription = super.authStateChanges.listen((final user) {
      if (user != null) {
        _localGuest = null;
      }
      _authStateController.add(currentUser);
    });
  }

  final StreamController<AuthUser?> _authStateController =
      StreamController<AuthUser?>.broadcast();
  StreamSubscription<AuthUser?>? _firebaseSubscription;
  AuthUser? _localGuest;

  @override
  AuthUser? get currentUser => super.currentUser ?? _localGuest;

  @override
  Stream<AuthUser?> get authStateChanges async* {
    yield currentUser;
    yield* _authStateController.stream;
  }

  @override
  Future<void> signInAnonymously() async {
    try {
      await super.signInAnonymously();
    } on Exception catch (error) {
      if (!_looksLikeKeychainEntitlementError(error)) {
        rethrow;
      }
      _localGuest = const AuthUser(
        id: 'macos-debug-local-guest',
        isAnonymous: true,
      );
      _authStateController.add(_localGuest);
    }
  }

  @override
  Future<void> signOut() async {
    _localGuest = null;
    _authStateController.add(null);
    try {
      await super.signOut();
    } on Exception catch (error) {
      if (!_looksLikeKeychainEntitlementError(error)) {
        rethrow;
      }
    }
  }

  Future<void> dispose() async {
    await _firebaseSubscription?.cancel();
    await _authStateController.close();
  }
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

bool _looksLikeKeychainEntitlementError(final Object error) {
  final String message = error.toString().toLowerCase();
  return message.contains('-34018') ||
      message.contains('secitemadd') ||
      message.contains('keychain') ||
      message.contains('nslocalizedfailurereasonerrorkey') ||
      message.contains('required entitlement');
}
