import 'dart:async';

mixin TimerDisposable {
  void dispose();
}

/// Abstraction over periodic timers to make time deterministic in tests.
mixin TimerService {
  /// Starts a periodic timer and returns a disposable handle to cancel it.
  TimerDisposable periodic(
    final Duration interval,
    final void Function() onTick,
  );

  /// Runs a single-shot timer after [delay] and returns a disposable handle.
  TimerDisposable runOnce(
    final Duration delay,
    final void Function() onComplete,
  );
}

class _TimerHandle implements TimerDisposable {
  _TimerHandle(this._timer);
  final Timer _timer;
  @override
  void dispose() => _timer.cancel();
}

class DefaultTimerService implements TimerService {
  @override
  TimerDisposable periodic(
    final Duration interval,
    final void Function() onTick,
  ) {
    final timer = Timer.periodic(interval, (_) => onTick());
    return _TimerHandle(timer);
  }

  @override
  TimerDisposable runOnce(
    final Duration delay,
    final void Function() onComplete,
  ) {
    final timer = Timer(delay, onComplete);
    return _TimerHandle(timer);
  }
}
