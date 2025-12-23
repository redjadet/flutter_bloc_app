import 'dart:async';

import 'package:flutter_bloc_app/shared/utils/repository_watch_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RepositoryWatchHelper', () {
    test('emits cached value then loaded value on listen', () async {
      final RepositoryWatchHelper<String> helper =
          RepositoryWatchHelper<String>(
            loadInitial: () async => 'loaded',
            emptyValue: 'empty',
          );
      helper.cachedValue = 'cached';
      helper.createWatchController(
        onListen: helper.handleOnListen,
        onCancel: helper.handleOnCancel,
      );

      await expectLater(
        helper.stream,
        emitsInOrder(<String>['cached', 'loaded']),
      );
    });

    test('emits empty value when load fails without cache', () async {
      final List<Object> errors = <Object>[];
      final RepositoryWatchHelper<String> helper =
          RepositoryWatchHelper<String>(
            loadInitial: () async => throw Exception('load failed'),
            emptyValue: 'empty',
            onError: (Object error, StackTrace stackTrace) => errors.add(error),
          );
      helper.createWatchController(
        onListen: helper.handleOnListen,
        onCancel: helper.handleOnCancel,
      );

      await expectLater(helper.stream, emits('empty'));
      expect(errors, hasLength(1));
    });

    test('emitValue caches latest value', () {
      final RepositoryWatchHelper<String> helper =
          RepositoryWatchHelper<String>(
            loadInitial: () async => 'loaded',
            emptyValue: 'empty',
          );

      helper.emitValue('next');

      expect(helper.cachedValue, 'next');
    });

    test('handleOnCancel allows controller to be recreated', () async {
      final RepositoryWatchHelper<String> helper =
          RepositoryWatchHelper<String>(
            loadInitial: () async => 'loaded',
            emptyValue: 'empty',
          );
      helper.createWatchController(
        onListen: helper.handleOnListen,
        onCancel: helper.handleOnCancel,
      );

      final Completer<void> firstLoad = Completer<void>();
      final StreamSubscription<String> subscription = helper.stream.listen((
        final value,
      ) {
        if (!firstLoad.isCompleted) {
          firstLoad.complete();
        }
      });
      await firstLoad.future;
      await subscription.cancel();
      await helper.handleOnCancel();

      helper.createWatchController(
        onListen: helper.handleOnListen,
        onCancel: helper.handleOnCancel,
      );

      await expectLater(
        helper.stream,
        emitsInOrder(<String>['loaded', 'loaded']),
      );
    });
  });
}
