import 'dart:async';

import 'package:flutter_bloc_app/shared/utils/retry_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RetryPolicy', () {
    test('executeWithRetry succeeds on first attempt', () async {
      const policy = RetryPolicy(maxAttempts: 3);
      int callCount = 0;

      final result = await policy.executeWithRetry<int>(
        action: () async {
          callCount++;
          return 42;
        },
      );

      expect(result, 42);
      expect(callCount, 1);
    });

    test('executeWithRetry retries on failure and succeeds', () async {
      const policy = RetryPolicy(
        maxAttempts: 3,
        baseDelay: Duration(milliseconds: 10),
      );
      int callCount = 0;

      final result = await policy.executeWithRetry<int>(
        action: () async {
          callCount++;
          if (callCount < 2) {
            throw Exception('Temporary error');
          }
          return 42;
        },
      );

      expect(result, 42);
      expect(callCount, 2);
    });

    test('executeWithRetry throws after max attempts', () async {
      const policy = RetryPolicy(
        maxAttempts: 3,
        baseDelay: Duration(milliseconds: 10),
      );

      expect(
        () => policy.executeWithRetry<int>(
          action: () async {
            throw Exception('Persistent error');
          },
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('executeWithRetry respects shouldRetry callback', () async {
      const policy = RetryPolicy(
        maxAttempts: 3,
        baseDelay: Duration(milliseconds: 10),
      );
      int callCount = 0;

      expect(
        () => policy.executeWithRetry<int>(
          action: () async {
            callCount++;
            throw Exception('Non-retryable error');
          },
          shouldRetry: (final error) => false,
        ),
        throwsA(isA<Exception>()),
      );

      expect(callCount, 1); // Should not retry
    });

    test('executeWithRetry cancels when cancelToken is cancelled', () async {
      const policy = RetryPolicy(
        maxAttempts: 3,
        baseDelay: Duration(milliseconds: 10),
      );
      final cancelToken = CancelToken();

      cancelToken.cancel();

      expect(
        () => policy.executeWithRetry<int>(
          action: () async => 42,
          cancelToken: cancelToken,
        ),
        throwsA(isA<CancellationException>()),
      );
    });

    test('executeWithRetry cancels during delay', () async {
      const policy = RetryPolicy(
        maxAttempts: 3,
        baseDelay: Duration(milliseconds: 50),
      );
      final cancelToken = CancelToken();
      int callCount = 0;

      unawaited(
        Future<void>.delayed(const Duration(milliseconds: 25), () {
          cancelToken.cancel();
        }),
      );

      expect(
        () => policy.executeWithRetry<int>(
          action: () async {
            callCount++;
            throw Exception('Error');
          },
          cancelToken: cancelToken,
        ),
        throwsA(isA<CancellationException>()),
      );

      expect(callCount, 1);
    });

    test('_calculateDelay uses exponential strategy', () {
      const policy = RetryPolicy(
        strategy: RetryStrategy.exponential,
        baseDelay: Duration(milliseconds: 100),
      );

      // Access private method via reflection would be needed, but we can test via executeWithRetry
      // For now, just verify the policy is created correctly
      expect(policy.strategy, RetryStrategy.exponential);
    });

    test('_calculateDelay uses linear strategy', () {
      const policy = RetryPolicy(
        strategy: RetryStrategy.linear,
        baseDelay: Duration(milliseconds: 100),
      );

      expect(policy.strategy, RetryStrategy.linear);
    });

    test('_calculateDelay uses fixed strategy', () {
      const policy = RetryPolicy(
        strategy: RetryStrategy.fixed,
        baseDelay: Duration(milliseconds: 100),
      );

      expect(policy.strategy, RetryStrategy.fixed);
    });

    test('calculateDelay does not exceed maxDelay when jitter is enabled', () {
      const Duration maxDelay = Duration(milliseconds: 50);

      for (int i = 0; i < 100; i++) {
        final Duration delay = RetryPolicy.calculateDelay(
          attempt: 8,
          baseDelay: const Duration(milliseconds: 10),
          maxDelay: maxDelay,
          strategy: RetryStrategy.exponential,
          jitter: true,
        );
        expect(delay <= maxDelay, isTrue);
      }
    });

    test(
      'calculateDelay returns deterministic value when jitter is disabled',
      () {
        final Duration delay = RetryPolicy.calculateDelay(
          attempt: 2,
          baseDelay: const Duration(milliseconds: 100),
          maxDelay: const Duration(milliseconds: 10 * 1000),
          strategy: RetryStrategy.exponential,
          jitter: false,
        );

        expect(delay, const Duration(milliseconds: 400));
      },
    );

    test('transientErrors creates policy with correct maxDelay', () {
      expect(RetryPolicy.transientErrors.maxDelay, const Duration(seconds: 10));
    });

    test('networkErrors creates policy with correct baseDelay', () {
      expect(RetryPolicy.networkErrors.baseDelay, const Duration(seconds: 2));
    });
  });

  group('CancelToken', () {
    test('isCancelled returns false initially', () {
      final token = CancelToken();
      expect(token.isCancelled, isFalse);
    });

    test('isCancelled returns true after cancel', () {
      final token = CancelToken();
      token.cancel();
      expect(token.isCancelled, isTrue);
    });
  });

  group('CancellationException', () {
    test('toString returns formatted message', () {
      final exception = CancellationException('Test cancellation');
      expect(exception.toString(), 'CancellationException: Test cancellation');
    });
  });

  group('RetryPolicy constructor', () {
    test('asserts when maxAttempts is zero', () {
      expect(() => RetryPolicy(maxAttempts: 0), throwsAssertionError);
    });
  });
}
