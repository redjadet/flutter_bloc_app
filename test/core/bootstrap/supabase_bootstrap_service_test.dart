import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/core/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SecretConfig.resetForTest();
    SecretConfig.storage = _MemorySecretStorage();
    SecretConfig.debugAssetBundle = _FakeAssetBundle.throwing();
    SupabaseBootstrapService.resetForTest();
  });

  tearDown(() {
    SecretConfig.resetForTest();
    SupabaseBootstrapService.resetForTest();
  });

  test('initializeSupabase skips when secrets are missing', () async {
    var callCount = 0;
    SupabaseBootstrapService.initializeClient =
        ({required final String url, required final String anonKey}) async {
          callCount++;
        };

    await SecretConfig.load(persistToSecureStorage: false);
    await SupabaseBootstrapService.initializeSupabase();

    expect(callCount, 0);
    expect(SupabaseBootstrapService.isSupabaseInitialized, isFalse);
  });

  test('initializeSupabase is single-flight for concurrent calls', () async {
    final completer = Completer<void>();
    var callCount = 0;
    SupabaseBootstrapService.initializeClient =
        ({required final String url, required final String anonKey}) async {
          callCount++;
          await completer.future;
        };

    SecretConfig.debugEnvironment = <String, dynamic>{
      'SUPABASE_URL': 'https://example.supabase.co',
      'SUPABASE_ANON_KEY': 'anon-key',
    };
    await SecretConfig.load(persistToSecureStorage: false);

    final first = SupabaseBootstrapService.initializeSupabase();
    final second = SupabaseBootstrapService.initializeSupabase();

    expect(callCount, 1);
    expect(identical(first, second), isTrue);

    completer.complete();
    await Future.wait<void>(<Future<void>>[first, second]);

    expect(SupabaseBootstrapService.isSupabaseInitialized, isTrue);
    expect(callCount, 1);
  });

  test('initializeSupabase retries after a failed initialization', () async {
    var callCount = 0;
    var shouldFail = true;
    SupabaseBootstrapService.initializeClient =
        ({required final String url, required final String anonKey}) async {
          callCount++;
          if (shouldFail) {
            throw StateError('boom');
          }
        };

    SecretConfig.debugEnvironment = <String, dynamic>{
      'SUPABASE_URL': 'https://example.supabase.co',
      'SUPABASE_ANON_KEY': 'anon-key',
    };
    await SecretConfig.load(persistToSecureStorage: false);

    await SupabaseBootstrapService.initializeSupabase();
    expect(SupabaseBootstrapService.isSupabaseInitialized, isFalse);

    shouldFail = false;
    await SupabaseBootstrapService.initializeSupabase();

    expect(callCount, 2);
    expect(SupabaseBootstrapService.isSupabaseInitialized, isTrue);
  });
}

class _MemorySecretStorage implements SecretStorage {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> delete(final String key) async {
    _values.remove(key);
  }

  @override
  Future<String?> read(final String key) async => _values[key];

  @override
  Future<void> write(final String key, final String value) async {
    _values[key] = value;
  }

  @override
  T withoutLogs<T>(final T Function() action) => action();

  @override
  Future<T> withoutLogsAsync<T>(final Future<T> Function() action) => action();
}

class _FakeAssetBundle extends CachingAssetBundle {
  _FakeAssetBundle(this._response);

  _FakeAssetBundle.throwing() : _response = null;

  final String? _response;

  @override
  Future<ByteData> load(final String key) async {
    if (_response == null) {
      throw FlutterError('Asset $key missing');
    }
    final List<int> bytes = utf8.encode(_response);
    return ByteData.view(Uint8List.fromList(bytes).buffer);
  }

  @override
  Future<String> loadString(final String key, {final bool cache = true}) async {
    if (_response == null) {
      throw FlutterError('Asset $key missing');
    }
    return _response;
  }
}
