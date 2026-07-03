import 'package:flutter_bloc_app/core/auth/auth_user.dart';

/// Read-only contract for "who is logged in" used by router and auth gates.
///
/// Implementations are registered in DI. Consumers depend on this core
/// contract only.
abstract class AuthRepository {
  /// Current user, or null if not signed in.
  AuthUser? get currentUser;

  /// Stream of auth state changes (emits current user or null on sign out).
  Stream<AuthUser?> get authStateChanges;
}
