import 'package:firebase_auth/firebase_auth.dart';

/// Supplies Firebase ID tokens for Render caller auth (`Authorization: Bearer`).
abstract class RenderCallerAuthHeaderProvider {
  /// Returns a fresh ID token, or null when signed out.
  Future<String?> bearerIdToken({final bool forceRefresh = false});
}

class DefaultRenderCallerAuthHeaderProvider implements RenderCallerAuthHeaderProvider {
  DefaultRenderCallerAuthHeaderProvider(this._auth);

  final FirebaseAuth _auth;

  @override
  Future<String?> bearerIdToken({final bool forceRefresh = false}) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    return user.getIdToken(forceRefresh);
  }
}
