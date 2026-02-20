import 'package:firebase_auth/firebase_auth.dart';

/// Manages Firebase authentication tokens with caching and refresh capabilities.
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

  /// Refresh the authentication token
  Future<bool> refreshToken() async {
    try {
      final User? user = _firebaseAuth?.currentUser;
      if (user == null) return false;

      await user.getIdToken(true); // Force refresh
      _cachedAuthToken = null; // Clear cache to force re-fetch
      _tokenExpiry = null;
      return true;
    } catch (error, stackTrace) {
      _cachedAuthToken = null;
      _tokenExpiry = null;
      _cachedUserId = null;
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  /// Force-refresh the authentication token and return the updated token value.
  Future<String?> refreshTokenAndGet(final User user) async {
    await user.getIdToken(true);
    _cachedAuthToken = null;
    _tokenExpiry = null;
    _cachedUserId = null;
    return getValidAuthToken(user);
  }

  /// Clear cached token
  void clearCache() {
    _cachedAuthToken = null;
    _tokenExpiry = null;
    _cachedUserId = null;
  }
}
