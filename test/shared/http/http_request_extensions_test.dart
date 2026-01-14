import 'package:flutter_bloc_app/shared/http/http_request_extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('HttpRequestExtensions', () {
    test('clone creates copy of Request with same properties', () {
      final original = http.Request(
        'POST',
        Uri.parse('https://example.com/api'),
      );
      original.headers['Content-Type'] = 'application/json';
      original.body = '{"key": "value"}';

      final cloned = original.clone() as http.Request;

      expect(cloned.method, 'POST');
      expect(cloned.url, Uri.parse('https://example.com/api'));
      expect(cloned.headers['Content-Type'], 'application/json');
      expect(cloned.body, '{"key": "value"}');
      expect(cloned, isNot(same(original)));
    });

    test('clone copies headers from original request', () {
      final original = http.Request('GET', Uri.parse('https://example.com'));
      original.headers['Authorization'] = 'Bearer token123';
      original.headers['X-Custom-Header'] = 'custom-value';

      final cloned = original.clone() as http.Request;

      expect(cloned.headers['Authorization'], 'Bearer token123');
      expect(cloned.headers['X-Custom-Header'], 'custom-value');
    });

    test('clone handles empty body', () {
      final original = http.Request('GET', Uri.parse('https://example.com'));

      final cloned = original.clone() as http.Request;

      expect(cloned.body, isEmpty);
    });

    test('clone throws UnsupportedError for MultipartRequest', () {
      final multipart = http.MultipartRequest(
        'POST',
        Uri.parse('https://example.com/upload'),
      );

      expect(() => multipart.clone(), throwsA(isA<UnsupportedError>()));
    });

    test('clone throws UnsupportedError for unknown request types', () {
      // Create a mock request that's not Request or MultipartRequest
      // We'll use StreamedRequest which should also throw
      final streamed = http.StreamedRequest(
        'POST',
        Uri.parse('https://example.com'),
      );

      expect(() => streamed.clone(), throwsA(isA<UnsupportedError>()));
    });
  });
}
