import 'dart:async';

import 'package:flutter_bloc_app/core/time/timer_service.dart';

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
  bool _disposed = false;
  final Set<TimerDisposable> _handles = <TimerDisposable>{};

  bool get isDisposed => _disposed;

  TimerDisposable? register(final TimerDisposable? handle) {
    if (handle == null) return null;

    if (_disposed) {
      handle.dispose();
      return handle;
    }

    _handles.add(handle);
    return handle;
  }

  void unregister(final TimerDisposable? handle) {
    if (handle == null) return;
    _handles.remove(handle);
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    final Set<TimerDisposable> copy = Set<TimerDisposable>.from(_handles);
    _handles.clear();
    for (final TimerDisposable handle in copy) {
      try {
        handle.dispose();
      } on Object catch (error, stackTrace) {
        Zone.current.handleUncaughtError(error, stackTrace);
      }
    }
  }
}
