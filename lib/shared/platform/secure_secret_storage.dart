import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecretStorage {
  Future<String?> read(final String key);
  Future<void> write(final String key, final String value);
  Future<void> delete(final String key);

  T withoutLogs<T>(final T Function() action) => action();
  Future<T> withoutLogsAsync<T>(final Future<T> Function() action) => action();
}

/// Whether debug builds should avoid platform secure storage.
///
/// macOS and iOS simulators often lack the entitlements needed for
/// `flutter_secure_storage`, which surfaces as Keychain error -34018 and
/// breaks Hive persistence when encryption keys cannot be stored.
///
/// Web debug uses a stable in-memory key so hot restarts do not desync Hive
/// encryption from IndexedDB payloads (avoids "Invalid or corrupted pad block").
bool useInMemorySecretStorageInDebug() {
  if (kReleaseMode) {
    return false;
  }
  if (kIsWeb) {
    return true;
  }
  return defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

/// Whether Hive boxes should skip AES encryption in debug builds.
///
/// Web IndexedDB + hot restart often leaves ciphertext that no longer matches
/// the in-memory debug key ("Invalid or corrupted pad block"). Unencrypted
/// boxes in web debug avoid that class of startup failures.
bool useUnencryptedHiveBoxesInDebug() => !kReleaseMode && kIsWeb;

/// Whether Hive boxes should use an in-memory backend in debug builds.
///
/// Keep disabled: web parity needs IndexedDB durability across reloads. Debug
/// corruption recovery uses namespace rotation + box deletion instead.
bool useInMemoryHiveBoxesInDebug() => false;

/// Default secret storage for the current platform.
///
/// Apple-platform and web debug builds use [InMemorySecretStorage] because
/// Keychain / browser secure storage is unreliable in local development.
SecretStorage createDefaultSecretStorage() {
  if (useInMemorySecretStorageInDebug()) {
    return InMemorySecretStorage();
  }
  return FlutterSecureSecretStorage();
}

class FlutterSecureSecretStorage implements SecretStorage {
  FlutterSecureSecretStorage({final FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(final String key) async {
    try {
      return await _storage.read(key: key);
    } on PlatformException catch (error, stackTrace) {
      AppLogger.error(
        'FlutterSecureSecretStorage.read failed for key "$key"',
        error,
        stackTrace,
      );
      return null;
    } on MissingPluginException catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(final String key, final String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on PlatformException catch (error, stackTrace) {
      AppLogger.error(
        'FlutterSecureSecretStorage.write failed for key "$key"',
        error,
        stackTrace,
      );
    } on MissingPluginException catch (_) {
      // Ignore when secure storage is unavailable (e.g. tests).
    }
  }

  @override
  Future<void> delete(final String key) async {
    try {
      await _storage.delete(key: key);
    } on PlatformException catch (error, stackTrace) {
      AppLogger.error(
        'FlutterSecureSecretStorage.delete failed for key "$key"',
        error,
        stackTrace,
      );
    } on MissingPluginException catch (_) {
      // Ignore when secure storage is unavailable.
    }
  }

  @override
  T withoutLogs<T>(final T Function() action) => AppLogger.silence(action);

  @override
  Future<T> withoutLogsAsync<T>(final Future<T> Function() action) =>
      AppLogger.silenceAsync(action);
}

class InMemorySecretStorage implements SecretStorage {
  final Map<String, String> _store = <String, String>{};

  @override
  Future<String?> read(final String key) async => _store[key];

  @override
  Future<void> write(final String key, final String value) async {
    _store[key] = value;
  }

  @override
  Future<void> delete(final String key) async {
    _store.remove(key);
  }

  @override
  T withoutLogs<T>(final T Function() action) => AppLogger.silence(action);

  @override
  Future<T> withoutLogsAsync<T>(final Future<T> Function() action) =>
      AppLogger.silenceAsync(action);
}
