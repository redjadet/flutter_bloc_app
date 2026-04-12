import 'package:firebase_auth/firebase_auth.dart';

/// Supplies Firebase ID tokens for Render caller auth (`Authorization: Bearer`).
abstract class RenderCallerAuthHeaderProvider {
  /// Returns a fresh ID token, or null when signed out.
  Future<String?> bearerIdToken({final bool forceRefresh = false});
}

class DefaultRenderCallerAuthHeaderProvider implements RenderCallerAuthHeaderProvider {
  /// Resolves [FirebaseAuth] lazily so DI registration does not touch
  /// [FirebaseAuth.instance] before Firebase is initialized (for example in
  /// unit tests that configure GetIt without a default Firebase app).
  DefaultRenderCallerAuthHeaderProvider(this._auth);

  final FirebaseAuth Function() _auth;

  @override
  Future<String?> bearerIdToken({final bool forceRefresh = false}) async {
    final User? user = _auth().currentUser;
    if (user == null) {
      return null;
    }
    return user.getIdToken(forceRefresh);
  }
}
