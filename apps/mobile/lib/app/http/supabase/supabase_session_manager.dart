import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:auth/auth.dart';
import 'package:flutter_bloc_app/app/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/app/http/supabase/supabase_session_refresh_classifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Single-flight Supabase access-token refresh and session invalidation.
class SupabaseSessionManager {
  SupabaseSessionManager({
    this._sessionCoordinator,
    final TokenRepository? tokenRepository,
    Future<AuthResponse> Function()? refreshSession,
    String? Function()? readPersistentAccessToken,
    String? Function()? readAccessToken,
  }) : _refreshSession = refreshSession ?? _defaultRefreshSession,
       _readPersistentAccessToken =
           readPersistentAccessToken ??
           readAccessToken ??
           _defaultReadPersistentAccessToken,
       _tokenRepository = tokenRepository ?? InMemoryTokenRepository();

  final SessionLifecycleCoordinator? _sessionCoordinator;
  final TokenRepository _tokenRepository;
  final Future<AuthResponse> Function() _refreshSession;
  final String? Function() _readPersistentAccessToken;

  Completer<bool>? _refreshCompleter;

  /// Returns the in-memory access token, lazily re-hydrating from the SDK when
  /// memory is empty (e.g. [hydrateFromPersistentSession] ran before Supabase
  /// init or before a persisted session was restored).
  String? getAccessToken() {
    final String? cached = _tokenRepository.getSupabaseAccessToken();
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    final String? persistent = _readPersistentAccessToken();
    if (persistent == null || persistent.isEmpty) {
      return null;
    }

    _tokenRepository.cacheSupabaseAccessToken(persistent);
    return persistent;
  }

  void hydrateFromPersistentSession() {
    _tokenRepository.cacheSupabaseAccessToken(_readPersistentAccessToken());
  }

  /// Serialized refresh; returns whether a non-empty access token is available.
  Future<bool> refreshSessionSerialized() async {
    final Completer<bool>? existingCompleter = _refreshCompleter;
    if (existingCompleter != null) {
      return existingCompleter.future;
    }
    final Completer<bool> completer = Completer<bool>();
    _refreshCompleter = completer;
    try {
      final String? token = await _tokenRepository.refreshSupabaseAccessToken(
        refreshSession: _refreshSession,
        readPersistentAccessToken: _readPersistentAccessToken,
      );
      final bool success = token != null && token.isNotEmpty;
      completer.complete(success);
      return success;
    } on Object catch (error, stackTrace) {
      if (isAuthClassifiedSupabaseRefreshFailure(error)) {
        await _invalidateSupabaseSession();
      } else {
        AppLogger.error(
          'SupabaseSessionManager refresh failed (transient)',
          error,
          stackTrace,
        );
      }
      completer.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  /// One 401 recovery attempt: refresh then return the new access token.
  Future<String?> refreshAccessTokenAfterUnauthorized() async {
    final bool refreshed = await refreshSessionSerialized();
    if (!refreshed) {
      return null;
    }
    return getAccessToken();
  }

  Future<void> _invalidateSupabaseSession() async {
    final SessionLifecycleCoordinator? coordinator = _sessionCoordinator;
    if (coordinator == null) {
      return;
    }
    await coordinator.invalidateSession(
      provider: AuthProviderKind.supabase,
      reason: SessionInvalidationReason.supabaseSessionInvalid,
    );
  }
}

Future<AuthResponse> _defaultRefreshSession() =>
    Supabase.instance.client.auth.refreshSession();

String? _defaultReadPersistentAccessToken() {
  try {
    return Supabase.instance.client.auth.currentSession?.accessToken;
  } on Object {
    return null;
  }
}
