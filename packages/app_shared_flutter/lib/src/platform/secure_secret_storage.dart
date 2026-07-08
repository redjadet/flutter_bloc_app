import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/logger.dart';

abstract class SecretStorage {
  Future<String?> read(final String key);

  Future<Result<String?>> readResult(final String key);

  Future<void> write(final String key, final String value);
  Future<void> delete(final String key);

  T withoutLogs<T>(final T Function() action) => action();
  Future<T> withoutLogsAsync<T>(final Future<T> Function() action) => action();
}

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

bool useUnencryptedHiveBoxesInDebug() => !kReleaseMode && kIsWeb;

bool useInMemoryHiveBoxesInDebug() => false;

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
    final result = await readResult(key);
    return result.getOrNull();
  }

  @override
  Future<Result<String?>> readResult(final String key) async {
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
  Future<void> write(final String key, final String value) async {
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
  Future<void> delete(final String key) async {
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
  Future<Result<String?>> readResult(final String key) async =>
      Success<String?>(_store[key]);

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
