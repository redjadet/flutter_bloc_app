import 'dart:async';

import 'package:flutter_bloc_app/shared/storage/hive_initializer.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'hive_service_boxes.part.dart';

/// Service for managing Hive database with encryption.
class HiveService with HiveServiceBoxOperations {
  HiveService({
    required this._keyManager,
    final Future<bool> Function()? initializeHiveStorage,
  }) : _initializeHiveStorage = initializeHiveStorage ?? initHive;

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

  /// Runs [action] under the per-box mutex used by open/close/delete.
  Future<T> withBoxLock<T>(
    final String boxName,
    final Future<T> Function() action,
  ) {
    if (boxName.isEmpty) {
      throw ArgumentError('Box name cannot be empty');
    }
    return _mutexFor(boxName).run(action);
  }

  /// Initializes Hive with encryption once.
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
        // Open and close a temporary box to verify initialization.
        final String testBoxName =
            '_init_check_${DateTime.now().millisecondsSinceEpoch}';
        final Box<dynamic> testBox = await Hive.openBox(
          testBoxName,
          crashRecovery: false,
        );
        await testBox.close();
        await Hive.deleteBoxFromDisk(testBoxName);
        AppLogger.debug('Hive already initialized, skipping initFlutter');
      } on Exception {
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
}
