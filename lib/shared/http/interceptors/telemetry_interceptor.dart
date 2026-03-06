import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

const String _keyStopwatch = '_sw';

/// Logs request/response duration and status.
class TelemetryInterceptor extends Interceptor {
  @override
  void onRequest(
    final RequestOptions options,
    final RequestInterceptorHandler handler,
  ) {
    options.extra[_keyStopwatch] = Stopwatch()..start();
    handler.next(options);
  }

  @override
  void onResponse(
    final Response<dynamic> response,
    final ResponseInterceptorHandler handler,
  ) {
    _log(response.requestOptions, response.statusCode, null);
    handler.next(response);
  }

  @override
  void onError(
    final DioException err,
    final ErrorInterceptorHandler handler,
  ) {
    _log(
      err.requestOptions,
      err.response?.statusCode,
      err.message ?? err.error?.toString(),
    );
    handler.next(err);
  }

  void _log(
    final RequestOptions options,
    final int? statusCode,
    final String? error,
  ) {
    final Stopwatch? sw = options.extra[_keyStopwatch] as Stopwatch?;
    if (sw == null) return;
    sw.stop();
    final int ms = sw.elapsedMilliseconds;
    if (error != null) {
      AppLogger.debug(
        'HTTP ${options.method} ${options.uri} failed after ${ms}ms: $error',
      );
    } else {
      AppLogger.debug(
        'HTTP ${options.method} ${options.uri} -> $statusCode (${ms}ms)',
      );
    }
  }
}
