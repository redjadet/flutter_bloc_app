import 'package:firebase_auth/firebase_auth.dart';

/// Manages Firebase authentication tokens with caching and refresh capabilities.
class AuthTokenManager {
  AuthTokenManager({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth;

  final FirebaseAuth? _firebaseAuth;

  /// Current auth token, cached to avoid repeated Firebase calls
  String? _cachedAuthToken;

  /// When the cached auth token expires
  DateTime? _tokenExpiry;

  /// Get a valid auth token, refreshing if necessary
  Future<String?> getValidAuthToken(final User user) async {
    final DateTime now = DateTime.now().toUtc();

    // Use cached token if still valid
    if (_cachedAuthToken != null &&
        _tokenExpiry != null &&
        now.isBefore(_tokenExpiry!.subtract(const Duration(minutes: 5)))) {
      return _cachedAuthToken;
    }

    try {
      final IdTokenResult tokenResult = await user.getIdTokenResult();
      _cachedAuthToken = tokenResult.token;
      _tokenExpiry = tokenResult.expirationTime?.toUtc();
      return _cachedAuthToken;
    } catch (error, stackTrace) {
      // Clear cache on error
      _cachedAuthToken = null;
      _tokenExpiry = null;
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
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  /// Force-refresh the authentication token and return the updated token value.
  Future<String?> refreshTokenAndGet(final User user) async {
    await user.getIdToken(true);
    _cachedAuthToken = null;
    _tokenExpiry = null;
    return getValidAuthToken(user);
  }

  /// Clear cached token
  void clearCache() {
    _cachedAuthToken = null;
    _tokenExpiry = null;
  }
}
