import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:dio/dio.dart';

const String _keyStopwatch = '_sw';
typedef TelemetryEventSink = void Function(
  RequestOptions options,
  int? statusCode,
  String? error,
  int elapsedMilliseconds,
);

/// Logs request/response duration and status.
class TelemetryInterceptor extends Interceptor {
  TelemetryInterceptor({this._eventSink});

  final TelemetryEventSink? _eventSink;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_keyStopwatch] = Stopwatch()..start();
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _log(response.requestOptions, response.statusCode, null);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(
      err.requestOptions,
      err.response?.statusCode,
      err.message ?? err.error?.toString(),
    );
    handler.next(err);
  }

  void _log(RequestOptions options, int? statusCode, String? error) {
    final Stopwatch? sw = options.extra[_keyStopwatch] as Stopwatch?;
    if (sw == null) return;
    sw.stop();
    final int ms = sw.elapsedMilliseconds;
    _eventSink?.call(options, statusCode, error, ms);
    final fields = <String, Object?>{
      'method': options.method,
      'uri': LogRedaction.uriForLog(options.uri),
      'statusCode': statusCode,
      'durationMs': ms,
    };
    if (error != null) {
      AppLogger.event(
        AppLogLevel.debug,
        'http.request',
        fields: fields,
        error: error,
      );
    } else {
      AppLogger.event(AppLogLevel.debug, 'http.request', fields: fields);
    }
  }
}
