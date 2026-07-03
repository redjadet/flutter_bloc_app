part of 'hive_service.dart';

bool _effectiveHiveEncryption(final bool encrypted) {
  if (encrypted && useUnencryptedHiveBoxesInDebug()) {
    return false;
  }
  return encrypted;
}

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

    final bool useEncryption = _effectiveHiveEncryption(encrypted);
    return self._mutexFor(name).run(() async {
      final Box<dynamic> box = await _openBoxInternal(
        name,
        encrypted: useEncryption,
      );
      try {
        return await action(box);
      } on Object catch (error, _) {
        if (!isRecoverableHiveFailure(error)) {
          rethrow;
        }
        AppLogger.warning(
          'Recovering Hive box after read failure: $name ($error)',
        );
        try {
          final Box<dynamic> recovered = await _recoverCorruptBox(
            name,
            encrypted: useEncryption,
          );
          return await action(recovered);
        } on Object catch (retryError, retryStackTrace) {
          AppLogger.error(
            'Failed to recover Hive box after read failure: $name',
            retryError,
            retryStackTrace,
          );
          rethrow;
        }
      }
    });
  }

  Future<Box<dynamic>> _openBoxInternal(
    final String name, {
    required final bool encrypted,
  }) async {
    try {
      return await _openBoxOnce(name, encrypted: encrypted);
    } on Object catch (error, stackTrace) {
      if (!isRecoverableHiveFailure(error)) {
        AppLogger.error(
          'Failed to open Hive box: $name',
          error,
          stackTrace,
        );
        rethrow;
      }

      AppLogger.warning(
        'Recovering corrupted Hive box: $name ($error)',
      );
      try {
        return await _recoverCorruptBox(name, encrypted: encrypted);
      } on Object catch (retryError, retryStackTrace) {
        AppLogger.error(
          'Failed to reopen Hive box after recovery: $name',
          retryError,
          retryStackTrace,
        );
        rethrow;
      }
    }
  }

  Future<Box<dynamic>> _recoverCorruptBox(
    final String name, {
    required final bool encrypted,
  }) async {
    if (Hive.isBoxOpen(name)) {
      await Hive.box<dynamic>(name).close();
    }
    if (useInMemoryHiveBoxesInDebug()) {
      return _openBoxOnce(name, encrypted: encrypted, resetInMemory: true);
    }
    await Hive.deleteBoxFromDisk(name);
    return _openBoxOnce(name, encrypted: encrypted);
  }

  Future<Box<dynamic>> _openBoxOnce(
    final String name, {
    required final bool encrypted,
    final bool resetInMemory = false,
  }) async {
    final self = this as HiveService;
    final bool inMemoryDebug = useInMemoryHiveBoxesInDebug();
    // Web debug must never reuse a box opened before in-memory mode (IndexedDB).
    final bool mustReopen = resetInMemory || inMemoryDebug;
    if (Hive.isBoxOpen(name) && !mustReopen) {
      return Hive.box<dynamic>(name);
    }
    if (Hive.isBoxOpen(name)) {
      await Hive.box<dynamic>(name).close();
    }

    if (inMemoryDebug) {
      final Uint8List bytes = Uint8List(0);
      if (encrypted) {
        final HiveAesCipher cipher = await self.getEncryptionCipher();
        return Hive.openBox(
          name,
          bytes: bytes,
          encryptionCipher: cipher,
        );
      }
      return Hive.openBox(name, bytes: bytes);
    }

    if (encrypted) {
      final HiveAesCipher cipher = await self.getEncryptionCipher();
      return Hive.openBox(name, encryptionCipher: cipher);
    }
    return Hive.openBox(name);
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
        if (useInMemoryHiveBoxesInDebug()) {
          return;
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
