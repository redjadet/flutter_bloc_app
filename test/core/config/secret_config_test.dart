import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SecretConfig.resetForTest();
  });

  test('loads secrets from secure storage when present', () async {
    final _FakeSecretStorage storage = _FakeSecretStorage(
      initialValues: <String, String>{
        'huggingface_api_key': 'token-123',
        'huggingface_model': 'awesome-model',
        'huggingface_use_chat_completions': 'true',
      },
    );

    SecretConfig.configureStorage(storage);

    await SecretConfig.load();

    expect(SecretConfig.huggingfaceApiKey, 'token-123');
    expect(SecretConfig.huggingfaceModel, 'awesome-model');
    expect(SecretConfig.useChatCompletions, isTrue);
    expect(storage.writeCalls, isEmpty);
  });

  test('falls back to bundled asset secrets in debug builds', () async {
    final _FakeSecretStorage storage = _FakeSecretStorage();
    SecretConfig.configureStorage(storage);

    final Map<String, dynamic> assetSecrets = <String, dynamic>{
      'HUGGINGFACE_API_KEY': 'asset-key',
      'HUGGINGFACE_MODEL': 'asset-model',
      'HUGGINGFACE_USE_CHAT_COMPLETIONS': 'TrUe',
    };
    SecretConfig.debugAssetBundle = _FakeAssetBundle(jsonEncode(assetSecrets));

    await SecretConfig.load();

    expect(SecretConfig.huggingfaceApiKey, 'asset-key');
    expect(SecretConfig.huggingfaceModel, 'asset-model');
    expect(SecretConfig.useChatCompletions, isTrue);
    expect(storage.writeCalls, isEmpty);
  });

  test('uses environment overrides and persists them by default', () async {
    final _FakeSecretStorage storage = _FakeSecretStorage();
    SecretConfig.configureStorage(storage);
    SecretConfig.debugAssetBundle = _FakeAssetBundle.throwing();
    SecretConfig.debugEnvironment = <String, dynamic>{
      'HUGGINGFACE_API_KEY': 'env-key',
      'HUGGINGFACE_MODEL': 'env-model',
      'HUGGINGFACE_USE_CHAT_COMPLETIONS': true,
    };

    await SecretConfig.load();

    expect(SecretConfig.huggingfaceApiKey, 'env-key');
    expect(SecretConfig.huggingfaceModel, 'env-model');
    expect(SecretConfig.useChatCompletions, isTrue);
    expect(storage.writeCalls, containsPair('huggingface_api_key', 'env-key'));
    expect(storage.writeCalls, containsPair('huggingface_model', 'env-model'));
    expect(
      storage.writeCalls,
      containsPair('huggingface_use_chat_completions', 'true'),
    );
  });

  test('skips secure storage persistence when disabled', () async {
    final _FakeSecretStorage storage = _FakeSecretStorage();
    SecretConfig.configureStorage(storage);
    SecretConfig.debugAssetBundle = _FakeAssetBundle.throwing();
    SecretConfig.debugEnvironment = <String, dynamic>{
      'HUGGINGFACE_API_KEY': 'env-key',
    };

    await SecretConfig.load(persistToSecureStorage: false);

    expect(SecretConfig.huggingfaceApiKey, 'env-key');
    expect(storage.writeCalls, isEmpty);
  });
}

class _FakeSecretStorage implements SecretStorage {
  _FakeSecretStorage({Map<String, String>? initialValues})
    : _values = Map<String, String>.from(initialValues ?? <String, String>{});

  final Map<String, String> _values;
  final Map<String, String> writeCalls = <String, String>{};

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
    writeCalls[key] = value;
  }

  @override
  T withoutLogs<T>(T Function() action) => action();

  @override
  Future<T> withoutLogsAsync<T>(Future<T> Function() action) => action();
}

class _FakeAssetBundle extends CachingAssetBundle {
  _FakeAssetBundle(this._response);

  _FakeAssetBundle.throwing() : _response = null;

  final String? _response;

  @override
  Future<ByteData> load(String key) async {
    if (_response == null) {
      throw FlutterError('Asset $key missing');
    }
    final List<int> bytes = utf8.encode(_response);
    return ByteData.view(Uint8List.fromList(bytes).buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (_response == null) {
      throw FlutterError('Asset $key missing');
    }
    return _response;
  }
}
