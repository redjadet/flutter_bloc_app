import 'dart:async';

import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Small helper to standardise repository error handling for local storage
/// operations (e.g. SharedPreferences).
class StorageGuard {
  StorageGuard._();

  /// Executes [action] and returns its result.
  ///
  /// When an exception is thrown, it logs the error alongside [logContext]. If
  /// [fallback] is provided the fallback result is returned; otherwise the
  /// original error is rethrown.
  static Future<T> run<T>({
    required final String logContext,
    required final FutureOr<T> Function() action,
    FutureOr<T> Function()? fallback,
  }) async {
    try {
      return await action();
    } on Exception catch (error, stackTrace) {
      AppLogger.error(logContext, error, stackTrace);
      if (fallback != null) {
        return await fallback();
      }
      rethrow;
    }
  }
}
