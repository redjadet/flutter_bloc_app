import 'package:flutter_bloc_app/shared/utils/network_error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetworkErrorMapper', () {
    test('maps common error strings to friendly messages', () {
      expect(
        NetworkErrorMapper.getErrorMessage('Network connection lost'),
        'Network connection error. Please check your internet connection.',
      );
      expect(
        NetworkErrorMapper.getErrorMessage('Request timeout'),
        'Request timed out. Please try again.',
      );
      expect(
        NetworkErrorMapper.getErrorMessage('Unauthorized 401'),
        'Authentication required. Please sign in again.',
      );
      expect(
        NetworkErrorMapper.getErrorMessage('Forbidden 403'),
        "Access denied. You don't have permission for this action.",
      );
      expect(
        NetworkErrorMapper.getErrorMessage('Not found 404'),
        'The requested resource was not found.',
      );
      expect(
        NetworkErrorMapper.getErrorMessage('Server error 500'),
        'Server error. Please try again later.',
      );
    });

    test('returns fallback message for unknown errors', () {
      expect(
        NetworkErrorMapper.getErrorMessage('Something else'),
        'Something went wrong. Please try again.',
      );
      expect(
        NetworkErrorMapper.getErrorMessage(null),
        'An unknown error occurred',
      );
    });

    test('maps status codes to messages', () {
      expect(
        NetworkErrorMapper.getMessageForStatusCode(401),
        'Authentication required. Please sign in again.',
      );
      expect(
        NetworkErrorMapper.getMessageForStatusCode(404),
        'The requested resource was not found.',
      );
      expect(
        NetworkErrorMapper.getMessageForStatusCode(429),
        'Too many requests. Please wait before trying again.',
      );
      expect(
        NetworkErrorMapper.getMessageForStatusCode(418),
        'Client error. Please check your request and try again.',
      );
      expect(
        NetworkErrorMapper.getMessageForStatusCode(500),
        'Server error. Please try again later.',
      );
      expect(NetworkErrorMapper.getMessageForStatusCode(200), isNull);
    });

    test('detects network and timeout errors', () {
      expect(NetworkErrorMapper.isNetworkError('Socket error'), isTrue);
      expect(NetworkErrorMapper.isNetworkError('DNS failure'), isTrue);
      expect(NetworkErrorMapper.isNetworkError('Other error'), isFalse);

      expect(NetworkErrorMapper.isTimeoutError('Request timed out'), isTrue);
      expect(NetworkErrorMapper.isTimeoutError('timeout'), isTrue);
      expect(NetworkErrorMapper.isTimeoutError('Other error'), isFalse);
    });

    test('identifies transient status codes', () {
      expect(NetworkErrorMapper.isTransientError(408), isTrue);
      expect(NetworkErrorMapper.isTransientError(429), isTrue);
      expect(NetworkErrorMapper.isTransientError(500), isTrue);
      expect(NetworkErrorMapper.isTransientError(503), isTrue);
      expect(NetworkErrorMapper.isTransientError(200), isFalse);
    });
  });
}
