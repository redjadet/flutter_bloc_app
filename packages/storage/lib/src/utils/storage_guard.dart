import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:storage/storage.dart';

/// Standardises repository error handling for local storage operations.
class StorageGuard {
  StorageGuard._();

  static Future<T> run<T>({
    required final String logContext,
    required final FutureOr<T> Function() action,
    final FutureOr<T> Function()? fallback,
  }) async {
    try {
      return await action();
    } on Object catch (error, stackTrace) {
      AppLogger.error(logContext, error, stackTrace);
      if (isRecoverableHiveFailure(error)) {
        rethrow;
      }
      if (fallback != null) {
        return await fallback();
      }
      rethrow;
    }
  }
}
