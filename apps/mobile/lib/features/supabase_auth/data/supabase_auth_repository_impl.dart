import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:auth/auth.dart' as app_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/app/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;
import 'package:utilities/utilities.dart';

part 'supabase_auth_repository_impl.part.dart';

/// Supabase implementation of [SupabaseAuthRepository].
class SupabaseAuthRepositoryImpl implements SupabaseAuthRepository {
  SupabaseAuthRepositoryImpl({
    this._isConfiguredOverride,
    this.tokenRepository,
    final User? Function()? readCurrentUser,
    final String? Function()? readCurrentAccessToken,
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
  }) : _readCurrentUser = readCurrentUser ?? _defaultReadCurrentUser,
       _readCurrentAccessToken =
           readCurrentAccessToken ?? _defaultReadCurrentAccessToken,
       _authStateChangesStream =
           authStateChangesStream ?? _defaultAuthStateChangesStream,
       _signInWithPasswordImpl =
           signInWithPasswordImpl ?? _defaultSignInWithPassword,
       _signUpImpl = signUpImpl ?? _defaultSignUp,
       _signOutImpl = signOutImpl ?? _defaultSignOut;

  final bool Function()? _isConfiguredOverride;
  final app_auth.TokenRepository? tokenRepository;
  final User? Function() _readCurrentUser;
  final String? Function() _readCurrentAccessToken;
  final Stream<AuthState> Function() _authStateChangesStream;
  final Future<void> Function({required String email, required String password})
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
    if (!_canAccessSupabase) return null;
    try {
      return _mapSupabaseUser(_readCurrentUser());
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
    if (!_canAccessSupabase) {
      return Stream<app_auth.AuthUser?>.value(null);
    }
    return _authStateChangesStream().map((final data) {
      if (kDebugMode) {
        AppLogger.debug(
          'Supabase auth state changed (session=${data.session != null}).',
        );
      }
      return _mapSupabaseUser(data.session?.user);
    });
  }

  @override
  Future<void> signInWithPassword({
    required final String email,
    required final String password,
  }) async {
    _requireConfigured();
    _validateCredentialInputs(email: email, password: password);
    try {
      await _signInWithPasswordImpl(email: email.trim(), password: password);
      tokenRepository?.cacheSupabaseAccessToken(_readCurrentAccessToken());
      if (kDebugMode) AppLogger.debug('Supabase sign-in complete.');
    } on AuthException catch (e) {
      throw _authExceptionFromSupabase(e);
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'SupabaseAuthRepositoryImpl.signInWithPassword',
        error,
        stackTrace,
      );
      throw _unexpectedAuthException(error);
    }
  }

  @override
  Future<void> signUp({
    required final String email,
    required final String password,
    final String? displayName,
  }) async {
    _requireConfigured();
    _validateCredentialInputs(email: email, password: password);
    try {
      await _signUpImpl(
        email: email.trim(),
        password: password,
        data: _signUpUserData(displayName),
      );
      tokenRepository?.cacheSupabaseAccessToken(_readCurrentAccessToken());
    } on AuthException catch (e) {
      throw _authExceptionFromSupabase(e);
    } on Object catch (error, stackTrace) {
      AppLogger.error('SupabaseAuthRepositoryImpl.signUp', error, stackTrace);
      throw _unexpectedAuthException(error);
    }
  }

  @override
  Future<void> signOut() async {
    if (!_canAccessSupabase) return;
    try {
      await _signOutImpl();
      tokenRepository?.clearProvider(app_auth.AuthProviderKind.supabase);
    } on Object catch (error, stackTrace) {
      AppLogger.error('SupabaseAuthRepositoryImpl.signOut', error, stackTrace);
      rethrow;
    }
  }
}
