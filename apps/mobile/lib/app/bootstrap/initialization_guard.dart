// Optional bootstrap must soft-fail on any thrown Object (Exception and Error
// subtypes such as StateError / FlutterError) so launch is not aborted.

import 'package:app_shared_flutter/app_shared_flutter.dart';

/// Helper utilities for handling initialization errors gracefully.
///
/// Provides safe execution patterns for non-critical initialization steps
/// that shouldn't block app startup if they fail.
class InitializationGuard {
  new _();

  /// Executes an async initialization operation, logging errors but not throwing.
  ///
  /// This is useful for non-critical initialization steps that shouldn't block
  /// app startup if they fail. Errors are logged but not rethrown, allowing
  /// the application to continue running.
  ///
  /// Catches all [Object] failures (including [Error] subtypes and Flutter's
  /// FlutterError) so optional bootstrap cannot abort launch when a
  /// programming or plugin error surfaces.
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
    Future<void> Function() operation, {
    required String context,
    required String failureMessage,
  }) async {
    try {
      await operation();
    } on Object catch (error, stackTrace) {
      // Soft-fail optional bootstrap: Exception and Error subtypes alike.
      AppLogger.error('$context: $failureMessage', error, stackTrace);
      // Don't rethrow - allow app to continue
    }
  }
}
