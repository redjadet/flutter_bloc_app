import 'dart:convert';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_api_client.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_test/flutter_test.dart';

Dio createMockDio(
  final String body,
  final int statusCode, {
  final String contentType = 'application/json',
}) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(
          Response<String>(
            requestOptions: options,
            data: body,
            statusCode: statusCode,
            headers: Headers.fromMap({
              'content-type': [contentType],
            }),
          ),
        );
      },
    ),
  );
  return dio;
}

void main() {
  group('HuggingFaceApiClient', () {
    test('cleans whitespace API keys', () {
      final client = HuggingFaceApiClient(apiKey: '   ');
      expect(client.hasApiKey, isFalse);
    });

    test('throws when response content-type is not JSON', () async {
      final mockDio = createMockDio('binary', 200, contentType: 'text/plain');
      final apiClient = HuggingFaceApiClient(dio: mockDio, apiKey: 'token');

      await AppLogger.silenceAsync(() async {
        await expectLater(
          apiClient.postJson(
            uri: Uri.parse('https://example.com'),
            payload: const <String, dynamic>{},
            context: 'test',
          ),
          throwsA(isA<ChatException>()),
        );
      });
    });

    test('throws when response body is not a JSON map', () async {
      final mockDio = createMockDio(jsonEncode(<int>[1, 2, 3]), 200);
      final apiClient = HuggingFaceApiClient(dio: mockDio, apiKey: 'token');

      await AppLogger.silenceAsync(() async {
        await expectLater(
          apiClient.postJson(
            uri: Uri.parse('https://example.com'),
            payload: const <String, dynamic>{},
            context: 'test',
          ),
          throwsA(isA<ChatException>()),
        );
      });
    });

    test(
      'includes authorization header and returns JSON map on success',
      () async {
        RequestOptions? capturedOptions;
        final dio = Dio();
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              capturedOptions = options;
              handler.resolve(
                Response<String>(
                  requestOptions: options,
                  data: jsonEncode(<String, dynamic>{'ok': true}),
                  statusCode: 200,
                  headers: Headers.fromMap({
                    'content-type': ['application/json; charset=utf-8'],
                  }),
                ),
              );
            },
          ),
        );
        final apiClient = HuggingFaceApiClient(
          dio: dio,
          apiKey: ' secret-token ',
        );

        final Map<String, dynamic> result = await AppLogger.silenceAsync(() {
          return apiClient.postJson(
            uri: Uri.parse('https://example.com'),
            payload: const <String, dynamic>{'prompt': 'hello'},
            context: 'unit',
          );
        });

        expect(result['ok'], isTrue);
        expect(
          capturedOptions?.headers['Authorization'],
          'Bearer secret-token',
        );
        expect(capturedOptions?.data, contains('"prompt":"hello"'));
      },
    );

    test('throws friendly message when rate limited', () async {
      final mockDio = createMockDio('{}', 429);
      final apiClient = HuggingFaceApiClient(dio: mockDio);

      await AppLogger.silenceAsync(() async {
        await expectLater(
          () => apiClient.postJson(
            uri: Uri.parse('https://example.com'),
            payload: const <String, dynamic>{},
            context: 'rate',
          ),
          throwsA(
            isA<ChatException>().having(
              (ChatException error) => error.message,
              'message',
              contains('rate limit'),
            ),
          ),
        );
      });
    });

    test('wraps HTTP errors with formatted message', () async {
      final mockDio = createMockDio(
        jsonEncode(<String, String>{'error': 'bad request'}),
        400,
      );
      final apiClient = HuggingFaceApiClient(dio: mockDio);

      await AppLogger.silenceAsync(() async {
        await expectLater(
          () => apiClient.postJson(
            uri: Uri.parse('https://example.com'),
            payload: const <String, dynamic>{},
            context: 'http',
          ),
          throwsA(
            isA<ChatException>().having(
              (ChatException error) => error.message,
              'message',
              'Chat service error (HTTP 400): bad request',
            ),
          ),
        );
      });
    });

    test('wraps unexpected exceptions in generic ChatException', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (_, handler) {
            handler.reject(
              DioException(
                requestOptions: RequestOptions(path: 'https://example.com'),
                error: Exception('no network'),
              ),
            );
          },
        ),
      );
      final apiClient = HuggingFaceApiClient(dio: dio);

      await AppLogger.silenceAsync(() async {
        await expectLater(
          () => apiClient.postJson(
            uri: Uri.parse('https://example.com'),
            payload: const <String, dynamic>{},
            context: 'network',
          ),
          throwsA(
            isA<ChatException>().having(
              (ChatException error) => error.message,
              'message',
              'Failed to contact chat service.',
            ),
          ),
        );
      });
    });

    test(
      'wraps timeout exceptions with timeout-specific ChatException',
      () async {
        final dio = Dio();
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (_, handler) {
              handler.reject(
                DioException(
                  requestOptions: RequestOptions(path: 'https://example.com'),
                  type: DioExceptionType.connectionTimeout,
                  error: TimeoutException('timed out'),
                ),
              );
            },
          ),
        );
        final apiClient = HuggingFaceApiClient(dio: dio);

        await AppLogger.silenceAsync(() async {
          await expectLater(
            () => apiClient.postJson(
              uri: Uri.parse('https://example.com'),
              payload: const <String, dynamic>{},
              context: 'timeout',
            ),
            throwsA(
              isA<ChatException>().having(
                (ChatException error) => error.message,
                'message',
                'Chat service timed out.',
              ),
            ),
          );
        });
      },
    );
  });

  group('HuggingFaceApiClient.formatError', () {
    Response<String> response(int statusCode, String data) => Response<String>(
      requestOptions: RequestOptions(path: '/'),
      data: data,
      statusCode: statusCode,
    );

    test('returns authentication hint for 401 without detail', () {
      expect(
        HuggingFaceApiClient.formatError(response(401, '{"error":null}')),
        'Chat service authentication failed (HTTP 401). '
        'Check your Hugging Face token or model.',
      );
    });

    test('includes detail message when present', () {
      expect(
        HuggingFaceApiClient.formatError(
          response(
            403,
            jsonEncode(<String, String>{'message': 'model missing'}),
          ),
        ),
        'Chat service authentication failed (HTTP 403): model missing. '
        'Verify your Hugging Face token/model access.',
      );
    });

    test('treats 404 as generic service error, not auth failure', () {
      expect(
        HuggingFaceApiClient.formatError(
          response(
            404,
            jsonEncode(<String, String>{'message': 'model missing'}),
          ),
        ),
        'Chat service error (HTTP 404): model missing',
      );
    });

    test('falls back to generic message when parsing fails', () {
      expect(
        HuggingFaceApiClient.formatError(response(500, 'unparsable')),
        'Chat service error (HTTP 500): unparsable',
      );
    });

    test('stringifies non-string error details when present', () {
      expect(
        HuggingFaceApiClient.formatError(
          response(
            400,
            jsonEncode(<String, Object?>{
              'error': <String, Object?>{'code': 'MODEL_UNAVAILABLE'},
            }),
          ),
        ),
        'Chat service error (HTTP 400): {code: MODEL_UNAVAILABLE}',
      );
    });
  });
}
