import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/shared/utils/timer_handle_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimerHandleManager', () {
    test(
      'clear disposes current handles without disposing the manager',
      () async {
        final TimerHandleManager manager = TimerHandleManager();
        final _CountingTimerDisposable first = _CountingTimerDisposable();
        final _CountingTimerDisposable second = _CountingTimerDisposable();

        manager.register(first);
        await manager.clear();
        manager.register(second);
        await manager.dispose();

        expect(manager.isDisposed, isTrue);
        expect(first.disposeCount, 1);
        expect(second.disposeCount, 1);
      },
    );

    test(
      'unregister prevents a manually disposed handle from being disposed again',
      () async {
        final TimerHandleManager manager = TimerHandleManager();
        final _CountingTimerDisposable handle = _CountingTimerDisposable();

        manager.register(handle);
        handle.dispose();
        manager.unregister(handle);
        await manager.dispose();

        expect(handle.disposeCount, 1);
      },
    );

    test('register after dispose disposes immediately', () async {
      final TimerHandleManager manager = TimerHandleManager();
      final _CountingTimerDisposable handle = _CountingTimerDisposable();

      await manager.dispose();
      manager.register(handle);

      expect(handle.disposeCount, 1);
    });
  });
}

class _CountingTimerDisposable implements TimerDisposable {
  int disposeCount = 0;

  @override
  void dispose() {
    disposeCount++;
  }
}
