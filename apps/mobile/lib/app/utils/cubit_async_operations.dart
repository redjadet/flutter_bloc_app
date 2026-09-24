import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter_bloc_app/app/utils/network_error_mapper.dart';
import 'package:utilities/utilities.dart';

/// Normalized failure payload for cubit async helpers.
///
/// Prefer CubitExceptionHandler.executeAsync / handleException with
/// onFailure so every call site sees the same diagnostic shape (raw error,
/// message, and AppError).
final class CubitFailure {
  const new({
    required this.error,
    required this.stackTrace,
    required this.message,
    required this.appError,
  });

  final Object error;
  final StackTrace? stackTrace;
  final String message;
  final AppError appError;
}

/// Utility class for standardized exception handling in cubits.
class CubitExceptionHandler {
  new _();

  static const String _missingCallbackMessage =
      'CubitExceptionHandler requires onFailure or onError';

  /// Handle an exception with standardized logging and error conversion.
  ///
  /// Prefer [onFailure]. Provide [onError] only for legacy string-only call
  /// sites. At least one of [onFailure] or [onError] is required.
  ///
  /// Optional [onAppError] is only invoked on the legacy [onError] path.
  /// When [onFailure] is set, use [CubitFailure.appError] instead — [onAppError]
  /// is ignored.
  ///
  /// Set [logErrors] to false when [onFailure] / [onError] performs its own
  /// severity-aware logging (e.g. expected auth failures at debug).
  static void handleException(
    Object error,
    StackTrace? stackTrace,
    String logContext, {
    void Function(String errorMessage)? onError,
    void Function(CubitFailure failure)? onFailure,
    void Function(AppError appError)? onAppError,
    bool logErrors = true,
  }) {
    _requireFailureCallback(onFailure: onFailure, onError: onError);

    final CubitFailure failure = toFailure(error, stackTrace);

    if (onFailure != null) {
      if (logErrors) {
        AppLogger.error(logContext, error, stackTrace);
      }
      onFailure(failure);
      return;
    }

    final void Function(String errorMessage)? legacyOnError = onError;
    if (legacyOnError == null) {
      // Unreachable after _requireFailureCallback; keeps promotion bang-free.
      throw StateError(_missingCallbackMessage);
    }

    if (logErrors) {
      AppLogger.error(logContext, error, stackTrace);
    }

    if (onAppError != null) {
      onAppError(failure.appError);
    }

    legacyOnError(failure.message);
  }

  /// Builds a [CubitFailure] without logging (for tests / custom paths).
  static CubitFailure toFailure(Object error, StackTrace? stackTrace) {
    final String message = _extractErrorMessage(error);
    final AppError appError = error is HttpRequestFailure
        ? error.toAppError()
        : NetworkErrorMapper.getAppError(error);
    return CubitFailure(
      error: error,
      stackTrace: stackTrace,
      message: message,
      appError: appError,
    );
  }

  static String _extractErrorMessage(Object error) {
    if (error is HttpRequestFailure) {
      return NetworkErrorMapper.getErrorMessage(error);
    }

    if (error is TypeError) {
      return error.toString();
    }

    final String fallback = error.toString();
    if (fallback.startsWith('Exception:')) {
      return fallback;
    }

    try {
      final dynamic message = (error as dynamic).message;
      if (message is String && message.isNotEmpty) {
        return message;
      }
    } on Exception {
      // message property doesn't exist or isn't accessible
    }

    return fallback;
  }

  /// Execute an async operation with standardized exception handling.
  ///
  /// Prefer [onFailure]. At least one of [onFailure] or [onError] is required.
  /// The requirement is checked before [operation] runs.
  static Future<void> executeAsync<T>({
    required Future<T> Function() operation,
    required void Function(T result) onSuccess,
    required String logContext,
    void Function(String errorMessage)? onError,
    bool Function()? isAlive,
    void Function(CubitFailure failure)? onFailure,
    void Function(AppError appError)? onAppError,
    bool logErrors = true,
  }) async {
    _requireFailureCallback(onFailure: onFailure, onError: onError);
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
        onFailure: onFailure,
        onAppError: onAppError,
        logErrors: logErrors,
      );
    }
  }

  /// Execute an async operation that returns void with standardized exception
  /// handling.
  ///
  /// Prefer [onFailure]. At least one of [onFailure] or [onError] is required.
  /// The requirement is checked before [operation] runs.
  static Future<void> executeAsyncVoid({
    required Future<void> Function() operation,
    required String logContext,
    void Function(String errorMessage)? onError,
    void Function()? onSuccess,
    bool Function()? isAlive,
    void Function(CubitFailure failure)? onFailure,
    void Function(AppError appError)? onAppError,
    bool logErrors = true,
  }) async {
    await executeAsync(
      operation: operation,
      onSuccess: (_) => onSuccess?.call(),
      onError: onError,
      logContext: logContext,
      isAlive: isAlive,
      onFailure: onFailure,
      onAppError: onAppError,
      logErrors: logErrors,
    );
  }

  static void _requireFailureCallback({
    required void Function(CubitFailure failure)? onFailure,
    required void Function(String errorMessage)? onError,
  }) {
    if (onFailure == null && onError == null) {
      throw StateError(_missingCallbackMessage);
    }
  }
}
