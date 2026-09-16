import 'dart:async';

class GoodCubit {
  StreamSubscription<int>? _subscription;

  void start(Stream<int> stream) {
    _subscription = stream.listen((_) {});
  }

  Future<void> close() async {
    await _subscription?.cancel();
  }
}
