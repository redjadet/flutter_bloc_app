import 'dart:async';

class GoodCubit {
  StreamSubscription<int>? _subscription;

  void start(final Stream<int> stream) {
    _subscription = stream.listen((final _) {});
  }

  Future<void> close() async {
    await _subscription?.cancel();
  }
}
