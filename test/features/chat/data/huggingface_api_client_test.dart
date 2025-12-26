import 'package:flutter_bloc_app/features/chat/data/huggingface_api_client.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class _MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
    registerFallbackValue(<String, String>{});
    registerFallbackValue('');
  });

  group('HuggingFaceApiClient', () {
    late HuggingFaceApiClient apiClient;
    late _MockHttpClient mockHttpClient;

    setUp(() {
      mockHttpClient = _MockHttpClient();
      apiClient = HuggingFaceApiClient(
        httpClient: mockHttpClient,
        apiKey: 'test-key',
      );
    });

    tearDown(() {
      apiClient.dispose();
    });

    test('handles malformed JSON responses gracefully', () async {
      // Mock response with invalid JSON
      final mockResponse = http.Response(
        '{invalid json',
        200,
        headers: {'content-type': 'application/json'},
      );

      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Should throw ChatException instead of FormatException
      expect(
        () => apiClient.postJson(
          uri: Uri.parse('https://api.example.com/test'),
          payload: {'test': 'data'},
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
      // Mock response with valid JSON
      final mockResponse = http.Response(
        '{"result": "success", "data": [1, 2, 3]}',
        200,
        headers: {'content-type': 'application/json'},
      );

      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await apiClient.postJson(
        uri: Uri.parse('https://api.example.com/test'),
        payload: {'test': 'data'},
        context: 'test',
      );

      expect(result, isA<Map<String, dynamic>>());
      expect(result['result'], equals('success'));
      expect(result['data'], equals([1, 2, 3]));
    });

    test('handles non-JSON content type', () async {
      // Mock response with non-JSON content type
      final mockResponse = http.Response(
        'plain text response',
        200,
        headers: {'content-type': 'text/plain'},
      );

      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => mockResponse);

      expect(
        () => apiClient.postJson(
          uri: Uri.parse('https://api.example.com/test'),
          payload: {'test': 'data'},
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
      // Mock response with JSON that's not a map
      final mockResponse = http.Response(
        '[1, 2, 3]',
        200,
        headers: {'content-type': 'application/json'},
      );

      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => mockResponse);

      expect(
        () => apiClient.postJson(
          uri: Uri.parse('https://api.example.com/test'),
          payload: {'test': 'data'},
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
