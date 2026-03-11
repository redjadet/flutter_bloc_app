import 'package:flutter_bloc_app/shared/utils/http_request_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HttpRequestFailure', () {
    test('stores status code, message, and retry-after hint', () {
      const HttpRequestFailure failure = HttpRequestFailure(
        429,
        'Too many requests',
        retryAfterSeconds: 120,
      );

      expect(failure.statusCode, 429);
      expect(failure.message, 'Too many requests');
      expect(failure.retryAfterSeconds, 120);
    });

    test('formats toString with status code and message', () {
      const HttpRequestFailure failure = HttpRequestFailure(
        503,
        'Service unavailable',
      );

      expect(
        failure.toString(),
        'HttpRequestFailure(503): Service unavailable',
      );
    });
  });
}
