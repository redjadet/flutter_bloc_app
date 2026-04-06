import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/core/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/config/supabase_config_provider.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_service.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _FakeRemoteConfigService implements RemoteConfigService {
  _FakeRemoteConfigService(this._values);

  final Map<String, Object?> _values;

  bool didForceFetch = false;
  Object? forceFetchError;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> forceFetch() async {
    if (forceFetchError != null) {
      throw forceFetchError!;
    }
    didForceFetch = true;
  }

  @override
  Future<void> clearCache() async {}

  @override
  bool getBool(final String key) => (_values[key] as bool?) ?? false;

  @override
  String getString(final String key) => (_values[key] as String?) ?? '';

  @override
  int getInt(final String key) => (_values[key] as int?) ?? 0;

  @override
  double getDouble(final String key) => (_values[key] as double?) ?? 0.0;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SecretConfig.resetForTest();
    SupabaseBootstrapService.resetForTest();
    SupabaseBootstrapService.initializeClient =
        ({required final url, required final anonKey}) async {};
  });

  test('fetches remote config payload and persists + applies config', () async {
    final storage = InMemorySecretStorage();
    SecretConfig.storage = storage;

    final auth = _MockFirebaseAuth();
    final user = _MockUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.getIdToken(true)).thenAnswer((_) async => 'token');

    final remoteConfig = _FakeRemoteConfigService(<String, Object?>{
      'SUPABASE_URL': 'https://example.supabase.co',
      'SUPABASE_ANON_KEY': 'anon',
      'SUPABASE_CONFIG_VERSION': 1,
      'SUPABASE_CONFIG_ENABLED': true,
    });

    final provider = SupabaseConfigProvider(
      auth: auth,
      remoteConfig: remoteConfig,
      storage: storage,
    );

    final result = await provider.fetchAndApplyIfNeeded();

    expect(result.updated, isTrue);
    expect(result.skipped, isFalse);
    expect(result.version, 'rcv:1');
    expect(SecretConfig.supabaseUrl, 'https://example.supabase.co');
    expect(SecretConfig.supabaseAnonKey, 'anon');
    expect(SecretConfig.supabaseConfigVersion, 'rcv:1');
    expect(remoteConfig.didForceFetch, isTrue);
  });

  test('does not update when version unchanged', () async {
    final storage = InMemorySecretStorage();
    SecretConfig.storage = storage;

    SecretConfig.applySupabaseConfig(
      supabaseUrl: 'https://example.supabase.co',
      supabaseAnonKey: 'anon',
      version: 'rcv:1',
      firebaseProjectId: null,
    );

    final auth = _MockFirebaseAuth();
    final user = _MockUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.getIdToken(true)).thenAnswer((_) async => 'token');

    final remoteConfig = _FakeRemoteConfigService(<String, Object?>{
      'SUPABASE_URL': 'https://example.supabase.co',
      'SUPABASE_ANON_KEY': 'anon',
      'SUPABASE_CONFIG_VERSION': 1,
      'SUPABASE_CONFIG_ENABLED': true,
    });

    final provider = SupabaseConfigProvider(
      auth: auth,
      remoteConfig: remoteConfig,
      storage: storage,
    );

    final result = await provider.fetchAndApplyIfNeeded();

    expect(result.updated, isFalse);
    expect(result.skipped, isFalse);
    expect(result.reason, 'version_unchanged');
    expect(SecretConfig.supabaseConfigVersion, 'rcv:1');
    expect(remoteConfig.didForceFetch, isTrue);
  });

  test('updates when version changes', () async {
    final storage = InMemorySecretStorage();
    SecretConfig.storage = storage;

    SecretConfig.applySupabaseConfig(
      supabaseUrl: 'https://example.supabase.co',
      supabaseAnonKey: 'anon',
      version: 'rcv:1',
      firebaseProjectId: null,
    );

    final auth = _MockFirebaseAuth();
    final user = _MockUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.getIdToken(true)).thenAnswer((_) async => 'token');

    final remoteConfig = _FakeRemoteConfigService(<String, Object?>{
      'SUPABASE_URL': 'https://example.supabase.co',
      'SUPABASE_ANON_KEY': 'anon',
      'SUPABASE_CONFIG_VERSION': 2,
      'SUPABASE_CONFIG_ENABLED': true,
    });

    final provider = SupabaseConfigProvider(
      auth: auth,
      remoteConfig: remoteConfig,
      storage: storage,
    );

    final result = await provider.fetchAndApplyIfNeeded();

    expect(result.updated, isTrue);
    expect(result.skipped, isFalse);
    expect(result.version, 'rcv:2');
    expect(SecretConfig.supabaseConfigVersion, 'rcv:2');
  });

  test('skips invalid payload and does not overwrite existing config', () async {
    final storage = InMemorySecretStorage();
    SecretConfig.storage = storage;

    SecretConfig.applySupabaseConfig(
      supabaseUrl: 'https://example.supabase.co',
      supabaseAnonKey: 'anon',
      version: 'rcv:1',
      firebaseProjectId: null,
    );

    final auth = _MockFirebaseAuth();
    final user = _MockUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.getIdToken(true)).thenAnswer((_) async => 'token');

    final remoteConfig = _FakeRemoteConfigService(<String, Object?>{
      'SUPABASE_URL': '',
      'SUPABASE_ANON_KEY': 'anon',
      'SUPABASE_CONFIG_VERSION': 2,
      'SUPABASE_CONFIG_ENABLED': true,
    });

    final provider = SupabaseConfigProvider(
      auth: auth,
      remoteConfig: remoteConfig,
      storage: storage,
    );

    final result = await provider.fetchAndApplyIfNeeded(force: true);

    expect(result.updated, isFalse);
    expect(result.skipped, isTrue);
    expect(result.reason, 'invalid_payload');
    expect(SecretConfig.supabaseConfigVersion, 'rcv:1');
    expect(SecretConfig.supabaseUrl, 'https://example.supabase.co');
  });

  test('skips when disabled and a cached config exists', () async {
    final storage = InMemorySecretStorage();
    SecretConfig.storage = storage;

    SecretConfig.applySupabaseConfig(
      supabaseUrl: 'https://example.supabase.co',
      supabaseAnonKey: 'anon',
      version: 'rcv:1',
      firebaseProjectId: null,
    );

    final auth = _MockFirebaseAuth();
    final user = _MockUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.getIdToken(true)).thenAnswer((_) async => 'token');

    final remoteConfig = _FakeRemoteConfigService(<String, Object?>{
      'SUPABASE_URL': 'https://example.supabase.co',
      'SUPABASE_ANON_KEY': 'anon',
      'SUPABASE_CONFIG_VERSION': 2,
      'SUPABASE_CONFIG_ENABLED': false,
    });

    final provider = SupabaseConfigProvider(
      auth: auth,
      remoteConfig: remoteConfig,
      storage: storage,
    );

    final result = await provider.fetchAndApplyIfNeeded(force: true);

    expect(result.updated, isFalse);
    expect(result.skipped, isTrue);
    expect(result.reason, 'remote_config_disabled');
    expect(SecretConfig.supabaseConfigVersion, 'rcv:1');
  });

  test('skips when disabled and no cached config exists', () async {
    final storage = InMemorySecretStorage();
    SecretConfig.storage = storage;

    final auth = _MockFirebaseAuth();
    final user = _MockUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.getIdToken(true)).thenAnswer((_) async => 'token');

    final remoteConfig = _FakeRemoteConfigService(<String, Object?>{
      'SUPABASE_URL': 'https://example.supabase.co',
      'SUPABASE_ANON_KEY': 'anon',
      'SUPABASE_CONFIG_VERSION': 1,
      'SUPABASE_CONFIG_ENABLED': false,
    });

    final provider = SupabaseConfigProvider(
      auth: auth,
      remoteConfig: remoteConfig,
      storage: storage,
    );

    final result = await provider.fetchAndApplyIfNeeded(force: true);

    expect(result.updated, isFalse);
    expect(result.skipped, isTrue);
    expect(result.reason, 'remote_config_disabled');
    expect(SecretConfig.supabaseConfigVersion, isNull);
    expect(SecretConfig.supabaseUrl, isNull);
  });

  test('skips cleanly when remote config is unavailable', () async {
    final auth = _MockFirebaseAuth();
    when(() => auth.currentUser).thenReturn(null);

    final provider = SupabaseConfigProvider(auth: auth);

    final result = await provider.fetchAndApplyIfNeeded();

    expect(result.updated, isFalse);
    expect(result.skipped, isTrue);
    expect(result.reason, 'firebase_not_initialized');
  });

  test('skips cleanly when forceFetch fails but cached config exists', () async {
    final storage = InMemorySecretStorage();
    SecretConfig.storage = storage;

    SecretConfig.applySupabaseConfig(
      supabaseUrl: 'https://example.supabase.co',
      supabaseAnonKey: 'anon',
      version: 'rcv:1',
      firebaseProjectId: null,
    );

    final auth = _MockFirebaseAuth();
    final user = _MockUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.getIdToken(true)).thenAnswer((_) async => 'token');

    final remoteConfig = _FakeRemoteConfigService(<String, Object?>{
      'SUPABASE_URL': 'https://example.supabase.co',
      'SUPABASE_ANON_KEY': 'anon',
      'SUPABASE_CONFIG_VERSION': 2,
      'SUPABASE_CONFIG_ENABLED': true,
    });
    remoteConfig.forceFetchError = Exception('network');

    final provider = SupabaseConfigProvider(
      auth: auth,
      remoteConfig: remoteConfig,
      storage: storage,
    );

    final result = await provider.fetchAndApplyIfNeeded();

    expect(result.updated, isFalse);
    expect(result.skipped, isTrue);
    expect(result.reason, 'remote_config_fetch_failed');
    expect(SecretConfig.supabaseConfigVersion, 'rcv:1');
  });
}
