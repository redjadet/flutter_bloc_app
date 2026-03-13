import 'package:flutter_bloc_app/core/auth/auth_user.dart' as app_auth;
import 'package:flutter_bloc_app/core/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

/// Supabase implementation of [SupabaseAuthRepository].
class SupabaseAuthRepositoryImpl implements SupabaseAuthRepository {
  SupabaseAuthRepositoryImpl({
    final bool Function()? isConfiguredOverride,
    final User? Function()? readCurrentUser,
    final Stream<AuthState> Function()? authStateChangesStream,
    final Future<void> Function({
      required String email,
      required String password,
    })?
    signInWithPasswordImpl,
    final Future<void> Function({
      required String email,
      required String password,
      Map<String, dynamic>? data,
    })?
    signUpImpl,
    final Future<void> Function()? signOutImpl,
  }) : _isConfiguredOverride = isConfiguredOverride,
       _readCurrentUser = readCurrentUser ?? _defaultReadCurrentUser,
       _authStateChangesStream =
           authStateChangesStream ?? _defaultAuthStateChangesStream,
       _signInWithPasswordImpl =
           signInWithPasswordImpl ?? _defaultSignInWithPassword,
       _signUpImpl = signUpImpl ?? _defaultSignUp,
       _signOutImpl = signOutImpl ?? _defaultSignOut;

  final bool Function()? _isConfiguredOverride;
  final User? Function() _readCurrentUser;
  final Stream<AuthState> Function() _authStateChangesStream;
  final Future<void> Function({
    required String email,
    required String password,
  })
  _signInWithPasswordImpl;
  final Future<void> Function({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  })
  _signUpImpl;
  final Future<void> Function() _signOutImpl;

  @override
  bool get isConfigured =>
      _isConfiguredOverride?.call() ??
      SupabaseBootstrapService.isSupabaseInitialized;

  @override
  app_auth.AuthUser? get currentUser {
    if (!isConfigured) return null;
    try {
      final user = _readCurrentUser();
      return user == null ? null : _toAuthUser(user);
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'SupabaseAuthRepositoryImpl.currentUser',
        error,
        stackTrace,
      );
      return null;
    }
  }

  @override
  Stream<app_auth.AuthUser?> get authStateChanges {
    if (!isConfigured) {
      return Stream<app_auth.AuthUser?>.value(null);
    }
    return _authStateChangesStream().map((
      final data,
    ) {
      final user = data.session?.user;
      return user == null ? null : _toAuthUser(user);
    });
  }

  @override
  Future<void> signInWithPassword({
    required final String email,
    required final String password,
  }) async {
    if (!isConfigured) {
      throw const SupabaseAuthException(
        'Supabase is not configured (missing URL or anon key).',
      );
    }
    try {
      await _signInWithPasswordImpl(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (e) {
      throw SupabaseAuthException(
        e.message,
        code: _mapErrorCode(e),
        cause: e,
      );
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'SupabaseAuthRepositoryImpl.signInWithPassword',
        error,
        stackTrace,
      );
      throw SupabaseAuthException(error.toString(), cause: error);
    }
  }

  @override
  Future<void> signUp({
    required final String email,
    required final String password,
    final String? displayName,
  }) async {
    if (!isConfigured) {
      throw const SupabaseAuthException(
        'Supabase is not configured (missing URL or anon key).',
      );
    }
    try {
      await _signUpImpl(
        email: email.trim(),
        password: password,
        data: displayName != null && displayName.trim().isNotEmpty
            ? <String, dynamic>{'full_name': displayName.trim()}
            : null,
      );
    } on AuthException catch (e) {
      throw SupabaseAuthException(
        e.message,
        code: _mapErrorCode(e),
        cause: e,
      );
    } on Object catch (error, stackTrace) {
      AppLogger.error('SupabaseAuthRepositoryImpl.signUp', error, stackTrace);
      throw SupabaseAuthException(error.toString(), cause: error);
    }
  }

  @override
  Future<void> signOut() async {
    if (!isConfigured) return;
    try {
      await _signOutImpl();
    } on Object catch (error, stackTrace) {
      AppLogger.error('SupabaseAuthRepositoryImpl.signOut', error, stackTrace);
      rethrow;
    }
  }

  static app_auth.AuthUser _toAuthUser(final User user) {
    final meta = user.userMetadata;
    final String? displayName = switch (meta) {
      final Map<dynamic, dynamic> values => stringFromDynamic(
        values['full_name'],
      )?.trim(),
      _ => null,
    };
    return app_auth.AuthUser(
      id: user.id,
      email: user.email?.trim(),
      displayName: displayName?.isEmpty ?? true ? null : displayName,
      isAnonymous: false,
    );
  }

  static SupabaseAuthErrorCode? _mapErrorCode(final AuthException error) {
    if (error is AuthRetryableFetchException || error.statusCode == null) {
      return SupabaseAuthErrorCode.network;
    }

    final String normalizedMessage = error.message.trim().toLowerCase();
    if (normalizedMessage.contains('invalid login credentials') ||
        normalizedMessage.contains('invalid email or password')) {
      return SupabaseAuthErrorCode.invalidCredentials;
    }

    if (normalizedMessage.contains('failed host lookup') ||
        normalizedMessage.contains('socketexception') ||
        normalizedMessage.contains('network')) {
      return SupabaseAuthErrorCode.network;
    }

    if (normalizedMessage.contains('password should be') ||
        normalizedMessage.contains('at least 6 characters')) {
      return SupabaseAuthErrorCode.weakPassword;
    }

    if (normalizedMessage.contains('validate email') ||
        (normalizedMessage.contains('invalid format') &&
            normalizedMessage.contains('email'))) {
      return SupabaseAuthErrorCode.invalidEmail;
    }

    if (normalizedMessage.contains('already registered') ||
        normalizedMessage.contains('user already exists') ||
        normalizedMessage.contains('email already in use')) {
      return SupabaseAuthErrorCode.userAlreadyExists;
    }

    return null;
  }

  static User? _defaultReadCurrentUser() =>
      Supabase.instance.client.auth.currentUser;

  static Stream<AuthState> _defaultAuthStateChangesStream() =>
      Supabase.instance.client.auth.onAuthStateChange;

  static Future<void> _defaultSignInWithPassword({
    required final String email,
    required final String password,
  }) {
    return Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> _defaultSignUp({
    required final String email,
    required final String password,
    final Map<String, dynamic>? data,
  }) {
    return Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  static Future<void> _defaultSignOut() =>
      Supabase.instance.client.auth.signOut();
}
