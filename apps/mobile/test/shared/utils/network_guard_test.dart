import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/shared/utils/network_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetworkGuard', () {
    test('executeDio returns response when request succeeds', () async {
      final response = Response<String>(
        requestOptions: RequestOptions(path: '/'),
        data: 'Success',
        statusCode: 200,
      );

      final result = await NetworkGuard.executeDio<String, Exception>(
        request: () async => response,
        timeout: const Duration(seconds: 5),
        isSuccess: (final statusCode) => statusCode == 200,
        logContext: 'test',
        onHttpFailure: (final res) => Exception('HTTP error'),
        onException: (final error) => Exception('Network error'),
      );

      expect(result.statusCode, 200);
      expect(result.data, 'Success');
    });

    test(
      'executeDio throws onHttpFailure when status code is not successful',
      () async {
        final response = Response<String>(
          requestOptions: RequestOptions(path: '/'),
          data: 'Error',
          statusCode: 404,
        );

        expect(
          () => NetworkGuard.executeDio<String, Exception>(
            request: () async => response,
            timeout: const Duration(seconds: 5),
            isSuccess: (final statusCode) => statusCode == 200,
            logContext: 'test',
            onHttpFailure: (final res) =>
                Exception('HTTP error: ${res.statusCode}'),
            onException: (final error) => Exception('Network error'),
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test(
      'executeDio calls onFailureLog when status code is not successful',
      () async {
        final response = Response<String>(
          requestOptions: RequestOptions(path: '/'),
          data: 'Error',
          statusCode: 404,
        );
        bool failureLogCalled = false;

        try {
          await NetworkGuard.executeDio<String, Exception>(
            request: () async => response,
            timeout: const Duration(seconds: 5),
            isSuccess: (final statusCode) => statusCode == 200,
            logContext: 'test',
            onHttpFailure: (final res) => Exception('HTTP error'),
            onException: (final error) => Exception('Network error'),
            onFailureLog: (final res) {
              failureLogCalled = true;
            },
          );
        } catch (_) {
          // Expected to throw
        }

        expect(failureLogCalled, isTrue);
      },
    );

    test('executeDio throws onException when timeout occurs', () async {
      expect(
        () => NetworkGuard.executeDio<String, Exception>(
          request: () async {
            await Future<void>.delayed(const Duration(seconds: 2));
            return Response<String>(
              requestOptions: RequestOptions(path: '/'),
              data: 'Success',
              statusCode: 200,
            );
          },
          timeout: const Duration(milliseconds: 100),
          isSuccess: (final statusCode) => statusCode == 200,
          logContext: 'test',
          onHttpFailure: (final res) => Exception('HTTP error'),
          onException: (final error) => Exception('Timeout error'),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('executeDio throws onException when request throws', () async {
      expect(
        () => NetworkGuard.executeDio<String, Exception>(
          request: () async {
            throw Exception('Connection failed');
          },
          timeout: const Duration(seconds: 5),
          isSuccess: (final statusCode) => statusCode == 200,
          logContext: 'test',
          onHttpFailure: (final res) => Exception('HTTP error'),
          onException: (final error) => Exception('Network error'),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('executeDio rethrows E exception when request throws E', () async {
      expect(
        () => NetworkGuard.executeDio<String, TestException>(
          request: () async {
            throw TestException('Custom error');
          },
          timeout: const Duration(seconds: 5),
          isSuccess: (final statusCode) => statusCode == 200,
          logContext: 'test',
          onHttpFailure: (final res) => TestException('HTTP error'),
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
