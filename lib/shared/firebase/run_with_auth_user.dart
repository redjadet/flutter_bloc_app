import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/shared/firebase/auth_helpers.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Runs an async action with a Firebase Auth user and standardized error handling.
///
/// Use in Firebase-backed repositories to avoid duplicating auth wait plus
/// Firebase/Exception catch-and-log logic. [FirebaseAuthException] is rethrown.
/// Other errors are logged with [logContext], then [onFailureFallback] is
/// used if provided, otherwise the error is rethrown.
///
/// [logContext] is used in log messages, e.g. "RealtimeDatabaseCounterRepository.load".
Future<T> runWithAuthUser<T>({
  required final FirebaseAuth auth,
  required final String logContext,
  required final Future<T> Function(User user) action,
  final Future<T> Function()? onFailureFallback,
}) async {
  try {
    final User user = await waitForAuthUser(auth);
    return await action(user);
  } on FirebaseAuthException {
    rethrow;
  } on FirebaseException catch (error, stackTrace) {
    AppLogger.error('$logContext failed', error, stackTrace);
    if (onFailureFallback != null) {
      return onFailureFallback();
    }
    rethrow;
  } on Exception catch (error, stackTrace) {
    AppLogger.error('$logContext failed', error, stackTrace);
    if (onFailureFallback != null) {
      return onFailureFallback();
    }
    rethrow;
  } catch (error, stackTrace) {
    AppLogger.error(
      '$logContext failed with unexpected error',
      error,
      stackTrace,
    );
    if (onFailureFallback != null) {
      return onFailureFallback();
    }
    rethrow;
  }
}
