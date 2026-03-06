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
  }) : _dio = dio,
       _maxRetries = maxRetries,
       _retryNotificationService = retryNotificationService;

  final Dio _dio;
  final int _maxRetries;
  final RetryNotificationService? _retryNotificationService;

  static const String _keyRetryCount = 'retry_count';

  @override
  Future<void> onError(
    final DioException err,
    final ErrorInterceptorHandler handler,
  ) async {
    final int attempt = (err.requestOptions.extra[_keyRetryCount] as int?) ?? 0;
    if (attempt >= _maxRetries) {
      handler.next(err);
      return;
    }
    if (!_canRetry(err)) {
      handler.next(err);
      return;
    }
    if (_isMultipart(err.requestOptions)) {
      AppLogger.warning(
        'RetryInterceptor: skip retry (multipart request is single-use)',
      );
      handler.next(err);
      return;
    }

    final Duration delay = RetryPolicy.calculateDelay(
      attempt: attempt,
      baseDelay: const Duration(seconds: 1),
      maxDelay: const Duration(seconds: 30),
    );

    _retryNotificationService?.notifyRetrying(
      RetryNotification(
        method: err.requestOptions.method,
        uri: err.requestOptions.uri,
        attempt: attempt + 1,
        maxAttempts: _maxRetries + 1,
        delay: delay,
        error: err.error ?? err,
      ),
    );

    AppLogger.debug(
      'RetryInterceptor retrying (attempt ${attempt + 1}/${_maxRetries + 1}): ${err.message}',
    );

    await Future<void>.delayed(delay);

    err.requestOptions.extra[_keyRetryCount] = attempt + 1;

    try {
      final response = await _dio.fetch<dynamic>(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    } on Object catch (e, st) {
      handler.next(
        DioException(
          requestOptions: err.requestOptions,
          error: e,
          stackTrace: st,
        ),
      );
    }
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
}
