import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Helper for wrapping HTTP requests with consistent logging and error mapping.
class NetworkGuard {
  NetworkGuard._();

  /// Executes [request] and validates using [isSuccess].
  ///
  /// On HTTP failure, [onHttpFailure] is invoked with the Dio [Response].
  /// On [DioException] or other errors, [onException] builds the domain error.
  static Future<Response<T>> executeDio<T, E extends Exception>({
    required final Future<Response<T>> Function() request,
    required final Duration timeout,
    required final bool Function(int statusCode) isSuccess,
    required final String logContext,
    required final E Function(Response<T> response) onHttpFailure,
    required final E Function(Object error) onException,
    final void Function(Response<T> response)? onFailureLog,
  }) async {
    try {
      final Response<T> response = await request().timeout(timeout);
      final int? statusCode = response.statusCode;
      if (statusCode != null && isSuccess(statusCode)) {
        return response;
      }
      onFailureLog?.call(response);
      throw onHttpFailure(response);
    } on E {
      rethrow;
    } on DioException catch (error, stackTrace) {
      AppLogger.error('$logContext failed', error, stackTrace);
      throw onException(error);
    } on TimeoutException catch (error, stackTrace) {
      AppLogger.error('$logContext timeout', error, stackTrace);
      throw onException(error);
    } on Exception catch (error, stackTrace) {
      AppLogger.error('$logContext failed', error, stackTrace);
      throw onException(error);
    }
  }
}
