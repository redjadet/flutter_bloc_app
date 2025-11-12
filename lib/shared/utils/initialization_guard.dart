import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Helper utilities for handling initialization errors gracefully.
///
/// Provides safe execution patterns for non-critical initialization steps
/// that shouldn't block app startup if they fail.
class InitializationGuard {
  InitializationGuard._();

  /// Executes an async initialization operation, logging errors but not throwing.
  ///
  /// This is useful for non-critical initialization steps that shouldn't block
  /// app startup if they fail. Errors are logged but not rethrown, allowing
  /// the application to continue running.
  ///
  /// Parameters:
  /// - [operation]: The async operation to execute
  /// - [context]: Context string for error logging (e.g., function name)
  /// - [failureMessage]: Descriptive message to log if the operation fails
  ///
  /// Example:
  /// ```dart
  /// await InitializationGuard.executeSafely(
  ///   () => initializeOptionalFeature(),
  ///   context: 'appStartup',
  ///   failureMessage: 'Optional feature initialization failed',
  /// );
  /// ```
  static Future<void> executeSafely(
    final Future<void> Function() operation, {
    required final String context,
    required final String failureMessage,
  }) async {
    try {
      await operation();
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        '$context: $failureMessage',
        error,
        stackTrace,
      );
      // Don't rethrow - allow app to continue
    }
  }
}
