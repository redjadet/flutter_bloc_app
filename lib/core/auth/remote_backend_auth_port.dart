import 'package:flutter_bloc_app/core/auth/auth_user.dart';

/// Read-only Supabase (or similar remote backend) auth surface for cross-feature use.
///
/// Feature modules depend on this core port instead of [SupabaseAuthRepository].
abstract class RemoteBackendAuthPort {
  /// Whether the remote backend was initialized (URL and credentials configured).
  bool get isConfigured;

  /// Current remote-backend user, or null if not signed in.
  AuthUser? get currentUser;

  /// Stream of remote-backend auth state changes.
  Stream<AuthUser?> get authStateChanges;

  /// Signs out the current remote-backend user.
  Future<void> signOut();
}
