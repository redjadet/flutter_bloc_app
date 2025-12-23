import 'package:fake_async/fake_async.dart';
import 'package:flutter_bloc_app/shared/utils/retry_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RetryPolicy', () {
    test('returns result without retries when action succeeds', () async {
      final RetryPolicy policy = RetryPolicy(maxAttempts: 3, jitter: false);
      int calls = 0;

      final String result = await policy.executeWithRetry(
        action: () async {
          calls += 1;
          return 'ok';
        },
      );

      expect(result, 'ok');
      expect(calls, 1);
    });

    test('retries until success with linear backoff', () {
      fakeAsync((final async) {
        final RetryPolicy policy = RetryPolicy(
          maxAttempts: 3,
          baseDelay: const Duration(seconds: 1),
          strategy: RetryStrategy.linear,
          jitter: false,
        );
        int calls = 0;

        final Future<String> future = policy.executeWithRetry(
          action: () async {
            calls += 1;
            if (calls < 2) {
              throw Exception('fail');
            }
            return 'ok';
          },
        );

        String? result;
        Object? error;
        future
            .then<void>((final value) => result = value)
            .catchError((final Object err) => error = err);

        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        async.flushMicrotasks();
        expect(error, isNull);
        expect(result, 'ok');
        expect(calls, 2);
      });
    });

    test('does not retry when shouldRetry returns false', () async {
      final RetryPolicy policy = RetryPolicy(jitter: false);
      int calls = 0;

      final Future<String> future = policy.executeWithRetry(
        action: () async {
          calls += 1;
          throw Exception('fail');
        },
        shouldRetry: (Object error) => false,
      );

      await expectLater(future, throwsA(isA<Exception>()));
      expect(calls, 1);
    });

    test('throws CancellationException when cancelled before start', () async {
      final CancelToken token = CancelToken()..cancel();
      final RetryPolicy policy = RetryPolicy(jitter: false);

      await expectLater(
        policy.executeWithRetry(action: () async => 'ok', cancelToken: token),
        throwsA(isA<CancellationException>()),
      );
    });
  });
}
