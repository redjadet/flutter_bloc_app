import 'dart:async';

import 'package:flutter_bloc_app/core/auth/auth_provider_kind.dart';
import 'package:flutter_bloc_app/core/auth/session_invalidation_reason.dart';
import 'package:flutter_bloc_app/core/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/shared/http/supabase_session_refresh_classifier.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Single-flight Supabase access-token refresh and session invalidation.
class SupabaseSessionManager {
  SupabaseSessionManager({
    this._sessionCoordinator,
    Future<AuthResponse> Function()? refreshSession,
    String? Function()? readAccessToken,
  }) : _refreshSession = refreshSession ?? _defaultRefreshSession,
       _readAccessToken = readAccessToken ?? _defaultReadAccessToken;

  final SessionLifecycleCoordinator? _sessionCoordinator;
  final Future<AuthResponse> Function() _refreshSession;
  final String? Function() _readAccessToken;

  Completer<bool>? _refreshCompleter;

  String? getAccessToken() => _readAccessToken();

  /// Serialized refresh; returns whether a non-empty access token is available.
  Future<bool> refreshSessionSerialized() async {
    final Completer<bool>? existingCompleter = _refreshCompleter;
    if (existingCompleter != null) {
      return existingCompleter.future;
    }
    final Completer<bool> completer = Completer<bool>();
    _refreshCompleter = completer;
    try {
      await _refreshSession();
      final String? token = _readAccessToken();
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

String? _defaultReadAccessToken() =>
    Supabase.instance.client.auth.currentSession?.accessToken;
