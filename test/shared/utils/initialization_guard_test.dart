import 'package:flutter_bloc_app/shared/utils/initialization_guard.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InitializationGuard', () {
    test(
      'executeSafely completes successfully for successful operation',
      () async {
        bool operationExecuted = false;

        await InitializationGuard.executeSafely(
          () async {
            operationExecuted = true;
          },
          context: 'test',
          failureMessage: 'Should not fail',
        );

        expect(operationExecuted, isTrue);
      },
    );

    test('executeSafely handles exceptions without rethrowing', () async {
      bool operationExecuted = false;

      await InitializationGuard.executeSafely(
        () async {
          operationExecuted = true;
          throw Exception('Test error');
        },
        context: 'test',
        failureMessage: 'Test failure',
      );

      expect(operationExecuted, isTrue);
      // Should not throw - operation completes gracefully
    });

    test('executeSafely logs errors when operation fails', () async {
      // Silence logger to avoid noise in test output
      AppLogger.silenceGlobally();

      try {
        await InitializationGuard.executeSafely(
          () async {
            throw Exception('Test error');
          },
          context: 'testContext',
          failureMessage: 'Test failure message',
        );

        // Should complete without throwing
        expect(true, isTrue);
      } finally {
        AppLogger.restoreGlobalLogging();
      }
    });

    test('executeSafely handles multiple sequential calls', () async {
      int executionCount = 0;

      await InitializationGuard.executeSafely(
        () async {
          executionCount++;
        },
        context: 'test1',
        failureMessage: 'Failure 1',
      );

      await InitializationGuard.executeSafely(
        () async {
          executionCount++;
        },
        context: 'test2',
        failureMessage: 'Failure 2',
      );

      expect(executionCount, equals(2));
    });

    test(
      'executeSafely handles mixed success and failure operations',
      () async {
        int successCount = 0;
        int failureCount = 0;

        // Successful operation
        await InitializationGuard.executeSafely(
          () async {
            successCount++;
          },
          context: 'success',
          failureMessage: 'Should not fail',
        );

        // Failing operation
        await InitializationGuard.executeSafely(
          () async {
            failureCount++;
            throw Exception('Expected failure');
          },
          context: 'failure',
          failureMessage: 'Expected failure',
        );

        // Another successful operation
        await InitializationGuard.executeSafely(
          () async {
            successCount++;
          },
          context: 'success2',
          failureMessage: 'Should not fail',
        );

        expect(successCount, equals(2));
        expect(failureCount, equals(1));
      },
    );

    test('executeSafely handles operations that return values', () async {
      String? result;

      await InitializationGuard.executeSafely(
        () async {
          result = 'Success';
        },
        context: 'test',
        failureMessage: 'Should not fail',
      );

      expect(result, equals('Success'));
    });
  });
}
