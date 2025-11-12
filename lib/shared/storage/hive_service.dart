import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Service for managing Hive database with encryption.
class HiveService {
  HiveService({required final HiveKeyManager keyManager})
    : _keyManager = keyManager;

  final HiveKeyManager _keyManager;
  bool _initialized = false;

  /// Initializes Hive with encryption.
  ///
  /// This method is safe to call multiple times - it will only initialize once.
  Future<void> initialize() async => StorageGuard.run<void>(
    logContext: 'HiveService.initialize',
    action: () async {
      if (_initialized) {
        return;
      }

      // Try to initialize Hive
      // In tests, Hive.init() may have been called already, so initFlutter() will fail
      try {
        await Hive.initFlutter();
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
    },
    fallback: () {
      throw StateError(
        'Failed to initialize Hive database. '
        'App cannot continue without storage.',
      );
    },
  );

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
    if (name.isEmpty) {
      throw ArgumentError('Box name cannot be empty');
    }
    if (!_initialized) {
      await initialize();
    }

    try {
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
  }

  /// Deletes a box.
  Future<void> deleteBox(final String name) async {
    if (name.isEmpty) {
      return;
    }
    try {
      // Close box first if it's open
      if (Hive.isBoxOpen(name)) {
        await closeBox(name);
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
  }
}
