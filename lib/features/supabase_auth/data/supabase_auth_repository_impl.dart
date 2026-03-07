import 'package:flutter_bloc_app/core/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_user.dart'
    as app_auth;
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

/// Supabase implementation of [SupabaseAuthRepository].
class SupabaseAuthRepositoryImpl implements SupabaseAuthRepository {
  @override
  bool get isConfigured => SupabaseBootstrapService.isSupabaseInitialized;

  @override
  app_auth.AuthUser? get currentUser {
    if (!isConfigured) return null;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      return user == null ? null : _toAuthUser(user);
    } on Object catch (e, s) {
      AppLogger.error(
        'SupabaseAuthRepositoryImpl.currentUser',
        e,
        s,
      );
      return null;
    }
  }

  @override
  Stream<app_auth.AuthUser?> get authStateChanges {
    if (!isConfigured) {
      return Stream<app_auth.AuthUser?>.value(null);
    }
    return Supabase.instance.client.auth.onAuthStateChange.map((
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
      await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (e) {
      throw SupabaseAuthException(
        e.message,
        code: _mapErrorCode(e),
        cause: e,
      );
    } on Object catch (e, s) {
      AppLogger.error('SupabaseAuthRepositoryImpl.signInWithPassword', e, s);
      throw SupabaseAuthException(e.toString(), cause: e);
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
      await Supabase.instance.client.auth.signUp(
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
    } on Object catch (e, s) {
      AppLogger.error('SupabaseAuthRepositoryImpl.signUp', e, s);
      throw SupabaseAuthException(e.toString(), cause: e);
    }
  }

  @override
  Future<void> signOut() async {
    if (!isConfigured) return;
    try {
      await Supabase.instance.client.auth.signOut();
    } on Object catch (e, s) {
      AppLogger.error('SupabaseAuthRepositoryImpl.signOut', e, s);
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
}
