import 'dart:async';

import 'package:flutter_bloc_app/shared/utils/stream_controller_lifecycle.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestLifecycle with StreamControllerLifecycle<int> {
  Future<void> dispose() async {
    await disposeController();
  }
}

void main() {
  group('StreamControllerLifecycle', () {
    test('safeEmit does nothing when controller is null', () {
      final _TestLifecycle lifecycle = _TestLifecycle();

      lifecycle.safeEmit(1);
      lifecycle.safeEmitError(Exception('error'));

      expect(lifecycle.controller, isNull);
    });

    test('emits values and errors when controller is active', () async {
      final _TestLifecycle lifecycle = _TestLifecycle();
      await lifecycle.createController();

      final List<int> values = <int>[];
      final List<Object> errors = <Object>[];
      final StreamSubscription<int> subscription = lifecycle.controller!.stream
          .listen(values.add, onError: errors.add);

      lifecycle.safeEmit(42);
      lifecycle.safeEmitError(Exception('boom'));
      await Future<void>.delayed(Duration.zero);

      expect(values, <int>[42]);
      expect(errors, hasLength(1));

      await subscription.cancel();
      await lifecycle.dispose();
    });

    test('createController replaces existing controller', () async {
      final _TestLifecycle lifecycle = _TestLifecycle();
      await lifecycle.createController();
      final StreamController<int>? first = lifecycle.controller;

      await lifecycle.createController();
      final StreamController<int>? second = lifecycle.controller;

      expect(first, isNotNull);
      expect(second, isNotNull);
      expect(identical(first, second), isFalse);

      await lifecycle.dispose();
    });
  });
}
