import 'package:flutter_bloc_app/app/utils/cubit_async_operations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utilities/utilities.dart';

void main() {
  group('CubitExceptionHandler', () {
    test('toFailure maps HttpRequestFailure and generic errors', () {
      final CubitFailure httpFailure = CubitExceptionHandler.toFailure(
        const HttpRequestFailure(503, 'unavailable'),
        StackTrace.current,
      );
      expect(httpFailure.appError, isA<NetworkError>());
      expect(httpFailure.message, isNotEmpty);

      final CubitFailure plain = CubitExceptionHandler.toFailure(
        Exception('boom'),
        null,
      );
      expect(plain.message, contains('boom'));
      expect(plain.stackTrace, isNull);
      expect(plain.appError, isA<UnknownError>());
    });

    test('onFailure short-circuits onError and onAppError', () async {
      var onFailureCalls = 0;
      var onErrorCalls = 0;
      var onAppErrorCalls = 0;

      await CubitExceptionHandler.executeAsync<int>(
        operation: () async => throw Exception('fail'),
        onSuccess: (_) {},
        onError: (_) {
          onErrorCalls += 1;
        },
        onAppError: (_) {
          onAppErrorCalls += 1;
        },
        onFailure: (_) {
          onFailureCalls += 1;
        },
        logContext: 'CubitExceptionHandlerTest.onFailure',
        logErrors: false,
      );

      expect(onFailureCalls, 1);
      expect(onErrorCalls, 0);
      expect(onAppErrorCalls, 0);
    });

    test('onFailure-only succeeds without onError', () async {
      CubitFailure? captured;
      await CubitExceptionHandler.executeAsyncVoid(
        operation: () async => throw Exception('only-failure'),
        onFailure: (failure) {
          captured = failure;
        },
        logContext: 'CubitExceptionHandlerTest.onFailureOnly',
        logErrors: false,
      );

      expect(captured, isNotNull);
      expect(captured!.message, contains('only-failure'));
      expect(captured!.appError, isA<UnknownError>());
    });

    test('onError-only still works for legacy call sites', () async {
      String? message;
      await CubitExceptionHandler.executeAsync<int>(
        operation: () async => throw Exception('legacy'),
        onSuccess: (_) {},
        onError: (errorMessage) {
          message = errorMessage;
        },
        logContext: 'CubitExceptionHandlerTest.onErrorOnly',
        logErrors: false,
      );

      expect(message, contains('legacy'));
    });

    test(
      'neither onFailure nor onError throws StateError before normalize',
      () {
        expect(
          () => CubitExceptionHandler.handleException(
            Exception('missing'),
            StackTrace.current,
            'CubitExceptionHandlerTest.neither',
            logErrors: false,
          ),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              contains('requires onFailure or onError'),
            ),
          ),
        );
      },
    );

    test(
      'executeAsync neither callback throws before operation runs',
      () async {
        var operationCalls = 0;
        await expectLater(
          () => CubitExceptionHandler.executeAsync<int>(
            operation: () async {
              operationCalls += 1;
              return 1;
            },
            onSuccess: (_) {},
            logContext: 'CubitExceptionHandlerTest.executeAsyncNeither',
            logErrors: false,
          ),
          throwsA(isA<StateError>()),
        );
        expect(operationCalls, 0);
      },
    );

    test(
      'executeAsyncVoid neither callback throws before operation runs',
      () async {
        var operationCalls = 0;
        await expectLater(
          () => CubitExceptionHandler.executeAsyncVoid(
            operation: () async {
              operationCalls += 1;
            },
            logContext: 'CubitExceptionHandlerTest.executeAsyncVoidNeither',
            logErrors: false,
          ),
          throwsA(isA<StateError>()),
        );
        expect(operationCalls, 0);
      },
    );

    test('logErrors:false skips default AppLogger.error path with onError', () {
      // Smoke: handler completes without throwing when logErrors is false.
      CubitExceptionHandler.handleException(
        Exception('quiet'),
        StackTrace.current,
        'CubitExceptionHandlerTest.quiet',
        onError: (_) {},
        logErrors: false,
      );
    });
  });
}
