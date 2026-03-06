import 'package:flutter_bloc_app/features/auth/domain/auth_user.dart';

/// Abstraction over authentication state and operations.
///
/// Implementations may wrap Firebase Auth or other providers.
/// Enables testing and decouples presentation from a specific auth SDK.
abstract class AuthRepository {
  /// Current user, or null if not signed in.
  AuthUser? get currentUser;

  /// Stream of auth state changes (emits current user or null on sign out).
  Stream<AuthUser?> get authStateChanges;

  /// Signs in anonymously. Throws on failure.
  Future<void> signInAnonymously();

  /// Signs out the current user.
  Future<void> signOut();
}
