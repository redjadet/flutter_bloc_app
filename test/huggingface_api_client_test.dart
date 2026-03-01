import 'dart:convert';

import 'package:flutter_bloc_app/features/chat/data/huggingface_api_client.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('HuggingFaceApiClient', () {
    test('cleans whitespace API keys', () {
      final client = HuggingFaceApiClient(apiKey: '   ');
      expect(client.hasApiKey, isFalse);
    });

    test('throws when response content-type is not JSON', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          'binary',
          200,
          headers: {'content-type': 'text/plain'},
        );
      });
      final apiClient = HuggingFaceApiClient(
        httpClient: mockClient,
        apiKey: 'token',
      );

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
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode(<int>[1, 2, 3]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final apiClient = HuggingFaceApiClient(
        httpClient: mockClient,
        apiKey: 'token',
      );

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
        late http.Request capturedRequest;
        final mockClient = MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode(<String, dynamic>{'ok': true}),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });
        final apiClient = HuggingFaceApiClient(
          httpClient: mockClient,
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
        expect(capturedRequest.headers['Authorization'], 'Bearer secret-token');
        expect(capturedRequest.body, contains('"prompt":"hello"'));
      },
    );

    test('throws friendly message when rate limited', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          '{}',
          429,
          headers: {'content-type': 'application/json'},
        );
      });
      final apiClient = HuggingFaceApiClient(httpClient: mockClient);

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
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode(<String, String>{'error': 'bad request'}),
          400,
          headers: {'content-type': 'application/json'},
        );
      });
      final apiClient = HuggingFaceApiClient(httpClient: mockClient);

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
      final mockClient = MockClient((request) async {
        throw http.ClientException('no network');
      });
      final apiClient = HuggingFaceApiClient(httpClient: mockClient);

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
  });

  group('HuggingFaceApiClient.formatError', () {
    test('returns authentication hint for 401 without detail', () {
      final http.Response response = http.Response('{"error":null}', 401);
      expect(
        HuggingFaceApiClient.formatError(response),
        'Chat service authentication failed (HTTP 401). '
        'Check your Hugging Face token or model.',
      );
    });

    test('includes detail message when present', () {
      final http.Response response = http.Response(
        jsonEncode(<String, String>{'message': 'model missing'}),
        403,
      );
      expect(
        HuggingFaceApiClient.formatError(response),
        'Chat service authentication failed (HTTP 403): model missing. '
        'Verify your Hugging Face token/model access.',
      );
    });

    test('falls back to generic message when parsing fails', () {
      final http.Response response = http.Response('unparsable', 500);
      expect(
        HuggingFaceApiClient.formatError(response),
        'Chat service error (HTTP 500): unparsable',
      );
    });

    test('stringifies non-string error details when present', () {
      final http.Response response = http.Response(
        jsonEncode(<String, Object?>{
          'error': <String, Object?>{'code': 'MODEL_UNAVAILABLE'},
        }),
        400,
      );
      expect(
        HuggingFaceApiClient.formatError(response),
        'Chat service error (HTTP 400): {code: MODEL_UNAVAILABLE}',
      );
    });
  });
}
