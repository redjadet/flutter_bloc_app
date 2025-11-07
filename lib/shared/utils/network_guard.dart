import 'dart:async';

import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:http/http.dart' as http;

/// Helper for wrapping HTTP requests with consistent logging and error mapping.
class NetworkGuard {
  NetworkGuard._();

  /// Executes [request] and validates the response using [isSuccess].
  ///
  /// On HTTP failure, [onHttpFailure] is invoked to produce the domain error.
  /// On any other exception, [onException] builds the error.
  static Future<http.Response> execute<E extends Exception>({
    required final Future<http.Response> Function() request,
    required final Duration timeout,
    required final bool Function(int statusCode) isSuccess,
    required final String logContext,
    required final E Function(http.Response response) onHttpFailure,
    required final E Function(Object error) onException,
    final void Function(http.Response response)? onFailureLog,
  }) async {
    try {
      final http.Response response = await request().timeout(timeout);
      if (isSuccess(response.statusCode)) {
        return response;
      }
      onFailureLog?.call(response);
      throw onHttpFailure(response);
    } on E {
      rethrow;
    } on TimeoutException catch (error, stackTrace) {
      AppLogger.error('$logContext timeout', error, stackTrace);
      throw onException(error);
    } on Exception catch (error, stackTrace) {
      AppLogger.error('$logContext failed', error, stackTrace);
      throw onException(error);
    }
  }
}
