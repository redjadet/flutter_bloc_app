import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/shared/utils/disposable_bag.dart';
import 'package:flutter_bloc_app/shared/utils/timer_handle_manager.dart';

/// Mixin for managing stream subscriptions in cubits.
///
/// Subscriptions registered via [registerSubscription] are automatically
/// cancelled when the cubit is closed. [close] is overridden to run
/// [closeAllSubscriptions] then [Cubit.close], so subclasses that override
/// [close] should perform their own cleanup (e.g. null refs, dispose timer
/// handles) then call `super.close()` to run subscription cancellation and
/// bloc teardown.
///
/// Example:
/// ```dart
/// class MyCubit extends Cubit<MyState> with CubitSubscriptionMixin<MyState> {
///   MyCubit({required MyRepository repository})
///     : _repository = repository,
///       super(MyState.initial()) {
///     _subscription = registerSubscription(
///       _repository.stream.listen(_onData),
///     );
///   }
///
///   final MyRepository _repository;
///   StreamSubscription<Data>? _subscription;
///
///   void _onData(Data data) {
///     if (isClosed) return;
///     emit(state.copyWith(data: data));
///   }
///
///   @override
///   Future<void> close() async {
///     _subscription = null; // optional: null ref before super.close()
///     return super.close(); // cancels all registered subscriptions then closes
///   }
/// }
/// ```
mixin CubitSubscriptionMixin<S> on Cubit<S> {
  final DisposableBag _subscriptions = DisposableBag();
  final TimerHandleManager _timers = TimerHandleManager();

  /// Registers a subscription to be automatically cancelled when the cubit closes.
  ///
  /// Subscriptions should be registered immediately after creation.
  T registerSubscription<T extends StreamSubscription<dynamic>?>(
    final T subscription,
  ) {
    if (subscription == null) return subscription;

    // If a late async callback creates a subscription after the cubit has already
    // closed, cancel immediately to avoid leaks.
    if (isClosed) {
      unawaited(subscription.cancel());
      return subscription;
    }

    _subscriptions.trackSubscription(subscription);
    return subscription;
  }

  /// Cancels a registered subscription and removes it from the tracked set.
  Future<void> cancelRegisteredSubscription(
    final StreamSubscription<dynamic>? subscription,
  ) async {
    if (subscription == null) return;
    _subscriptions.untrackSubscription(subscription);
    await subscription.cancel();
  }

  /// Registers a timer handle to be disposed when the cubit closes.
  ///
  /// If a late async callback creates a timer after the cubit has already
  /// closed, the handle is disposed immediately to avoid leaks.
  T registerTimer<T extends TimerDisposable?>(final T handle) {
    final TimerDisposable? value = handle;
    if (value == null) return handle;
    if (isClosed) {
      value.dispose();
      return handle;
    }
    _timers.register(value);
    return handle;
  }

  /// Unregisters a timer handle that has been disposed independently.
  void unregisterTimer(final TimerDisposable? handle) {
    _timers.unregister(handle);
  }

  /// Cancels all registered subscriptions.
  ///
  /// Called automatically from [close]; can be called manually if needed.
  Future<void> cancelAllSubscriptions() async {
    await _subscriptions.clear();
  }

  Future<void> disposeAllTimers() async {
    await _timers.dispose();
  }

  /// Cancels all registered subscriptions. Invoked automatically by [close].
  Future<void> closeAllSubscriptions() async {
    await cancelAllSubscriptions();
  }

  @override
  Future<void> close() async {
    await disposeAllTimers();
    await closeAllSubscriptions();
    return super.close();
  }
}
