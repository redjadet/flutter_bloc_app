import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_subscription_mixin.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CubitSubscriptionMixin', () {
    test(
      'cancelRegisteredSubscription removes old subscriptions from tracking',
      () async {
        final _TestSubscriptionCubit cubit = _TestSubscriptionCubit();
        final _CountingSubscription<int> firstSubscription =
            _CountingSubscription<int>();
        final _CountingSubscription<int> secondSubscription =
            _CountingSubscription<int>();

        addTearDown(cubit.close);

        await cubit.replaceSubscription(firstSubscription);
        expect(firstSubscription.cancelCount, 0);

        await cubit.replaceSubscription(secondSubscription);

        expect(firstSubscription.cancelCount, 1);
        expect(secondSubscription.cancelCount, 0);

        await cubit.close();

        expect(firstSubscription.cancelCount, 1);
        expect(secondSubscription.cancelCount, 1);
      },
    );

    test(
      'registerSubscription cancels late subscriptions after close',
      () async {
        final _TestSubscriptionCubit cubit = _TestSubscriptionCubit();
        final _CountingSubscription<int> subscription =
            _CountingSubscription<int>();

        await cubit.close();
        cubit.registerExternal(subscription);

        expect(subscription.cancelCount, 1);
      },
    );
  });
}

class _TestSubscriptionCubit extends Cubit<int>
    with CubitSubscriptionMixin<int> {
  _TestSubscriptionCubit() : super(0);

  StreamSubscription<int>? _subscription;

  Future<void> replaceSubscription(
    final StreamSubscription<int> subscription,
  ) async {
    final StreamSubscription<int>? previousSubscription = _subscription;
    _subscription = null;
    await cancelRegisteredSubscription(previousSubscription);
    _subscription = registerSubscription(subscription);
  }

  void registerExternal(final StreamSubscription<int> subscription) {
    registerSubscription(subscription);
  }

  @override
  Future<void> close() async {
    _subscription = null;
    return super.close();
  }
}

class _CountingSubscription<T> implements StreamSubscription<T> {
  int cancelCount = 0;
  bool _isPaused = false;

  @override
  Future<void> cancel() async {
    cancelCount++;
  }

  @override
  Future<E> asFuture<E>([final E? futureValue]) =>
      Future<E>.value(futureValue as E);

  @override
  bool get isPaused => _isPaused;

  @override
  void onData(final void Function(T data)? handleData) {}

  @override
  void onDone(final void Function()? handleDone) {}

  @override
  void onError(final Function? handleError) {}

  @override
  void pause([final Future<void>? resumeSignal]) {
    _isPaused = true;
    resumeSignal?.whenComplete(resume);
  }

  @override
  void resume() {
    _isPaused = false;
  }
}
