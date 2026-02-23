import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Utility class for standardized exception handling in cubits.
///
/// This class provides helpers to reduce duplication in exception handling
/// patterns across cubits, particularly for:
/// - Logging exceptions consistently
/// - Handling specific exception types
/// - Converting exceptions to error messages
class CubitExceptionHandler {
  CubitExceptionHandler._();

  /// Handle an exception with standardized logging and error conversion.
  ///
  /// This method:
  /// 1. Logs the exception with the provided context
  /// 2. Converts the exception to a user-friendly error message
  /// 3. Calls the appropriate error handler
  ///
  /// Parameters:
  /// - [error]: The exception that occurred
  /// - [stackTrace]: The stack trace (if available)
  /// - [logContext]: Context string for logging (e.g., 'MyCubit.loadData')
  /// - [onError]: Callback to handle the error (typically emits error state)
  /// - [specificExceptionHandlers]: Map of specific exception types to custom handlers
  static void handleException<T extends Exception>(
    final Object error,
    final StackTrace? stackTrace,
    final String logContext, {
    required final void Function(String errorMessage) onError,
    final Map<Type, void Function(Object error, StackTrace? stackTrace)>?
    specificExceptionHandlers,
    final void Function(Object error, StackTrace? stackTrace)?
    onErrorWithDetails,
  }) {
    // Handle specific exceptions first if provided
    if (specificExceptionHandlers != null) {
      final Type errorType = error.runtimeType;
      final handler = specificExceptionHandlers[errorType];
      if (handler != null) {
        handler(error, stackTrace);
        return;
      }
    }

    if (onErrorWithDetails != null) {
      onErrorWithDetails(error, stackTrace);
      return;
    }

    // Log the exception
    AppLogger.error(logContext, error, stackTrace);

    // Convert to error message
    final String errorMessage = _extractErrorMessage(error);

    // Call the error handler
    onError(errorMessage);
  }

  /// Extract a user-friendly error message from an exception.
  static String _extractErrorMessage(final Object error) {
    // Handle TypeError specially - it doesn't have a message property
    if (error is TypeError) {
      return error.toString();
    }

    final String fallback = error.toString();
    if (fallback.startsWith('Exception:')) {
      return fallback;
    }

    // Handle exceptions with a message property
    try {
      final dynamic message = (error as dynamic).message;
      if (message is String && message.isNotEmpty) {
        return message;
      }
    } on Exception {
      // message property doesn't exist or isn't accessible
    }

    // Fallback to toString
    return fallback;
  }

  /// Execute an async operation with standardized exception handling.
  ///
  /// This is a convenience method that wraps try-catch with standardized
  /// exception handling. When [isAlive] is provided, [onSuccess] and [onError]
  /// are only invoked if [isAlive] returns true (e.g. pass `() => !cubit.isClosed`
  /// to avoid emitting after the cubit is closed).
  ///
  /// Example:
  /// ```dart
  /// await CubitExceptionHandler.executeAsync(
  ///   operation: () => _repository.fetchData(),
  ///   onSuccess: (data) => emit(state.copyWith(data: data)),
  ///   onError: (message) => emit(state.copyWith(errorMessage: message)),
  ///   logContext: 'MyCubit.loadData',
  ///   isAlive: () => !isClosed,
  /// );
  /// ```
  static Future<void> executeAsync<T>({
    required final Future<T> Function() operation,
    required final void Function(T result) onSuccess,
    required final void Function(String errorMessage) onError,
    required final String logContext,
    final bool Function()? isAlive,
    final Map<Type, void Function(Object error, StackTrace? stackTrace)>?
    specificExceptionHandlers,
    final void Function(Object error, StackTrace? stackTrace)?
    onErrorWithDetails,
  }) async {
    try {
      final T result = await operation();
      if (isAlive != null && !isAlive()) return;
      onSuccess(result);
    } on Object catch (error, stackTrace) {
      if (isAlive != null && !isAlive()) return;
      handleException(
        error,
        stackTrace,
        logContext,
        onError: onError,
        specificExceptionHandlers: specificExceptionHandlers,
        onErrorWithDetails: onErrorWithDetails,
      );
    }
  }

  /// Execute an async operation that returns void with standardized exception handling.
  ///
  /// Convenience method for operations that don't return a value.
  /// When [isAlive] is provided, callbacks are only invoked if [isAlive] returns true.
  ///
  /// Example:
  /// ```dart
  /// await CubitExceptionHandler.executeAsyncVoid(
  ///   operation: () => _repository.connect(),
  ///   onSuccess: () => emit(state.copyWith(isConnected: true)),
  ///   onError: (message) => emit(state.copyWith(errorMessage: message)),
  ///   logContext: 'MyCubit.connect',
  ///   isAlive: () => !isClosed,
  /// );
  /// ```
  static Future<void> executeAsyncVoid({
    required final Future<void> Function() operation,
    required final void Function(String errorMessage) onError,
    required final String logContext,
    final void Function()? onSuccess,
    final bool Function()? isAlive,
    final Map<Type, void Function(Object error, StackTrace? stackTrace)>?
    specificExceptionHandlers,
    final void Function(Object error, StackTrace? stackTrace)?
    onErrorWithDetails,
  }) async {
    await executeAsync(
      operation: operation,
      onSuccess: (_) => onSuccess?.call(),
      onError: onError,
      logContext: logContext,
      isAlive: isAlive,
      specificExceptionHandlers: specificExceptionHandlers,
      onErrorWithDetails: onErrorWithDetails,
    );
  }
}
