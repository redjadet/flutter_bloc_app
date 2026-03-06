import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_api_client.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
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
    late HuggingFaceApiClient apiClient;

    tearDown(() {
      apiClient.dispose();
    });

    test('handles malformed JSON responses gracefully', () async {
      final Dio mockDio = createMockDio('{invalid json', 200);
      apiClient = HuggingFaceApiClient(dio: mockDio, apiKey: 'test-key');

      expect(
        () => apiClient.postJson(
          uri: Uri.parse('https://api.example.com/test'),
          payload: <String, dynamic>{'test': 'data'},
          context: 'test',
        ),
        throwsA(
          isA<ChatException>().having(
            (e) => e.message,
            'message',
            contains('invalid response format'),
          ),
        ),
      );
    });

    test('handles valid JSON responses correctly', () async {
      final Dio mockDio = createMockDio(
        '{"result": "success", "data": [1, 2, 3]}',
        200,
      );
      apiClient = HuggingFaceApiClient(dio: mockDio, apiKey: 'test-key');

      final result = await apiClient.postJson(
        uri: Uri.parse('https://api.example.com/test'),
        payload: <String, dynamic>{'test': 'data'},
        context: 'test',
      );

      expect(result, isA<Map<String, dynamic>>());
      expect(result['result'], equals('success'));
      expect(result['data'], equals([1, 2, 3]));
    });

    test('handles non-JSON content type', () async {
      final Dio mockDio = createMockDio(
        'plain text response',
        200,
        contentType: 'text/plain',
      );
      apiClient = HuggingFaceApiClient(dio: mockDio, apiKey: 'test-key');

      expect(
        () => apiClient.postJson(
          uri: Uri.parse('https://api.example.com/test'),
          payload: <String, dynamic>{'test': 'data'},
          context: 'test',
        ),
        throwsA(
          isA<ChatException>().having(
            (e) => e.message,
            'message',
            contains('unsupported content'),
          ),
        ),
      );
    });

    test('handles non-map JSON responses', () async {
      final Dio mockDio = createMockDio('[1, 2, 3]', 200);
      apiClient = HuggingFaceApiClient(dio: mockDio, apiKey: 'test-key');

      expect(
        () => apiClient.postJson(
          uri: Uri.parse('https://api.example.com/test'),
          payload: <String, dynamic>{'test': 'data'},
          context: 'test',
        ),
        throwsA(
          isA<ChatException>().having(
            (e) => e.message,
            'message',
            contains('unexpected payload'),
          ),
        ),
      );
    });
  });
}
