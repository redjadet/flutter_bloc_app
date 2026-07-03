import 'dart:async';

import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/shared/utils/disposable_bag.dart';

/// Centralized holder for [TimerDisposable] handles with a single [dispose] that
/// disposes all and marks the manager disposed.
///
/// Use in cubits, repositories, or services that own one-or-more timer handles
/// and must ensure they don't leak across lifecycle boundaries.
///
/// If [register] is called after [dispose], the handle is disposed immediately.
///
/// For restartable timers, call [unregister] after manually disposing a handle
/// to keep the manager's internal set bounded.
class TimerHandleManager {
  final DisposableBag _disposables = DisposableBag();

  bool get isDisposed => _disposables.isDisposed;

  TimerDisposable? register(final TimerDisposable? handle) {
    if (handle == null) return null;

    if (_disposables.isDisposed) {
      handle.dispose();
      return handle;
    }

    return _disposables.trackTimer(handle);
  }

  void unregister(final TimerDisposable? handle) {
    _disposables.untrackTimer(handle);
  }

  Future<void> clear() async {
    await _disposables.clear();
  }

  Future<void> dispose() async {
    await _disposables.dispose();
  }
}
