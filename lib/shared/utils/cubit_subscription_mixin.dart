import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

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
/// class MyCubit extends Cubit<MyState> with CubitSubscriptionMixin {
///   MyCubit({required MyRepository repository})
///     : _repository = repository,
///       super(MyState.initial()) {
///     _subscription = _repository.stream.listen(_onData);
///     registerSubscription(_subscription);
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
  final List<StreamSubscription<dynamic>?> _subscriptions = [];

  /// Registers a subscription to be automatically cancelled when the cubit closes.
  ///
  /// Subscriptions should be registered immediately after creation.
  void registerSubscription(final StreamSubscription<dynamic>? subscription) {
    if (subscription != null) {
      _subscriptions.add(subscription);
    }
  }

  /// Cancels all registered subscriptions.
  ///
  /// Called automatically from [close]; can be called manually if needed.
  Future<void> cancelAllSubscriptions() async {
    final List<StreamSubscription<dynamic>?> subscriptions = List.from(
      _subscriptions,
    );
    _subscriptions.clear();

    for (final subscription in subscriptions) {
      if (subscription != null) {
        await subscription.cancel();
      }
    }
  }

  /// Cancels all registered subscriptions. Invoked automatically by [close].
  Future<void> closeAllSubscriptions() async {
    await cancelAllSubscriptions();
  }

  @override
  Future<void> close() async {
    await closeAllSubscriptions();
    return super.close();
  }
}
