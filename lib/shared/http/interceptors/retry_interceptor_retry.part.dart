part of 'retry_interceptor.dart';

extension _RetryInterceptorRetry on RetryInterceptor {
  bool _shouldConsiderRetry(final RequestOptions options) {
    if (options.extra[RetryInterceptor.extraSkipRetry] == true) {
      return false;
    }
    if (_isMultipart(options)) {
      return true; // multipart is handled explicitly (skip) in retry paths
    }
    if (_isIdempotentMethod(options.method)) {
      return true;
    }
    return options.extra[RetryInterceptor.extraAllowRetryNonIdempotent] == true;
  }

  bool _isIdempotentMethod(final String method) {
    switch (method.toUpperCase()) {
      case 'GET':
      case 'HEAD':
      case 'PUT':
      case 'DELETE':
      case 'OPTIONS':
      case 'TRACE':
        return true;
    }
    return false;
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
    requestOptions.extra[RetryInterceptor.extraRetryCount] = attempt + 1;
    return _dio.fetch<dynamic>(requestOptions);
  }

  int _retryCountFrom(final RequestOptions requestOptions) =>
      (requestOptions.extra[RetryInterceptor.extraRetryCount] as int?) ?? 0;
}
