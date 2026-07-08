import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/app/firebase/auth_helpers.dart';

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
