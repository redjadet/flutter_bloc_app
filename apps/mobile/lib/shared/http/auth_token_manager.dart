import 'dart:async';

import 'package:auth/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/core/auth/token_repository.dart';

/// Manages Firebase authentication tokens with caching and refresh capabilities.
///
/// Token refresh is serialized with a Completer so that when multiple requests
/// receive 401 concurrently, only one refresh runs and the rest wait for it
/// (avoids race where each 401 triggers its own refresh and invalidates prior
/// tokens).
class AuthTokenManager {
  AuthTokenManager({this._firebaseAuth, final TokenRepository? tokenRepository})
    : _tokenRepository = tokenRepository ?? InMemoryTokenRepository();

  final FirebaseAuth? _firebaseAuth;
  final TokenRepository _tokenRepository;

  /// Serializes token refresh so concurrent 401s share a single refresh.
  Completer<bool>? _refreshCompleter;

  Future<void> hydrateFromPersistentSession() =>
      _tokenRepository.hydrateFirebaseSession(_firebaseAuth?.currentUser);

  /// Get a valid auth token, refreshing if necessary
  Future<String?> getValidAuthToken(final User user) async {
    return _tokenRepository.getFirebaseAccessToken(user);
  }

  /// Runs a single token refresh; concurrent callers await the same future.
  Future<bool> _runRefreshSerialized({final User? userOverride}) async {
    final Completer<bool>? existingCompleter = _refreshCompleter;
    if (existingCompleter != null) {
      return existingCompleter.future;
    }
    final Completer<bool> completer = Completer<bool>();
    _refreshCompleter = completer;
    final Future<bool> future = completer.future;
    try {
      final User? user = userOverride ?? _firebaseAuth?.currentUser;
      if (user == null) {
        completer.complete(false);
        return future;
      }
      final String? token = await _tokenRepository.refreshFirebaseAccessToken(
        user,
      );
      completer.complete(token != null);
    } catch (error, stackTrace) {
      _tokenRepository.clearProvider(AuthProviderKind.firebase);
      completer.completeError(error, stackTrace);
    } finally {
      _refreshCompleter = null;
    }
    return future;
  }

  /// Refresh the authentication token.
  /// When multiple callers hit 401 at once, only one refresh runs; others wait.
  Future<bool> refreshToken() async {
    return _runRefreshSerialized();
  }

  /// Force-refresh the authentication token and return the updated token value.
  /// Participates in the same serialized refresh as [refreshToken].
  Future<String?> refreshTokenAndGet(final User user) async {
    final bool refreshed = await _runRefreshSerialized(userOverride: user);
    if (!refreshed) {
      return null;
    }
    return getValidAuthToken(user);
  }

  /// Clear cached token
  void clearCache() {
    _tokenRepository.clearProvider(AuthProviderKind.firebase);
  }
}
