import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart'
    show DatabaseReference;

/// Runs a Realtime Database write (e.g. [DatabaseReference.set]) and converts
/// a known platform TypeError (details cast) into a [FirebaseException].
///
/// Some platform implementations throw [TypeError] when the response details
/// are not in the expected shape. This helper rethrows that as a consistent
/// [FirebaseException] so callers can handle it uniformly.
///
/// [message] should describe the operation for the user (e.g. "Check database
/// rules and path keys" or "Check database rules and auth state").
Future<void> guardRealtimeDatabaseWrite(
  final Future<void> Function() operation, {
  required final String message,
}) async {
  try {
    await operation();
  } catch (error, stackTrace) {
    if (error is TypeError) {
      final String errorMessage = error.toString();
      final bool isDetailsCastIssue = errorMessage.contains(
        "'String' is not a subtype of type 'Map",
      );
      if (isDetailsCastIssue) {
        Error.throwWithStackTrace(
          FirebaseException(
            plugin: 'firebase_database',
            code: 'database-platform-error-details',
            message: message,
          ),
          stackTrace,
        );
      }
    }
    rethrow;
  }
}
