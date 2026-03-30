import 'dart:async';

import 'package:flutter_bloc_app/core/time/timer_service.dart';

/// Minimal, centralized lifecycle helper for managing cancellable/closable
/// resources (subscriptions, controllers, timers).
///
/// Prefer this when a class owns multiple resources and wants a single,
/// reliable cleanup path without leaking.
class DisposableBag {
  final List<Future<void> Function()> _disposeActions =
      <Future<void> Function()>[];
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  void _reportDisposeError(final Object error, final StackTrace stackTrace) {
    Zone.current.handleUncaughtError(error, stackTrace);
  }

  /// Registers a synchronous dispose callback.
  void addSync(final void Function() dispose) {
    if (_isDisposed) {
      try {
        dispose();
      } on Object catch (error, stackTrace) {
        _reportDisposeError(error, stackTrace);
      }
      return;
    }
    _disposeActions.add(() async => dispose());
  }

  /// Registers an asynchronous dispose callback.
  void addAsync(final Future<void> Function() dispose) {
    if (_isDisposed) {
      unawaited(
        dispose().catchError(
          (final Object error, final StackTrace stackTrace) {
            _reportDisposeError(error, stackTrace);
          },
        ),
      );
      return;
    }
    _disposeActions.add(dispose);
  }

  /// Registers a stream subscription for cancellation during [dispose].
  T trackSubscription<T extends StreamSubscription<dynamic>?>(
    final T subscription,
  ) {
    final StreamSubscription<dynamic>? sub = subscription;
    if (sub == null) return subscription;

    addAsync(() async {
      try {
        await sub.cancel();
      } on Object catch (error, stackTrace) {
        _reportDisposeError(error, stackTrace);
      }
    });
    return subscription;
  }

  /// Registers a stream controller for closure during [dispose].
  T trackController<T extends StreamController<dynamic>>(final T controller) {
    addAsync(() async {
      if (controller.isClosed) return;
      try {
        await controller.close();
      } on Object catch (error, stackTrace) {
        _reportDisposeError(error, stackTrace);
      }
    });
    return controller;
  }

  /// Registers a [TimerDisposable] for cancellation during [dispose].
  T trackTimer<T extends TimerDisposable?>(final T disposable) {
    final TimerDisposable? handle = disposable;
    if (handle == null) return disposable;
    addSync(handle.dispose);
    return disposable;
  }

  /// Disposes everything registered so far. Safe to call multiple times.
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await clear();
  }

  /// Cancels/closes everything registered so far, but keeps the bag reusable.
  ///
  /// This is useful for owners that frequently restart watches (cancel old
  /// subscriptions, then register new ones) without being disposed.
  Future<void> clear() async {
    final List<Future<void> Function()> actions =
        List<Future<void> Function()>.from(_disposeActions);
    _disposeActions.clear();

    for (final action in actions.reversed) {
      try {
        await action();
      } on Object catch (error, stackTrace) {
        _reportDisposeError(error, stackTrace);
      }
    }
  }
}
