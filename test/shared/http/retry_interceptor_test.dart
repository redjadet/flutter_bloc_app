import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/shared/http/interceptors/retry_interceptor.dart';
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

void main() {
  group('RetryInterceptor', () {
    late Dio dio;

    Dio buildDio({final int maxRetries = 2}) {
      final Dio built = Dio(BaseOptions(validateStatus: (_) => true));
      built.interceptors.add(
        RetryInterceptor(
          dio: built,
          maxRetries: maxRetries,
          waitForDelay: (final _) async {},
        ),
      );
      return built;
    }

    test('retries transient status responses until success', () async {
      final List<int> seenRetryCounts = <int>[];
      int requestCount = 0;
      dio = buildDio();
      dio.httpClientAdapter = _SequenceAdapter((
        final options,
        final _,
        final cancelFuture,
      ) async {
        if (cancelFuture != null) {}
        seenRetryCounts.add(
          (options.extra[RetryInterceptor.extraRetryCount] as int?) ?? 0,
        );
        requestCount += 1;
        if (requestCount < 3) {
          return ResponseBody.fromString(
            jsonEncode(<String, Object?>{'error': 'temporary'}),
            503,
            headers: <String, List<String>>{
              Headers.contentTypeHeader: <String>[Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString(
          jsonEncode(<String, Object?>{'ok': true}),
          200,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>[Headers.jsonContentType],
          },
        );
      });

      final Response<dynamic> response = await dio.get<dynamic>(
        'https://example.com/retry',
      );

      expect(response.statusCode, 200);
      expect(requestCount, 3);
      expect(seenRetryCounts, <int>[0, 1, 2]);
    });

    test('returns the final transient response after max retries', () async {
      int requestCount = 0;
      dio = buildDio(maxRetries: 1);
      dio.httpClientAdapter = _SequenceAdapter((
        final options,
        final _,
        final cancelFuture,
      ) async {
        if (cancelFuture != null) {}
        requestCount += 1;
        return ResponseBody.fromString(
          jsonEncode(<String, Object?>{'error': 'still temporary'}),
          429,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>[Headers.jsonContentType],
          },
        );
      });

      final Response<dynamic> response = await dio.get<dynamic>(
        'https://example.com/retry',
      );

      expect(response.statusCode, 429);
      expect(requestCount, 2);
    });

    test('does not retry non-idempotent methods by default', () async {
      int requestCount = 0;
      dio = buildDio(maxRetries: 2);
      dio.httpClientAdapter = _SequenceAdapter((
        final options,
        final _,
        final cancelFuture,
      ) async {
        if (cancelFuture != null) {}
        requestCount += 1;
        if (requestCount == 1) {
          return ResponseBody.fromString(
            jsonEncode(<String, Object?>{'error': 'temporary'}),
            503,
            headers: <String, List<String>>{
              Headers.contentTypeHeader: <String>[Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString(
          jsonEncode(<String, Object?>{'ok': true}),
          200,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>[Headers.jsonContentType],
          },
        );
      });

      final Response<dynamic> response = await dio.post<dynamic>(
        'https://example.com/mutate',
        data: <String, Object?>{'x': 1},
      );

      expect(response.statusCode, 503);
      expect(requestCount, 1);
    });

    test('retries idempotent delete methods by default', () async {
      int requestCount = 0;
      dio = buildDio(maxRetries: 2);
      dio.httpClientAdapter = _SequenceAdapter((
        final options,
        final _,
        final cancelFuture,
      ) async {
        if (cancelFuture != null) {}
        requestCount += 1;
        if (requestCount == 1) {
          return ResponseBody.fromString(
            jsonEncode(<String, Object?>{'error': 'temporary'}),
            503,
            headers: <String, List<String>>{
              Headers.contentTypeHeader: <String>[Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString(
          jsonEncode(<String, Object?>{'ok': true}),
          200,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>[Headers.jsonContentType],
          },
        );
      });

      final Response<dynamic> response = await dio.delete<dynamic>(
        'https://example.com/mutate',
      );

      expect(response.statusCode, 200);
      expect(requestCount, 2);
    });

    test('can retry non-idempotent methods when explicitly opted in', () async {
      int requestCount = 0;
      dio = buildDio(maxRetries: 2);
      dio.httpClientAdapter = _SequenceAdapter((
        final options,
        final _,
        final cancelFuture,
      ) async {
        if (cancelFuture != null) {}
        requestCount += 1;
        if (requestCount == 1) {
          return ResponseBody.fromString(
            jsonEncode(<String, Object?>{'error': 'temporary'}),
            503,
            headers: <String, List<String>>{
              Headers.contentTypeHeader: <String>[Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString(
          jsonEncode(<String, Object?>{'ok': true}),
          200,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>[Headers.jsonContentType],
          },
        );
      });

      final Response<dynamic> response = await dio.post<dynamic>(
        'https://example.com/mutate',
        data: <String, Object?>{'x': 1},
        options: Options(
          extra: <String, Object?>{
            RetryInterceptor.extraAllowRetryNonIdempotent: true,
          },
        ),
      );

      expect(response.statusCode, 200);
      expect(requestCount, 2);
    });

    test(
      'retries transient DioException failures and resolves success',
      () async {
        int requestCount = 0;
        dio = buildDio(maxRetries: 1);
        dio.httpClientAdapter = _SequenceAdapter((
          final options,
          final _,
          final cancelFuture,
        ) async {
          if (cancelFuture != null) {}
          requestCount += 1;
          if (requestCount == 1) {
            throw DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
              message: 'temporary network issue',
            );
          }
          return ResponseBody.fromString(
            jsonEncode(<String, Object?>{'ok': true}),
            200,
            headers: <String, List<String>>{
              Headers.contentTypeHeader: <String>[Headers.jsonContentType],
            },
          );
        });

        final Response<dynamic> response = await dio.get<dynamic>(
          'https://example.com/retry',
        );

        expect(response.statusCode, 200);
        expect(requestCount, 2);
      },
    );

    test('skips multipart retries for single-use uploads', () async {
      int requestCount = 0;
      dio = buildDio(maxRetries: 2);
      dio.httpClientAdapter = _SequenceAdapter((
        final options,
        final _,
        final cancelFuture,
      ) async {
        if (cancelFuture != null) {}
        requestCount += 1;
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          message: 'offline',
        );
      });

      await expectLater(
        dio.post<dynamic>(
          'https://example.com/upload',
          data: FormData.fromMap(<String, Object>{'file': 'blob'}),
        ),
        throwsA(isA<DioException>()),
      );

      expect(requestCount, 1);
    });
  });
}
