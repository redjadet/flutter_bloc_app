import 'dart:convert';
import 'package:core/core.dart';

import 'package:flutter/foundation.dart';
import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:storage/storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

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

    test(
      'getEncryptionKey propagates read failure without rotating stored key',
      () async {
        final storage = _InterruptingReadSecretStorage();
        final validKey = List<int>.generate(32, (final index) => index);
        await storage.write('hive_encryption_key', base64Encode(validKey));

        storage.failReads = true;
        final keyManager = HiveKeyManager(storage: storage);

        await expectLater(
          keyManager.getEncryptionKey(),
          throwsA(isA<HiveKeyReadException>()),
        );

        storage.failReads = false;
        final stored = await storage.read('hive_encryption_key');
        expect(stored, base64Encode(validKey));

        final recoveredKey = await keyManager.getEncryptionKey();
        expect(recoveredKey, equals(validKey));
      },
    );

    test(
      'getEncryptionKey propagates read failure when storage is empty',
      () async {
        final storage = _FailingSecretStorage();
        final keyManager = HiveKeyManager(storage: storage);

        await expectLater(
          keyManager.getEncryptionKey(),
          throwsA(isA<HiveKeyReadException>()),
        );
      },
    );

    test('getEncryptionKey throws when new key cannot be persisted', () async {
      final storage = _NoPersistWriteSecretStorage();
      final keyManager = HiveKeyManager(storage: storage);

      await expectLater(
        keyManager.getEncryptionKey(),
        throwsA(isA<HiveKeyPersistenceException>()),
      );
    });

    test(
      'getEncryptionKey throws when persisted key fails verify read',
      () async {
        final storage = _VerifyMismatchSecretStorage();
        final keyManager = HiveKeyManager(storage: storage);

        await expectLater(
          keyManager.getEncryptionKey(),
          throwsA(isA<HiveKeyPersistenceException>()),
        );
      },
    );

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

    test('uses stable debug key on macOS debug with default storage', () async {
      addTearDown(() {
        debugDefaultTargetPlatformOverride = null;
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      final firstManager = HiveKeyManager();
      final secondManager = HiveKeyManager();

      final firstKey = await firstManager.getEncryptionKey();
      final secondKey = await secondManager.getEncryptionKey();

      expect(firstKey, hasLength(32));
      expect(secondKey, equals(firstKey));
      debugDefaultTargetPlatformOverride = null;
    });

    test('uses stable debug key on iOS debug with default storage', () async {
      addTearDown(() {
        debugDefaultTargetPlatformOverride = null;
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      final firstManager = HiveKeyManager();
      final secondManager = HiveKeyManager();

      final firstKey = await firstManager.getEncryptionKey();
      final secondKey = await secondManager.getEncryptionKey();

      expect(firstKey, hasLength(32));
      expect(secondKey, equals(firstKey));
      debugDefaultTargetPlatformOverride = null;
    });
  });
}

class _InterruptingReadSecretStorage implements SecretStorage {
  final Map<String, String> _values = <String, String>{};
  bool failReads = false;

  @override
  Future<String?> read(final String key) async {
    final result = await readResult(key);
    return result.getOrNull();
  }

  @override
  Future<Result<String?>> readResult(final String key) async {
    if (failReads) {
      return FailureResult<String?>(
        StorageFailure(kind: StorageFailureKind.read, key: key),
      );
    }
    return Success(_values[key]);
  }

  @override
  Future<void> write(final String key, final String value) async {
    _values[key] = value;
  }

  @override
  Future<void> delete(final String key) async {
    _values.remove(key);
  }

  @override
  T withoutLogs<T>(final T Function() action) => AppLogger.silence(action);

  @override
  Future<T> withoutLogsAsync<T>(final Future<T> Function() action) =>
      AppLogger.silenceAsync(action);
}

/// Simulates [FlutterSecureSecretStorage.write] swallowing write failures.
class _NoPersistWriteSecretStorage extends InMemorySecretStorage {
  @override
  Future<void> write(final String key, final String value) async {}
}

class _VerifyMismatchSecretStorage implements SecretStorage {
  int _readCount = 0;
  String? _written;

  @override
  Future<String?> read(final String key) async {
    final result = await readResult(key);
    return result.getOrNull();
  }

  @override
  Future<Result<String?>> readResult(final String key) async {
    _readCount++;
    if (_readCount == 1) {
      return const Success(null);
    }
    if (_written != null) {
      return Success('mismatch-$_written');
    }
    return const Success(null);
  }

  @override
  Future<void> write(final String key, final String value) async {
    _written = value;
  }

  @override
  Future<void> delete(final String key) async {
    _written = null;
    _readCount = 0;
  }

  @override
  T withoutLogs<T>(final T Function() action) => AppLogger.silence(action);

  @override
  Future<T> withoutLogsAsync<T>(final Future<T> Function() action) =>
      AppLogger.silenceAsync(action);
}

class _FailingSecretStorage implements SecretStorage {
  @override
  Future<String?> read(final String key) async {
    throw Exception('Storage read failed');
  }

  @override
  Future<Result<String?>> readResult(final String key) async =>
      const FailureResult<String?>(
        UnknownFailure(message: 'Storage read failed'),
      );

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
