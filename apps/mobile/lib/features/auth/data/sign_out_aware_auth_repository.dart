import 'package:auth/auth.dart' hide AuthRepository;
import 'package:flutter_bloc_app/core/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_repository.dart';

/// Decorator that runs session cleanup after explicit [signOut].
class SignOutAwareAuthRepository implements AuthRepository {
  SignOutAwareAuthRepository({
    required this._delegate,
    required this._coordinator,
  });

  final AuthRepository _delegate;
  final SessionLifecycleCoordinator _coordinator;

  /// Inner repository (for DI dispose forwarding).
  AuthRepository get delegate => _delegate;

  @override
  AuthUser? get currentUser => _delegate.currentUser;

  @override
  Stream<AuthUser?> get authStateChanges => _delegate.authStateChanges;

  @override
  Future<void> signInAnonymously() => _delegate.signInAnonymously();

  @override
  Future<void> signOut() async {
    await _delegate.signOut();
    await _coordinator.onSignOutCompleted(provider: AuthProviderKind.firebase);
  }
}
