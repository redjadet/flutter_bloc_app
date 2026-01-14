import 'package:flutter_bloc_app/shared/utils/network_guard.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('NetworkGuard', () {
    test('execute returns response when request succeeds', () async {
      final response = http.Response('Success', 200);

      final result = await NetworkGuard.execute<Exception>(
        request: () async => response,
        timeout: const Duration(seconds: 5),
        isSuccess: (final statusCode) => statusCode == 200,
        logContext: 'test',
        onHttpFailure: (final response) => Exception('HTTP error'),
        onException: (final error) => Exception('Network error'),
      );

      expect(result.statusCode, 200);
      expect(result.body, 'Success');
    });

    test(
      'execute throws onHttpFailure when status code is not successful',
      () async {
        final response = http.Response('Error', 404);

        expect(
          () => NetworkGuard.execute<Exception>(
            request: () async => response,
            timeout: const Duration(seconds: 5),
            isSuccess: (final statusCode) => statusCode == 200,
            logContext: 'test',
            onHttpFailure: (final response) =>
                Exception('HTTP error: ${response.statusCode}'),
            onException: (final error) => Exception('Network error'),
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test(
      'execute calls onFailureLog when status code is not successful',
      () async {
        final response = http.Response('Error', 404);
        bool failureLogCalled = false;

        try {
          await NetworkGuard.execute<Exception>(
            request: () async => response,
            timeout: const Duration(seconds: 5),
            isSuccess: (final statusCode) => statusCode == 200,
            logContext: 'test',
            onHttpFailure: (final response) => Exception('HTTP error'),
            onException: (final error) => Exception('Network error'),
            onFailureLog: (final response) {
              failureLogCalled = true;
            },
          );
        } catch (_) {
          // Expected to throw
        }

        expect(failureLogCalled, isTrue);
      },
    );

    test('execute throws onException when timeout occurs', () async {
      expect(
        () => NetworkGuard.execute<Exception>(
          request: () async {
            await Future<void>.delayed(const Duration(seconds: 2));
            return http.Response('Success', 200);
          },
          timeout: const Duration(milliseconds: 100),
          isSuccess: (final statusCode) => statusCode == 200,
          logContext: 'test',
          onHttpFailure: (final response) => Exception('HTTP error'),
          onException: (final error) => Exception('Timeout error'),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('execute throws onException when request throws', () async {
      expect(
        () => NetworkGuard.execute<Exception>(
          request: () async {
            throw Exception('Connection failed');
          },
          timeout: const Duration(seconds: 5),
          isSuccess: (final statusCode) => statusCode == 200,
          logContext: 'test',
          onHttpFailure: (final response) => Exception('HTTP error'),
          onException: (final error) => Exception('Network error'),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('execute rethrows E exception when request throws E', () async {
      expect(
        () => NetworkGuard.execute<TestException>(
          request: () async {
            throw TestException('Custom error');
          },
          timeout: const Duration(seconds: 5),
          isSuccess: (final statusCode) => statusCode == 200,
          logContext: 'test',
          onHttpFailure: (final response) => TestException('HTTP error'),
          onException: (final error) => TestException('Network error'),
        ),
        throwsA(isA<TestException>()),
      );
    });
  });
}

class TestException implements Exception {
  TestException(this.message);
  final String message;
  @override
  String toString() => message;
}
