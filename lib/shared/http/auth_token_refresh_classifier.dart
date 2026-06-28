import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Auth error codes that indicate the session cannot be recovered
/// without signing the user out (not transient network failures).
const Set<String> authClassifiedFirebaseRefreshFailureCodes = <String>{
  'user-token-expired',
  'user-disabled',
  'invalid-user-token',
  'user-not-found',
  'invalid-credential',
  'credential-already-in-use',
};

/// Returns true when [error] indicates an unrecoverable auth session failure.
bool isAuthClassifiedFirebaseRefreshFailure(final Object error) {
  if (error is! FirebaseAuthException) {
    return false;
  }
  return authClassifiedFirebaseRefreshFailureCodes.contains(error.code);
}
