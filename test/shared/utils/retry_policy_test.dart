import 'dart:async';

import 'package:flutter_bloc_app/shared/utils/retry_policy.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_helpers.dart' show FakeTimerService;

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

    test('executeWithRetry uses timerService-backed delays', () async {
      const policy = RetryPolicy(
        maxAttempts: 3,
        baseDelay: Duration(milliseconds: 50),
        jitter: false,
      );
      final FakeTimerService fakeTimer = FakeTimerService();
      int callCount = 0;

      final Future<int> future = policy.executeWithRetry<int>(
        action: () async {
          callCount++;
          if (callCount == 1) {
            throw Exception('Temporary error');
          }
          return 42;
        },
        timerService: fakeTimer,
      );

      await Future<void>.delayed(Duration.zero);
      expect(callCount, 1);

      fakeTimer.elapse(const Duration(milliseconds: 50));
      await Future<void>.delayed(Duration.zero);

      expect(await future, 42);
      expect(callCount, 2);
    });

    test('executeWithRetry cancels during timerService-backed delay', () async {
      const policy = RetryPolicy(
        maxAttempts: 3,
        baseDelay: Duration(milliseconds: 50),
        jitter: false,
      );
      final CancelToken cancelToken = CancelToken();
      final FakeTimerService fakeTimer = FakeTimerService();
      int callCount = 0;

      final Future<int> future = policy.executeWithRetry<int>(
        action: () async {
          callCount++;
          throw Exception('Error');
        },
        cancelToken: cancelToken,
        timerService: fakeTimer,
      );

      await Future<void>.delayed(Duration.zero);
      expect(callCount, 1);

      cancelToken.cancel();
      fakeTimer.elapse(const Duration(milliseconds: 50));

      await expectLater(future, throwsA(isA<CancellationException>()));
      expect(callCount, 1);
    });

    test('calculateDelay uses exponential strategy', () {
      final Duration delay = RetryPolicy.calculateDelay(
        attempt: 2,
        baseDelay: const Duration(milliseconds: 100),
        maxDelay: const Duration(seconds: 10),
        strategy: RetryStrategy.exponential,
        jitter: false,
      );

      expect(delay, const Duration(milliseconds: 400));
    });

    test('calculateDelay uses linear strategy', () {
      final Duration delay = RetryPolicy.calculateDelay(
        attempt: 2,
        baseDelay: const Duration(milliseconds: 100),
        maxDelay: const Duration(seconds: 10),
        strategy: RetryStrategy.linear,
        jitter: false,
      );

      expect(delay, const Duration(milliseconds: 300));
    });

    test('calculateDelay uses fixed strategy', () {
      final Duration delay = RetryPolicy.calculateDelay(
        attempt: 5,
        baseDelay: const Duration(milliseconds: 100),
        maxDelay: const Duration(seconds: 10),
        strategy: RetryStrategy.fixed,
        jitter: false,
      );

      expect(delay, const Duration(milliseconds: 100));
    });

    test('calculateDelay caps delay at maxDelay when jitter is disabled', () {
      final Duration delay = RetryPolicy.calculateDelay(
        attempt: 8,
        baseDelay: const Duration(milliseconds: 100),
        maxDelay: const Duration(milliseconds: 500),
        strategy: RetryStrategy.exponential,
        jitter: false,
      );

      expect(delay, const Duration(milliseconds: 500));
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
