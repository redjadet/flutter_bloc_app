import 'dart:async';

import 'package:flutter_bloc_app/shared/storage/hive_initializer.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Service for managing Hive database with encryption.
class HiveService {
  HiveService({
    required final HiveKeyManager keyManager,
    final Future<bool> Function()? initializeHiveStorage,
  }) : _keyManager = keyManager,
       _initializeHiveStorage = initializeHiveStorage ?? initHive;

  final HiveKeyManager _keyManager;
  final Future<bool> Function() _initializeHiveStorage;
  bool _initialized = false;
  bool _storageAvailable = true;
  Future<void>? _initializeInFlight;
  final Map<String, _BoxMutex> _boxMutexes = {};

  bool get isInitialized => _initialized;
  bool get isStorageAvailable => _storageAvailable;

  _BoxMutex _mutexFor(final String boxName) =>
      _boxMutexes.putIfAbsent(boxName, _BoxMutex.new);

  /// Runs [action] under the same per-box mutex used by open/close/delete.
  ///
  /// Exposed for higher-level box workflows (e.g. schema ensures) to prevent
  /// interleaving writes for the same box.
  Future<T> withBoxLock<T>(
    final String boxName,
    final Future<T> Function() action,
  ) {
    if (boxName.isEmpty) {
      throw ArgumentError('Box name cannot be empty');
    }
    return _mutexFor(boxName).run(action);
  }

  /// Initializes Hive with encryption.
  ///
  /// This method is safe to call multiple times - it will only initialize once.
  Future<void> initialize() async => StorageGuard.run<void>(
    logContext: 'HiveService.initialize',
    action: () async {
      final Future<void>? existing = _initializeInFlight;
      if (existing != null) {
        await existing;
        return;
      }
      if (_initialized) {
        return;
      }

      final Future<void> initFuture = _initializeInternal();
      _initializeInFlight = initFuture;
      try {
        await initFuture;
      } finally {
        _initializeInFlight = null;
      }
    },
    fallback: () {
      throw StateError(
        'Failed to initialize Hive database. '
        'App cannot continue without storage.',
      );
    },
  );

  Future<void> _initializeInternal() async {
    // Try to initialize Hive
    // In tests, Hive.init() may have been called already, so initFlutter() will fail
    try {
      final bool storageAvailable = await _initializeHiveStorage();
      if (!storageAvailable) {
        _storageAvailable = false;
        _initialized = true;
        return;
      }
    } on Exception catch (error, stackTrace) {
      // If initFlutter fails, verify if Hive is actually initialized
      // by attempting to use it (tests call Hive.init() directly)
      try {
        // Try to open and immediately close a temporary box to verify initialization
        final String testBoxName =
            '_init_check_${DateTime.now().millisecondsSinceEpoch}';
        final Box<dynamic> testBox = await Hive.openBox(
          testBoxName,
          crashRecovery: false,
        );
        await testBox.close();
        await Hive.deleteBoxFromDisk(testBoxName);
        // Hive was already initialized (e.g., in test setup via Hive.init())
        AppLogger.debug('Hive already initialized, skipping initFlutter');
      } on Exception {
        // Hive is truly not initialized - this is a real failure
        AppLogger.error(
          'Hive initialization failed and Hive is not initialized',
          error,
          stackTrace,
        );
        rethrow;
      }
    }
    _initialized = true;
    AppLogger.info('Hive database initialized');
  }

  /// Gets encryption cipher for a box.
  Future<HiveAesCipher> getEncryptionCipher() async {
    final List<int> key = await _keyManager.getEncryptionKey();
    if (key.length != 32) {
      throw StateError(
        'Invalid encryption key length: ${key.length}. Expected 32 bytes (256 bits).',
      );
    }
    return HiveAesCipher(key);
  }

  /// Opens a box with encryption.
  Future<Box<dynamic>> openBox(
    final String name, {
    final bool encrypted = true,
  }) async {
    return openBoxAndRun<Box<dynamic>>(
      name,
      encrypted: encrypted,
      action: (final box) async => box,
    );
  }

  /// Opens a box and runs [action] while holding the per-box mutex.
  ///
  /// Use this when callers must avoid interleaving with close/delete for the
  /// same box (e.g. schema ensure + reads).
  Future<T> openBoxAndRun<T>(
    final String name, {
    required final Future<T> Function(Box<dynamic> box) action,
    final bool encrypted = true,
  }) async {
    if (name.isEmpty) {
      throw ArgumentError('Box name cannot be empty');
    }
    await initialize();
    if (!_storageAvailable) {
      throw StateError(
        'Hive storage is unavailable because another app process owns it.',
      );
    }

    return _mutexFor(name).run(() async {
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
    try {
      if (Hive.isBoxOpen(name)) {
        return Hive.box<dynamic>(name);
      }

      if (encrypted) {
        final HiveAesCipher cipher = await getEncryptionCipher();
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

  /// Closes a box.
  Future<void> closeBox(final String name) async {
    if (name.isEmpty) {
      return;
    }
    if (!_storageAvailable) {
      return;
    }
    await _mutexFor(name).run(() async {
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
        // Don't rethrow - closing is best-effort
      }
    });
  }

  /// Deletes a box.
  Future<void> deleteBox(final String name) async {
    if (name.isEmpty) {
      return;
    }
    if (!_storageAvailable) {
      return;
    }
    await _mutexFor(name).run(() async {
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

    // Ensure tail stays alive even if action errors.
    unawaited(_tail.catchError((_) {}));

    return completer.future;
  }
}
