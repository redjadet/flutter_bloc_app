import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

/// Manages Firebase authentication tokens with caching and refresh capabilities.
///
/// Token refresh is serialized with a Completer so that when multiple requests
/// receive 401 concurrently, only one refresh runs and the rest wait for it
/// (avoids race where each 401 triggers its own refresh and invalidates prior
/// tokens).
class AuthTokenManager {
  AuthTokenManager({
    final FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth;

  final FirebaseAuth? _firebaseAuth;

  /// Current auth token, cached to avoid repeated Firebase calls
  String? _cachedAuthToken;

  /// When the cached auth token expires
  DateTime? _tokenExpiry;

  /// User ID associated with the cached token
  String? _cachedUserId;

  /// Serializes token refresh so concurrent 401s share a single refresh.
  Completer<bool>? _refreshCompleter;

  /// Get a valid auth token, refreshing if necessary
  Future<String?> getValidAuthToken(final User user) async {
    final DateTime now = DateTime.now().toUtc();

    // Use cached token if still valid and belongs to the same user
    final DateTime? expiry = _tokenExpiry;
    if (_cachedAuthToken != null &&
        expiry != null &&
        _cachedUserId == user.uid &&
        now.isBefore(expiry.subtract(const Duration(minutes: 5)))) {
      return _cachedAuthToken;
    }

    try {
      final IdTokenResult tokenResult = await user.getIdTokenResult();
      _cachedAuthToken = tokenResult.token;
      _tokenExpiry = tokenResult.expirationTime?.toUtc();
      _cachedUserId = user.uid;
      return _cachedAuthToken;
    } catch (error, stackTrace) {
      // Clear cache on error
      _cachedAuthToken = null;
      _tokenExpiry = null;
      _cachedUserId = null;
      Error.throwWithStackTrace(error, stackTrace);
    }
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
      await user.getIdToken(true); // Force refresh
      final IdTokenResult tokenResult = await user.getIdTokenResult();
      _cachedAuthToken = tokenResult.token;
      _tokenExpiry = tokenResult.expirationTime?.toUtc();
      _cachedUserId = user.uid;
      completer.complete(_cachedAuthToken != null);
    } catch (error, stackTrace) {
      _cachedAuthToken = null;
      _tokenExpiry = null;
      _cachedUserId = null;
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
    _cachedAuthToken = null;
    _tokenExpiry = null;
    _cachedUserId = null;
  }
}
