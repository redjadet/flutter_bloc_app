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
