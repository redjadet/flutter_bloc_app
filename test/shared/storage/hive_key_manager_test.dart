import 'dart:convert';

import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HiveKeyManager', () {
    test('getEncryptionKey generates new key when storage is empty', () async {
      final storage = InMemorySecretStorage();
      final keyManager = HiveKeyManager(storage: storage);

      final key = await keyManager.getEncryptionKey();

      expect(key, hasLength(32)); // 256 bits = 32 bytes
      expect(key, isA<List<int>>());
    });

    test('getEncryptionKey returns stored key when available', () async {
      final storage = InMemorySecretStorage();
      final keyManager = HiveKeyManager(storage: storage);

      // Generate and store a key
      final firstKey = await keyManager.getEncryptionKey();
      await storage.write('hive_encryption_key', base64Encode(firstKey));

      // Create new manager instance
      final keyManager2 = HiveKeyManager(storage: storage);
      final secondKey = await keyManager2.getEncryptionKey();

      expect(secondKey, equals(firstKey));
    });

    test(
      'getEncryptionKey generates new key when stored key has invalid length',
      () async {
        final storage = InMemorySecretStorage();
        // Store an invalid key (wrong length)
        await storage.write('hive_encryption_key', base64Encode([1, 2, 3]));

        final keyManager = HiveKeyManager(storage: storage);
        final key = await keyManager.getEncryptionKey();

        expect(key, hasLength(32));
      },
    );

    test(
      'getEncryptionKey generates new key when stored key is invalid base64',
      () async {
        final storage = InMemorySecretStorage();
        // Store invalid base64
        await storage.write('hive_encryption_key', 'invalid-base64!!!');

        final keyManager = HiveKeyManager(storage: storage);
        final key = await keyManager.getEncryptionKey();

        expect(key, hasLength(32));
      },
    );

    test('getEncryptionKey uses fallback when storage read fails', () async {
      final storage = _FailingSecretStorage();
      final keyManager = HiveKeyManager(storage: storage);

      final key = await keyManager.getEncryptionKey();

      // Should still return a valid key (from fallback)
      expect(key, hasLength(32));
    });

    test('getEncryptionKey generates unique keys', () async {
      final storage1 = InMemorySecretStorage();
      final storage2 = InMemorySecretStorage();
      final keyManager1 = HiveKeyManager(storage: storage1);
      final keyManager2 = HiveKeyManager(storage: storage2);

      final key1 = await keyManager1.getEncryptionKey();
      final key2 = await keyManager2.getEncryptionKey();

      // Keys should be different (very high probability)
      expect(key1, isNot(equals(key2)));
    });
  });
}

class _FailingSecretStorage implements SecretStorage {
  @override
  Future<String?> read(final String key) async {
    throw Exception('Storage read failed');
  }

  @override
  Future<void> write(final String key, final String value) async {
    throw Exception('Storage write failed');
  }

  @override
  Future<void> delete(final String key) async {
    throw Exception('Storage delete failed');
  }

  @override
  T withoutLogs<T>(final T Function() action) => AppLogger.silence(action);

  @override
  Future<T> withoutLogsAsync<T>(final Future<T> Function() action) =>
      AppLogger.silenceAsync(action);
}
