import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/shared/http/interceptors/telemetry_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

class _SequenceAdapter implements HttpClientAdapter {
  _SequenceAdapter(this._fetch);

  final Future<ResponseBody> Function(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  )
  _fetch;

  @override
  Future<ResponseBody> fetch(
    final RequestOptions options,
    final Stream<List<int>>? requestStream,
    final Future<void>? cancelFuture,
  ) => _fetch(options, requestStream, cancelFuture);

  @override
  void close({final bool force = false}) {}
}

class _TelemetryEvent {
  const _TelemetryEvent({
    required this.statusCode,
    required this.error,
    required this.elapsedMilliseconds,
  });

  final int? statusCode;
  final String? error;
  final int elapsedMilliseconds;
}

void main() {
  group('TelemetryInterceptor', () {
    late Dio dio;
    late List<_TelemetryEvent> events;

    setUp(() {
      events = <_TelemetryEvent>[];
      dio = Dio(BaseOptions(validateStatus: (_) => true))
        ..interceptors.add(
          TelemetryInterceptor(
            eventSink:
                (
                  final options,
                  final statusCode,
                  final error,
                  final elapsedMilliseconds,
                ) {
                  events.add(
                    _TelemetryEvent(
                      statusCode: statusCode,
                      error: error,
                      elapsedMilliseconds: elapsedMilliseconds,
                    ),
                  );
                },
          ),
        );
    });

    test('records response telemetry events', () async {
      dio.httpClientAdapter = _SequenceAdapter((
        final options,
        final _,
        final cancelFuture,
      ) async {
        if (cancelFuture != null) {}
        return ResponseBody.fromString(
          jsonEncode(<String, Object?>{'ok': true}),
          200,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>[Headers.jsonContentType],
          },
        );
      });

      final Response<dynamic> response = await dio.get<dynamic>(
        'https://example.com/telemetry',
      );

      expect(response.statusCode, 200);
      expect(events, hasLength(1));
      expect(events.single.statusCode, 200);
      expect(events.single.error, isNull);
      expect(events.single.elapsedMilliseconds, greaterThanOrEqualTo(0));
    });

    test('records error telemetry events', () async {
      dio.httpClientAdapter = _SequenceAdapter((
        final options,
        final _,
        final cancelFuture,
      ) async {
        if (cancelFuture != null) {}
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          message: 'socket failed',
        );
      });

      await expectLater(
        dio.get<dynamic>('https://example.com/telemetry'),
        throwsA(isA<DioException>()),
      );

      expect(events, hasLength(1));
      expect(events.single.statusCode, isNull);
      expect(events.single.error, contains('socket failed'));
      expect(events.single.elapsedMilliseconds, greaterThanOrEqualTo(0));
    });
  });
}
