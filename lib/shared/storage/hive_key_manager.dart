import 'dart:convert';
import 'dart:math';

import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';

/// Manages encryption key for Hive database using secure storage.
class HiveKeyManager {
  HiveKeyManager({final SecretStorage? storage})
    : _storage = storage ?? FlutterSecureSecretStorage();

  static const String _storageKey = 'hive_encryption_key';
  static const int _keyLengthBytes = 32; // 256 bits

  final SecretStorage _storage;

  /// Gets the encryption key, generating a new one if it doesn't exist.
  Future<List<int>> getEncryptionKey() async => StorageGuard.run<List<int>>(
    logContext: 'HiveKeyManager.getEncryptionKey',
    action: () async {
      final String? storedKey = await _storage.read(_storageKey);
      if (storedKey != null && storedKey.isNotEmpty) {
        try {
          final List<int> key = base64Decode(storedKey);
          if (key.length == _keyLengthBytes) {
            return key;
          }
          AppLogger.warning(
            'Stored encryption key has invalid length (${key.length}), '
            'generating new key.',
          );
        } on Exception catch (error, stackTrace) {
          AppLogger.error(
            'Failed to decode stored encryption key',
            error,
            stackTrace,
          );
        }
      }

      // Generate new key
      final List<int> newKey = _generateKey();
      await _storage.write(_storageKey, base64Encode(newKey));
      return newKey;
    },
    fallback: () {
      // Fallback: generate a key but don't persist it
      AppLogger.warning(
        'Failed to retrieve encryption key from secure storage, '
        'using temporary key (data will not persist across restarts).',
      );
      return _generateKey();
    },
  );

  List<int> _generateKey() {
    final Random random = Random.secure();
    return List<int>.generate(
      _keyLengthBytes,
      (_) => random.nextInt(256),
    );
  }
}
