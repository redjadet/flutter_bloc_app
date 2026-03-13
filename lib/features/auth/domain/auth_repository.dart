import 'package:flutter_bloc_app/core/auth/auth_repository.dart' as core;

/// Abstraction over authentication state and operations (extends core contract).
///
/// Implementations may wrap Firebase Auth or other providers.
/// Enables testing and decouples presentation from a specific auth SDK.
abstract class AuthRepository extends core.AuthRepository {
  /// Signs in anonymously. Throws on failure.
  Future<void> signInAnonymously();

  /// Signs out the current user.
  Future<void> signOut();
}
