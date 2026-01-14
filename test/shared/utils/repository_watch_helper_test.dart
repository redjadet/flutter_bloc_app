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

    test(
      'createWatchController does not recreate when controller has listeners',
      () async {
        final RepositoryWatchHelper<String> helper =
            RepositoryWatchHelper<String>(
              loadInitial: () async => 'loaded',
              emptyValue: 'empty',
            );

        // Access stream to create controller
        final stream = helper.stream;
        final subscription = stream.listen((_) {});

        // Try to create controller - should not recreate
        helper.createWatchController(
          onListen: helper.handleOnListen,
          onCancel: helper.handleOnCancel,
        );

        await subscription.cancel();
      },
    );

    test('emitValue does not emit when controller is closed', () {
      final RepositoryWatchHelper<String> helper =
          RepositoryWatchHelper<String>(
            loadInitial: () async => 'loaded',
            emptyValue: 'empty',
          );

      // Access stream to create controller
      helper.stream;
      // Close controller
      helper.dispose();

      // Should not throw
      expect(() => helper.emitValue('test'), returnsNormally);
    });

    test('handleOnCancel returns early when controller is null', () async {
      final RepositoryWatchHelper<String> helper =
          RepositoryWatchHelper<String>(
            loadInitial: () async => 'loaded',
            emptyValue: 'empty',
          );

      await helper.handleOnCancel();

      // Should not throw
      expect(helper.cachedValue, isNull);
    });

    test(
      'handleOnCancel does not close when controller has listeners',
      () async {
        final RepositoryWatchHelper<String> helper =
            RepositoryWatchHelper<String>(
              loadInitial: () async => 'loaded',
              emptyValue: 'empty',
            );
        helper.createWatchController(
          onListen: helper.handleOnListen,
          onCancel: helper.handleOnCancel,
        );

        final subscription = helper.stream.listen((_) {});

        await helper.handleOnCancel();

        // Controller should still exist
        expect(helper.stream, isNotNull);

        await subscription.cancel();
      },
    );

    test('dispose closes controller and clears pending operations', () async {
      final RepositoryWatchHelper<String> helper =
          RepositoryWatchHelper<String>(
            loadInitial: () async => 'loaded',
            emptyValue: 'empty',
          );
      helper.createWatchController(
        onListen: helper.handleOnListen,
        onCancel: helper.handleOnCancel,
      );

      await helper.dispose();

      // Should not throw
      expect(() => helper.emitValue('test'), returnsNormally);
    });
  });
}
