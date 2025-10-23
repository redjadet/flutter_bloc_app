import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';

import '../../test_helpers.dart';

void main() {
  group('DefaultTimerService', () {
    test('periodic timer fires at the specified interval', () {
      fakeAsync((async) {
        final timerService = DefaultTimerService();
        var count = 0;
        final timer = timerService.periodic(
          const Duration(seconds: 1),
          () => count++,
        );

        expect(count, 0);

        async.elapse(const Duration(milliseconds: 500));
        expect(count, 0);

        async.elapse(const Duration(milliseconds: 500));
        expect(count, 1);

        async.elapse(const Duration(seconds: 1));
        expect(count, 2);

        timer.dispose();
      });
    });

    test('dispose cancels the timer', () {
      fakeAsync((async) {
        final timerService = DefaultTimerService();
        var count = 0;
        final timer = timerService.periodic(
          const Duration(seconds: 1),
          () => count++,
        );

        timer.dispose();
        async.elapse(const Duration(seconds: 2));

        expect(count, 0);
      });
    });

    test('runOnce fires after delay', () {
      fakeAsync((async) {
        final timerService = DefaultTimerService();
        var count = 0;
        timerService.runOnce(const Duration(milliseconds: 500), () => count++);

        async.elapse(const Duration(milliseconds: 499));
        expect(count, 0);

        async.elapse(const Duration(milliseconds: 1));
        expect(count, 1);
      });
    });

    test('runOnce can be cancelled', () {
      fakeAsync((async) {
        final timerService = DefaultTimerService();
        var count = 0;
        final disposable = timerService.runOnce(
          const Duration(milliseconds: 500),
          () => count++,
        );

        disposable.dispose();
        async.elapse(const Duration(milliseconds: 600));

        expect(count, 0);
      });
    });
  });

  group('FakeTimerService', () {
    test('periodic timer fires deterministically', () {
      final timerService = FakeTimerService();
      var count = 0;
      timerService.periodic(const Duration(seconds: 1), () => count++);

      expect(count, 0);

      timerService.tick();
      expect(count, 1);

      timerService.tick(2);
      expect(count, 3);
    });

    test('dispose cancels the fake timer', () {
      final timerService = FakeTimerService();
      var count = 0;
      final disposable = timerService.periodic(
        const Duration(seconds: 1),
        () => count++,
      );

      disposable.dispose();
      timerService.tick(3);

      expect(count, 0);
    });

    test('runOnce fires after elapsing fake time', () {
      final timerService = FakeTimerService();
      var count = 0;
      timerService.runOnce(const Duration(milliseconds: 500), () => count++);

      timerService.elapse(const Duration(milliseconds: 499));
      expect(count, 0);

      timerService.elapse(const Duration(milliseconds: 1));
      expect(count, 1);
    });

    test('runOnce cancellation prevents callback', () {
      final timerService = FakeTimerService();
      var count = 0;
      final disposable = timerService.runOnce(
        const Duration(milliseconds: 500),
        () => count++,
      );

      disposable.dispose();
      timerService.elapse(const Duration(milliseconds: 600));

      expect(count, 0);
    });

    test('elapse advances periodic timers respecting intervals', () {
      final timerService = FakeTimerService();
      var count = 0;
      timerService.periodic(const Duration(milliseconds: 250), () => count++);

      timerService.elapse(const Duration(milliseconds: 1000));

      expect(count, 4);
    });
  });
}
