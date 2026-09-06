import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/logger.dart';

abstract class SecretStorage {
  Future<String?> read(String key);

  Future<Result<String?>> readResult(String key);

  Future<void> write(String key, String value);
  Future<void> delete(String key);

  T withoutLogs<T>(T Function() action) => action();
  Future<T> withoutLogsAsync<T>(Future<T> Function() action) => action();
}

bool useInMemorySecretStorageInDebug() {
  if (kReleaseMode) {
    return false;
  }
  if (kIsWeb) {
    return true;
  }
  // Apple Keychain and some Android emulator Keystore paths are unreliable in
  // debug/integration; use in-memory storage so Hive can still open.
  return defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;
}

bool useUnencryptedHiveBoxesInDebug() => !kReleaseMode && kIsWeb;

bool useInMemoryHiveBoxesInDebug() => false;

SecretStorage createDefaultSecretStorage() {
  if (useInMemorySecretStorageInDebug()) {
    return InMemorySecretStorage();
  }
  return FlutterSecureSecretStorage();
}

/// Apple Keychain policy for session tokens and encryption keys.
///
/// Library defaults use [KeychainAccessibility.unlocked], which can migrate
/// via encrypted backups to another device. Auth material must stay
/// device-bound (`…ThisDeviceOnly`) and off iCloud Keychain sync.
///
/// Prefer [KeychainAccessibility.first_unlock_this_device] so background work
/// after reboot can still read secrets once the user has unlocked once.
class FlutterSecureSecretStorage implements SecretStorage {
  FlutterSecureSecretStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? createDefaultFlutterSecureStorage();

  /// iOS options: device-only, no iCloud Keychain sync.
  static const IOSOptions defaultIosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
    synchronizable: false,
  );

  /// macOS options: same device-bound accessibility as iOS.
  static const MacOsOptions defaultMacOsOptions = MacOsOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
    synchronizable: false,
  );

  /// Builds [FlutterSecureStorage] with explicit Apple accessibility.
  static FlutterSecureStorage createDefaultFlutterSecureStorage() {
    return const FlutterSecureStorage(
      iOptions: defaultIosOptions,
      mOptions: defaultMacOsOptions,
    );
  }

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) async {
    final result = await readResult(key);
    return result.getOrNull();
  }

  @override
  Future<Result<String?>> readResult(String key) async {
    try {
      final value = await _storage.read(key: key);
      return Success<String?>(value);
    } on PlatformException catch (error, stackTrace) {
      AppLogger.error(
        'FlutterSecureSecretStorage.read failed for key "$key"',
        error,
        stackTrace,
      );
      return FailureResult(
        StorageFailure(kind: StorageFailureKind.read, key: key, cause: error),
      );
    } on MissingPluginException catch (error) {
      return FailureResult(
        PlatformFailure(PlatformFailureReason.unavailable, cause: error),
      );
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on PlatformException catch (error, stackTrace) {
      AppLogger.error(
        'FlutterSecureSecretStorage.write failed for key "$key"',
        error,
        stackTrace,
      );
    } on MissingPluginException catch (_) {}
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } on PlatformException catch (error, stackTrace) {
      AppLogger.error(
        'FlutterSecureSecretStorage.delete failed for key "$key"',
        error,
        stackTrace,
      );
    } on MissingPluginException catch (_) {}
  }

  @override
  T withoutLogs<T>(T Function() action) => AppLogger.silence(action);

  @override
  Future<T> withoutLogsAsync<T>(Future<T> Function() action) =>
      AppLogger.silenceAsync(action);
}

class InMemorySecretStorage implements SecretStorage {
  final Map<String, String> _store = <String, String>{};

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<Result<String?>> readResult(String key) async =>
      Success<String?>(_store[key]);

  @override
  Future<void> write(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _store.remove(key);
  }

  @override
  T withoutLogs<T>(T Function() action) => AppLogger.silence(action);

  @override
  Future<T> withoutLogsAsync<T>(Future<T> Function() action) =>
      AppLogger.silenceAsync(action);
}
