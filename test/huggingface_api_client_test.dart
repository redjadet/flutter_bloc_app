import 'dart:convert';

import 'package:flutter_bloc_app/features/chat/data/huggingface_api_client.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
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

      await expectLater(
        apiClient.postJson(
          uri: Uri.parse('https://example.com'),
          payload: const <String, dynamic>{},
          context: 'test',
        ),
        throwsA(isA<ChatException>()),
      );
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
}
