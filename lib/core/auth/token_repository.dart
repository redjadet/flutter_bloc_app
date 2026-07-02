import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/core/auth/auth_provider_kind.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthResponse;

/// App-owned authentication token state.
///
/// SDKs remain responsible for their persistent session stores. This repository
/// keeps the app's API-call path on in-memory state and touches provider SDKs
/// only when hydrating startup/login state, refreshing, or clearing logout state.
abstract interface class TokenRepository {
  Future<void> hydrateFirebaseSession(User? user);

  Future<String?> getFirebaseAccessToken(User user);

  Future<String?> refreshFirebaseAccessToken(User user);

  void cacheSupabaseAccessToken(String? token);

  String? getSupabaseAccessToken();

  Future<String?> refreshSupabaseAccessToken({
    required Future<AuthResponse> Function() refreshSession,
    required String? Function() readPersistentAccessToken,
  });

  void clearProvider(AuthProviderKind provider);
}

class InMemoryTokenRepository implements TokenRepository {
  static const Duration _firebaseRefreshWindow = Duration(minutes: 5);

  String? _firebaseAccessToken;
  DateTime? _firebaseTokenExpiry;
  String? _firebaseUserId;

  String? _supabaseAccessToken;

  @override
  Future<void> hydrateFirebaseSession(final User? user) async {
    if (user == null) {
      clearProvider(AuthProviderKind.firebase);
      return;
    }
    await _readFirebaseTokenResult(user, forceRefresh: false);
  }

  @override
  Future<String?> getFirebaseAccessToken(final User user) async {
    final DateTime now = DateTime.now().toUtc();
    final DateTime? expiry = _firebaseTokenExpiry;
    if (_firebaseAccessToken != null &&
        expiry != null &&
        _firebaseUserId == user.uid &&
        now.isBefore(expiry.subtract(_firebaseRefreshWindow))) {
      return _firebaseAccessToken;
    }
    return _readFirebaseTokenResult(user, forceRefresh: false);
  }

  @override
  Future<String?> refreshFirebaseAccessToken(final User user) async {
    return _readFirebaseTokenResult(user, forceRefresh: true);
  }

  @override
  void cacheSupabaseAccessToken(final String? token) {
    final String? trimmed = token?.trim();
    _supabaseAccessToken = trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  @override
  String? getSupabaseAccessToken() => _supabaseAccessToken;

  @override
  Future<String?> refreshSupabaseAccessToken({
    required final Future<AuthResponse> Function() refreshSession,
    required final String? Function() readPersistentAccessToken,
  }) async {
    await refreshSession();
    final String? token = readPersistentAccessToken();
    cacheSupabaseAccessToken(token);
    return _supabaseAccessToken;
  }

  @override
  void clearProvider(final AuthProviderKind provider) {
    switch (provider) {
      case AuthProviderKind.firebase:
        _firebaseAccessToken = null;
        _firebaseTokenExpiry = null;
        _firebaseUserId = null;
      case AuthProviderKind.supabase:
        _supabaseAccessToken = null;
    }
  }

  Future<String?> _readFirebaseTokenResult(
    final User user, {
    required final bool forceRefresh,
  }) async {
    try {
      final IdTokenResult tokenResult = await user.getIdTokenResult(
        forceRefresh,
      );
      _firebaseAccessToken = tokenResult.token;
      _firebaseTokenExpiry = tokenResult.expirationTime?.toUtc();
      _firebaseUserId = user.uid;
      return _firebaseAccessToken;
    } catch (error, stackTrace) {
      clearProvider(AuthProviderKind.firebase);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
