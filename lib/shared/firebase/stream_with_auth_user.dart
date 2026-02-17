import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/shared/firebase/auth_helpers.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Builds a stream that waits for auth, then expands to a stream per user with error logging.
///
/// Use in Firebase-backed repositories to avoid duplicating
/// `Stream.fromFuture(waitForAuthUser(auth)).asyncExpand(...).handleError(...)`.
Stream<T> streamWithAuthUser<T>({
  required final FirebaseAuth auth,
  required final String logContext,
  required final Stream<T> Function(User user) streamPerUser,
}) =>
    Stream.fromFuture(
          waitForAuthUser(auth),
        )
        .asyncExpand(streamPerUser)
        .handleError(AppLogger.streamErrorHandler(logContext));
