import 'package:flutter_bloc_app/shared/utils/in_flight_coalescer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InFlightCoalescer', () {
    test(
      'run() executes work and returns same future when in flight',
      () async {
        final InFlightCoalescer coalescer = InFlightCoalescer();
        int runs = 0;
        final Future<void> a = coalescer.run(() async {
          runs++;
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        final Future<void> b = coalescer.run(() async {
          runs++;
          await Future<void>.delayed(Duration.zero);
        });
        expect(identical(a, b), isTrue);
        await a;
        expect(runs, 1);
      },
    );

    test('run() allows new run after previous completes', () async {
      final InFlightCoalescer coalescer = InFlightCoalescer();
      int runs = 0;
      await coalescer.run(() async {
        runs++;
      });
      await coalescer.run(() async {
        runs++;
      });
      expect(runs, 2);
    });

    test('run() coalesces synchronous throws and clears afterward', () async {
      final InFlightCoalescer coalescer = InFlightCoalescer();
      int runs = 0;

      final Future<void> a = coalescer.run(() {
        runs++;
        throw StateError('boom');
      });
      final Future<void> failingExpectation = expectLater(
        a,
        throwsA(isA<StateError>()),
      );
      final Future<void> b = coalescer.run(() async {
        runs++;
      });

      expect(identical(a, b), isTrue);
      await failingExpectation;

      await coalescer.run(() async {
        runs++;
      });
      expect(runs, 2);
    });
  });

  group('KeyedInFlightCoalescer', () {
    test('run() coalesces by key', () async {
      final KeyedInFlightCoalescer<String> coalescer =
          KeyedInFlightCoalescer<String>();
      int runsA = 0;
      int runsB = 0;
      final Future<void> a1 = coalescer.run('a', () async {
        runsA++;
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      final Future<void> a2 = coalescer.run('a', () async {
        runsA++;
        await Future<void>.delayed(Duration.zero);
      });
      final Future<void> b1 = coalescer.run('b', () async {
        runsB++;
        await Future<void>.delayed(Duration.zero);
      });
      expect(identical(a1, a2), isTrue);
      expect(identical(a1, b1), isFalse);
      await Future.wait(<Future<void>>[a1, b1]);
      expect(runsA, 1);
      expect(runsB, 1);
    });

    test(
      'run() allows new run for same key after previous completes',
      () async {
        final KeyedInFlightCoalescer<String> coalescer =
            KeyedInFlightCoalescer<String>();
        int runs = 0;
        await coalescer.run('k', () async {
          runs++;
        });
        await coalescer.run('k', () async {
          runs++;
        });
        expect(runs, 2);
      },
    );

    test(
      'run() coalesces synchronous throws per key and clears afterward',
      () async {
        final KeyedInFlightCoalescer<String> coalescer =
            KeyedInFlightCoalescer<String>();
        int runs = 0;

        final Future<void> a = coalescer.run('k', () {
          runs++;
          throw StateError('boom');
        });
        final Future<void> failingExpectation = expectLater(
          a,
          throwsA(isA<StateError>()),
        );
        final Future<void> b = coalescer.run('k', () async {
          runs++;
        });

        expect(identical(a, b), isTrue);
        await failingExpectation;

        await coalescer.run('k', () async {
          runs++;
        });
        expect(runs, 2);
      },
    );
  });
}
