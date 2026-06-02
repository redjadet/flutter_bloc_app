import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/shared/services/retry_notification_service.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/retry_policy.dart';

part 'retry_interceptor_retry.part.dart';

/// Retries on transient status codes and connection/timeout errors.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this._dio,
    required this._maxRetries,
    this._retryNotificationService,
    final Future<void> Function(Duration delay)? waitForDelay,
  }) : _waitForDelay = waitForDelay ?? Future<void>.delayed;

  final Dio _dio;
  final int _maxRetries;
  final RetryNotificationService? _retryNotificationService;
  final Future<void> Function(Duration delay) _waitForDelay;

  static const String extraRetryCount = 'retry_count';
  static const String extraAllowRetryNonIdempotent =
      'allow_retry_non_idempotent';
  static const String extraSkipRetry = 'skip_retry';

  @override
  Future<void> onResponse(
    final Response<dynamic> response,
    final ResponseInterceptorHandler handler,
  ) async {
    if (!_isTransientStatusCode(response.statusCode ?? 0)) {
      handler.next(response);
      return;
    }
    if (!_shouldConsiderRetry(response.requestOptions)) {
      AppLogger.debug(
        'RetryInterceptor: skip retry (not allowed): '
        '${response.requestOptions.method} ${response.requestOptions.uri}',
      );
      handler.next(response);
      return;
    }

    final Response<dynamic>? retried = await _retryResponse(response);
    if (retried != null) {
      handler.resolve(retried);
      return;
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
    final DioException err,
    final ErrorInterceptorHandler handler,
  ) async {
    if (!_canRetry(err)) {
      handler.next(err);
      return;
    }
    if (!_shouldConsiderRetry(err.requestOptions)) {
      AppLogger.debug(
        'RetryInterceptor: skip retry (not allowed): '
        '${err.requestOptions.method} ${err.requestOptions.uri}',
      );
      handler.next(err);
      return;
    }
    final _RetryResult result = await _retryError(err);
    if (result.response case final Response<dynamic> response) {
      handler.resolve(response);
      return;
    }
    if (result.error case final DioException error) {
      handler.next(error);
      return;
    }
    handler.next(err);
  }
}

class _RetryResult {
  const _RetryResult._({
    this.response,
    this.error,
  });

  const _RetryResult.noRetry() : this._();

  const _RetryResult.response(final Response<dynamic> response)
    : this._(response: response);

  const _RetryResult.error(final DioException error) : this._(error: error);

  final Response<dynamic>? response;
  final DioException? error;
}
