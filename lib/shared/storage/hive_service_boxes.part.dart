part of 'hive_service.dart';

mixin HiveServiceBoxOperations on Object {
  Future<Box<dynamic>> openBox(
    final String name, {
    final bool encrypted = true,
  }) async {
    final self = this as HiveService;
    return self.openBoxAndRun<Box<dynamic>>(
      name,
      encrypted: encrypted,
      action: (final box) async => box,
    );
  }

  Future<T> openBoxAndRun<T>(
    final String name, {
    required final Future<T> Function(Box<dynamic> box) action,
    final bool encrypted = true,
  }) async {
    final self = this as HiveService;
    if (name.isEmpty) {
      throw ArgumentError('Box name cannot be empty');
    }
    await self.initialize();
    if (!self._storageAvailable) {
      throw StateError(
        'Hive storage is unavailable because another app process owns it.',
      );
    }

    return self._mutexFor(name).run(() async {
      final Box<dynamic> box = await _openBoxInternal(
        name,
        encrypted: encrypted,
      );
      return action(box);
    });
  }

  Future<Box<dynamic>> _openBoxInternal(
    final String name, {
    required final bool encrypted,
  }) async {
    final self = this as HiveService;
    try {
      if (Hive.isBoxOpen(name)) {
        return Hive.box<dynamic>(name);
      }

      if (encrypted) {
        final HiveAesCipher cipher = await self.getEncryptionCipher();
        return Hive.openBox(name, encryptionCipher: cipher);
      }
      return Hive.openBox(name);
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'Failed to open Hive box: $name',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> closeBox(final String name) async {
    final self = this as HiveService;
    if (name.isEmpty) {
      return;
    }
    if (!self._storageAvailable) {
      return;
    }
    await self._mutexFor(name).run(() async {
      try {
        if (Hive.isBoxOpen(name)) {
          await Hive.box<dynamic>(name).close();
        }
      } on Exception catch (error, stackTrace) {
        AppLogger.error(
          'Failed to close Hive box: $name',
          error,
          stackTrace,
        );
      }
    });
  }

  Future<void> deleteBox(final String name) async {
    final self = this as HiveService;
    if (name.isEmpty) {
      return;
    }
    if (!self._storageAvailable) {
      return;
    }
    await self._mutexFor(name).run(() async {
      try {
        if (Hive.isBoxOpen(name)) {
          await Hive.box<dynamic>(name).close();
        }
        await Hive.deleteBoxFromDisk(name);
      } on Exception catch (error, stackTrace) {
        AppLogger.error(
          'Failed to delete Hive box: $name',
          error,
          stackTrace,
        );
        rethrow;
      }
    });
  }
}

class _BoxMutex {
  Future<void> _tail = Future<void>.value();

  Future<T> run<T>(final Future<T> Function() action) {
    final Completer<T> completer = Completer<T>();

    _tail = _tail.then((_) async {
      try {
        final T result = await action();
        completer.complete(result);
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });

    // Completer forwards action errors; swallow only the chained tail future so
    // the mutex queue stays unbroken without an unhandled async error.
    unawaited(_tail.catchError((_) {}));

    return completer.future;
  }
}
