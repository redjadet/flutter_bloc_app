import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';

/// Manages encryption key for Hive database using secure storage.
class HiveKeyManager {
  HiveKeyManager({final SecretStorage? storage})
    : _useMacOsDebugFallbackKey =
          storage == null &&
          !kIsWeb &&
          !kReleaseMode &&
          defaultTargetPlatform == TargetPlatform.macOS,
      _storage = storage ?? createDefaultSecretStorage();

  static const String _storageKey = 'hive_encryption_key';
  static const int _keyLengthBytes = 32; // 256 bits
  static final List<int> _macOsDebugFallbackKey = List<int>.unmodifiable(
    List<int>.generate(_keyLengthBytes, (final index) => index),
  );

  final SecretStorage _storage;
  final bool _useMacOsDebugFallbackKey;
  List<int>? _cachedKey;

  /// Gets the encryption key, generating a new one if it doesn't exist.
  Future<List<int>> getEncryptionKey() async => StorageGuard.run<List<int>>(
    logContext: 'HiveKeyManager.getEncryptionKey',
    action: () async {
      final List<int>? cached = _cachedKey;
      if (cached != null && cached.length == _keyLengthBytes) {
        return cached;
      }
      if (_useMacOsDebugFallbackKey) {
        _cachedKey = _macOsDebugFallbackKey;
        return _macOsDebugFallbackKey;
      }

      final String? storedKey = await _storage.read(_storageKey);
      if (storedKey != null && storedKey.isNotEmpty) {
        try {
          final List<int> key = base64Decode(storedKey);
          if (key.length == _keyLengthBytes) {
            _cachedKey = key;
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
      final String encoded = base64Encode(newKey);
      await _storage.write(_storageKey, encoded);
      final String? verify = await _storage.read(_storageKey);
      if (verify != encoded) {
        AppLogger.warning(
          'Secure storage unavailable; using non-persisted Hive encryption key '
          '(data will not persist across restarts).',
        );
      }
      _cachedKey = newKey;
      return newKey;
    },
    fallback: () {
      // Fallback: generate a key but don't persist it
      AppLogger.warning(
        'Failed to retrieve encryption key from secure storage, '
        'using temporary key (data will not persist across restarts).',
      );
      final List<int> key = _generateKey();
      _cachedKey = key;
      return key;
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
