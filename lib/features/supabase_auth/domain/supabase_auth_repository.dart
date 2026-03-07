import 'package:flutter_bloc_app/features/auth/domain/auth_user.dart';

/// Abstraction over Supabase authentication state and operations.
///
/// Enables testing and decouples presentation from the Supabase SDK.
///
/// **Access from other code:** This repository is registered as a singleton in
/// DI (`register_supabase_services.dart`). Any code that has access to the app
/// injector can read the current Supabase user and listen to auth changes:
/// ```dart
/// final repo = getIt<SupabaseAuthRepository>();
/// final AuthUser? user = repo.currentUser;       // null if not signed in
/// repo.authStateChanges.listen(
///   (user) { ... },
///   onError: (Object error, StackTrace stackTrace) { ... },
/// );  // react to sign-in/out
/// ```
/// Use [currentUser] for one-off checks; use [authStateChanges] for reactive
/// flows (e.g. UI that updates when the user signs in or out).
abstract class SupabaseAuthRepository {
  /// Whether Supabase was initialized (URL and anon key configured).
  bool get isConfigured;

  /// Current user, or null if not signed in.
  AuthUser? get currentUser;

  /// Stream of auth state changes (emits current user or null on sign out).
  Stream<AuthUser?> get authStateChanges;

  /// Signs in with email and password. Throws [SupabaseAuthException] on failure.
  Future<void> signInWithPassword({
    required final String email,
    required final String password,
  });

  /// Signs up with email, password, and optional display name.
  /// Throws [SupabaseAuthException] on failure.
  Future<void> signUp({
    required final String email,
    required final String password,
    final String? displayName,
  });

  /// Signs out the current user.
  Future<void> signOut();
}

enum SupabaseAuthErrorCode {
  invalidCredentials,
  invalidEmail,
  network,
  userAlreadyExists,
  weakPassword,
}

/// Exception thrown by Supabase auth operations.
class SupabaseAuthException implements Exception {
  const SupabaseAuthException(this.message, {this.code, this.cause});

  final String message;
  final SupabaseAuthErrorCode? code;
  final Object? cause;

  @override
  String toString() =>
      'SupabaseAuthException: $message'
      '${cause != null ? ' (caused by: $cause)' : ''}';
}
