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
          cooldown: const Duration(milliseconds: 20),
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

        await Future<void>.delayed(const Duration(milliseconds: 25));

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
  });
}
