import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

/// Default timeout for waiting for authentication user.
const Duration _defaultAuthWaitTimeout = Duration(seconds: 5);

/// Waits for a Firebase Auth user to be available.
///
/// Returns the current user if available, otherwise waits for auth state changes
/// until a user is available or the timeout is reached.
///
/// Throws [FirebaseAuthException] if no user is available within [timeout].
Future<User> waitForAuthUser(
  final FirebaseAuth auth, {
  final Duration timeout = _defaultAuthWaitTimeout,
}) async {
  final User? current = auth.currentUser;
  if (current != null) {
    return current;
  }

  try {
    return await auth
        .authStateChanges()
        .where((final User? user) => user != null)
        .cast<User>()
        .first
        .timeout(timeout);
  } on TimeoutException {
    throw FirebaseAuthException(
      code: 'no-current-user',
      message:
          'FirebaseAuth did not supply a user within ${timeout.inMilliseconds}ms.',
    );
  }
}
