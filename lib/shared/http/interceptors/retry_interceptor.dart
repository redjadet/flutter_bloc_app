import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/shared/services/retry_notification_service.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/retry_policy.dart';

/// Retries on transient status codes and connection/timeout errors.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required final Dio dio,
    required final int maxRetries,
    final RetryNotificationService? retryNotificationService,
    final Future<void> Function(Duration delay)? waitForDelay,
  }) : _dio = dio,
       _maxRetries = maxRetries,
       _retryNotificationService = retryNotificationService,
       _waitForDelay = waitForDelay ?? Future<void>.delayed;

  final Dio _dio;
  final int _maxRetries;
  final RetryNotificationService? _retryNotificationService;
  final Future<void> Function(Duration delay) _waitForDelay;

  static const String _keyRetryCount = 'retry_count';

  @override
  Future<void> onResponse(
    final Response<dynamic> response,
    final ResponseInterceptorHandler handler,
  ) async {
    if (!_isTransientStatusCode(response.statusCode ?? 0)) {
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

  bool _canRetry(final DioException err) {
    final response = err.response;
    if (response != null) {
      return _isTransientStatusCode(response.statusCode ?? 0);
    }
    return _isTransientDioException(err);
  }

  bool _isTransientStatusCode(final int statusCode) =>
      statusCode == 408 || statusCode == 429 || statusCode >= 500;

  bool _isTransientDioException(final DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      default:
        break;
    }
    final String? message = err.message?.toLowerCase();
    if (message == null) return false;
    return message.contains('timeout') ||
        message.contains('connection') ||
        message.contains('network') ||
        message.contains('temporary') ||
        message.contains('unavailable') ||
        message.contains('server error');
  }

  bool _isMultipart(final RequestOptions options) => options.data is FormData;

  Future<Response<dynamic>?> _retryResponse(
    final Response<dynamic> response,
  ) async {
    final RequestOptions requestOptions = response.requestOptions;
    final int attempt = _retryCountFrom(requestOptions);
    if (attempt >= _maxRetries) {
      return null;
    }
    if (_isMultipart(requestOptions)) {
      AppLogger.warning(
        'RetryInterceptor: skip retry (multipart request is single-use)',
      );
      return null;
    }
    return _runRetry(
      requestOptions: requestOptions,
      attempt: attempt,
      error: response,
      logMessage: 'status ${response.statusCode}',
    );
  }

  Future<_RetryResult> _retryError(final DioException err) async {
    final RequestOptions requestOptions = err.requestOptions;
    final int attempt = _retryCountFrom(requestOptions);
    if (attempt >= _maxRetries) {
      return const _RetryResult.noRetry();
    }
    if (_isMultipart(requestOptions)) {
      AppLogger.warning(
        'RetryInterceptor: skip retry (multipart request is single-use)',
      );
      return _RetryResult.error(err);
    }

    try {
      return _RetryResult.response(
        await _runRetry(
          requestOptions: requestOptions,
          attempt: attempt,
          error: err.error ?? err,
          logMessage: err.message,
        ),
      );
    } on DioException catch (e) {
      return _RetryResult.error(e);
    }
  }

  Future<Response<dynamic>> _runRetry({
    required final RequestOptions requestOptions,
    required final int attempt,
    required final Object error,
    required final String? logMessage,
  }) async {
    final Duration delay = RetryPolicy.calculateDelay(
      attempt: attempt,
      baseDelay: const Duration(seconds: 1),
      maxDelay: const Duration(seconds: 30),
    );

    _retryNotificationService?.notifyRetrying(
      RetryNotification(
        method: requestOptions.method,
        uri: requestOptions.uri,
        attempt: attempt + 1,
        maxAttempts: _maxRetries + 1,
        delay: delay,
        error: error,
      ),
    );

    AppLogger.debug(
      'RetryInterceptor retrying (attempt ${attempt + 1}/${_maxRetries + 1}): ${logMessage ?? error}',
    );

    await _waitForDelay(delay);
    requestOptions.extra[_keyRetryCount] = attempt + 1;
    return _dio.fetch<dynamic>(requestOptions);
  }

  int _retryCountFrom(final RequestOptions requestOptions) =>
      (requestOptions.extra[_keyRetryCount] as int?) ?? 0;
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
