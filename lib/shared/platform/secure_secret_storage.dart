import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecretStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);

  T withoutLogs<T>(T Function() action) => action();
  Future<T> withoutLogsAsync<T>(Future<T> Function() action) => action();
}

class FlutterSecureSecretStorage implements SecretStorage {
  FlutterSecureSecretStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } on PlatformException catch (_) {
      return null;
    } on MissingPluginException catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on PlatformException catch (_) {
      // Ignore when secure storage is unavailable (e.g. tests).
    } on MissingPluginException catch (_) {
      // Ignore when secure storage is unavailable (e.g. tests).
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } on PlatformException catch (_) {
      // Ignore when secure storage is unavailable.
    } on MissingPluginException catch (_) {
      // Ignore when secure storage is unavailable.
    }
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
