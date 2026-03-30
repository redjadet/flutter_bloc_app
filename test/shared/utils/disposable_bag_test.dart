import 'dart:async';

import 'package:flutter_bloc_app/shared/utils/disposable_bag.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DisposableBag', () {
    test(
      'untrack prevents a registered callback from running on clear',
      () async {
        final DisposableBag bag = DisposableBag();
        var disposed = false;

        final Object token = bag.addSync(() {
          disposed = true;
        });
        bag.untrack(token);

        await bag.clear();

        expect(disposed, isFalse);
      },
    );

    test(
      'untracked subscription is not cancelled again during clear',
      () async {
        final DisposableBag bag = DisposableBag();
        final _CountingSubscription<int> subscription =
            _CountingSubscription<int>();

        bag.trackSubscription(subscription);
        bag.untrackSubscription(subscription);
        await subscription.cancel();
        await bag.clear();

        expect(subscription.cancelCount, 1);
      },
    );

    test(
      'dispose cancels tracked subscriptions in reverse registration order',
      () async {
        final DisposableBag bag = DisposableBag();
        final List<String> cancelOrder = <String>[];
        final _CountingSubscription<int> first = _CountingSubscription<int>(
          onCancel: () => cancelOrder.add('first'),
        );
        final _CountingSubscription<int> second = _CountingSubscription<int>(
          onCancel: () => cancelOrder.add('second'),
        );

        bag.trackSubscription(first);
        bag.trackSubscription(second);

        await bag.dispose();

        expect(cancelOrder, <String>['second', 'first']);
      },
    );
  });
}

class _CountingSubscription<T> implements StreamSubscription<T> {
  _CountingSubscription({this.onCancel});

  final void Function()? onCancel;
  int cancelCount = 0;
  bool _isPaused = false;

  @override
  Future<void> cancel() async {
    cancelCount++;
    onCancel?.call();
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
