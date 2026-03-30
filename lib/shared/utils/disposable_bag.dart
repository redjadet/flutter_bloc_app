import 'dart:async';
import 'dart:collection';

import 'package:flutter_bloc_app/core/time/timer_service.dart';

/// Minimal, centralized lifecycle helper for managing cancellable/closable
/// resources (subscriptions, controllers, timers).
///
/// Prefer this when a class owns multiple resources and wants a single,
/// reliable cleanup path without leaking.
class DisposableBag {
  final LinkedHashMap<Object, Future<void> Function()> _disposeActions =
      LinkedHashMap<Object, Future<void> Function()>.identity();
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  void _reportDisposeError(final Object error, final StackTrace stackTrace) {
    Zone.current.handleUncaughtError(error, stackTrace);
  }

  /// Registers a synchronous dispose callback.
  Object addSync(final void Function() dispose) {
    final Object token = Object();
    if (_isDisposed) {
      try {
        dispose();
      } on Object catch (error, stackTrace) {
        _reportDisposeError(error, stackTrace);
      }
      return token;
    }
    _disposeActions[token] = () async => dispose();
    return token;
  }

  /// Registers an asynchronous dispose callback.
  Object addAsync(final Future<void> Function() dispose) {
    final Object token = Object();
    if (_isDisposed) {
      unawaited(
        dispose().catchError(
          (final Object error, final StackTrace stackTrace) {
            _reportDisposeError(error, stackTrace);
          },
        ),
      );
      return token;
    }
    _disposeActions[token] = dispose;
    return token;
  }

  /// Registers a stream subscription for cancellation during [dispose].
  T trackSubscription<T extends StreamSubscription<dynamic>?>(
    final T subscription,
  ) {
    final StreamSubscription<dynamic>? sub = subscription;
    if (sub == null) return subscription;

    _disposeActions[sub] = () async {
      try {
        await sub.cancel();
      } on Object catch (error, stackTrace) {
        _reportDisposeError(error, stackTrace);
      }
    };
    return subscription;
  }

  /// Removes a previously tracked resource without disposing it.
  void untrack(final Object? token) {
    if (token == null) return;
    _disposeActions.remove(token);
  }

  /// Removes a previously tracked subscription without cancelling it.
  void untrackSubscription(final StreamSubscription<dynamic>? subscription) {
    untrack(subscription);
  }

  /// Registers a stream controller for closure during [dispose].
  T trackController<T extends StreamController<dynamic>>(final T controller) {
    _disposeActions[controller] = () async {
      if (controller.isClosed) return;
      try {
        await controller.close();
      } on Object catch (error, stackTrace) {
        _reportDisposeError(error, stackTrace);
      }
    };
    return controller;
  }

  /// Removes a previously tracked controller without closing it.
  void untrackController(final StreamController<dynamic>? controller) {
    untrack(controller);
  }

  /// Registers a [TimerDisposable] for cancellation during [dispose].
  T trackTimer<T extends TimerDisposable?>(final T disposable) {
    final TimerDisposable? handle = disposable;
    if (handle == null) return disposable;
    _disposeActions[handle] = () async => handle.dispose();
    return disposable;
  }

  /// Removes a previously tracked timer handle without disposing it.
  void untrackTimer(final TimerDisposable? disposable) {
    untrack(disposable);
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
    final List<Future<void> Function()> actions = _disposeActions.values.toList(
      growable: false,
    );
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
