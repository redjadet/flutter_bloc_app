import 'dart:async';

import 'package:flutter_bloc_app/shared/http/circuit_breaker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CircuitBreaker', () {
    test(
      'opens after threshold failures and recovers with successful probe',
      () async {
        final CircuitBreaker breaker = CircuitBreaker(
          key: 'test',
          failureThreshold: 1,
          window: const Duration(seconds: 1),
          // Keep this comfortably above any incidental delay between awaits in
          // the full suite to avoid flakes where the circuit transitions to
          // halfOpen earlier than intended.
          cooldown: const Duration(milliseconds: 200),
        );

        await expectLater(
          () => breaker.execute<void>(() async {
            throw StateError('fail');
          }),
          throwsA(isA<StateError>()),
        );
        expect(breaker.state, CircuitState.open);

        await expectLater(
          () => breaker.execute<void>(() async {}),
          throwsA(isA<CircuitOpenException>()),
        );

        await Future<void>.delayed(const Duration(milliseconds: 250));

        final Completer<void> probeCompleter = Completer<void>();
        final Future<void> probeFuture = breaker.execute<void>(() async {
          await probeCompleter.future;
        });

        await Future<void>.delayed(Duration.zero);
        await expectLater(
          () => breaker.execute<void>(() async {}),
          throwsA(isA<CircuitOpenException>()),
        );

        probeCompleter.complete();
        await probeFuture;

        expect(breaker.state, CircuitState.closed);
        await breaker.execute<void>(() async {});
      },
    );

    test('allows probe immediately when cooldown is zero', () async {
      final CircuitBreaker breaker = CircuitBreaker(
        key: 'zero-cooldown',
        failureThreshold: 1,
        window: const Duration(seconds: 1),
        cooldown: Duration.zero,
      );

      await expectLater(
        () => breaker.execute<void>(() async {
          throw StateError('fail');
        }),
        throwsA(isA<StateError>()),
      );
      expect(breaker.state, CircuitState.open);

      await breaker.execute<void>(() async {});
      expect(breaker.state, CircuitState.closed);
    });
  });
}
