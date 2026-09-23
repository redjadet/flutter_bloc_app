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
