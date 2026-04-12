import 'package:flutter_bloc_app/core/config/app_runtime_config.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_bloc_app/features/chat/data/render_orchestration_hf_token_provider.dart';
import 'package:flutter_bloc_app/features/remote_config/data/repositories/remote_config_repository.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_service.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LayeredRenderOrchestrationHfTokenProvider', () {
    late InMemorySecretStorage storage;

    setUp(() {
      storage = InMemorySecretStorage();
      SecretConfig.resetForTest();
    });

    tearDown(() {
      SecretConfig.resetForTest();
      FlavorManager.current = Flavor.dev;
    });

    test('dev: reads Remote Config token, persists to secure storage', () async {
      FlavorManager.current = Flavor.dev;
      final LayeredRenderOrchestrationHfTokenProvider provider =
          LayeredRenderOrchestrationHfTokenProvider(
            runtime: AppRuntimeConfig(flavor: Flavor.dev, skeletonDelay: Duration.zero),
            remoteConfig: _FakeRemoteConfig(
              strings: <String, String>{
                RemoteConfigRepository.renderChatDemoHfReadTokenKey: '  rc-hf  ',
              },
            ),
            storage: storage,
          );

      final String? first = await provider.readHfTokenForUpstream();
      expect(first, 'rc-hf');

      final String? cached = await storage.read(LayeredRenderOrchestrationHfTokenProvider.cacheKey);
      expect(cached, 'rc-hf');
    });

    test('dev: prefers secure storage over Remote Config', () async {
      FlavorManager.current = Flavor.dev;
      await storage.write(LayeredRenderOrchestrationHfTokenProvider.cacheKey, 'cached-only');

      final LayeredRenderOrchestrationHfTokenProvider provider =
          LayeredRenderOrchestrationHfTokenProvider(
            runtime: AppRuntimeConfig(flavor: Flavor.dev, skeletonDelay: Duration.zero),
            remoteConfig: _FakeRemoteConfig(
              strings: <String, String>{
                RemoteConfigRepository.renderChatDemoHfReadTokenKey: 'from-rc',
              },
            ),
            storage: storage,
          );

      expect(await provider.readHfTokenForUpstream(), 'cached-only');
    });

    test('non-dev: skips Remote Config, uses SecretConfig when loaded', () async {
      FlavorManager.current = Flavor.staging;
      SecretConfig.storage = storage;
      await storage.write('huggingface_api_key', 'secure-hf');
      await SecretConfig.load(allowAssetFallback: false, persistToSecureStorage: false);

      final LayeredRenderOrchestrationHfTokenProvider provider =
          LayeredRenderOrchestrationHfTokenProvider(
            runtime: AppRuntimeConfig(flavor: Flavor.staging, skeletonDelay: Duration.zero),
            remoteConfig: _FakeRemoteConfig(
              strings: <String, String>{
                RemoteConfigRepository.renderChatDemoHfReadTokenKey: 'from-rc',
              },
            ),
            storage: storage,
          );

      expect(await provider.readHfTokenForUpstream(), 'secure-hf');
    });

    test('non-dev: Callable override wins before SecretConfig', () async {
      FlavorManager.current = Flavor.staging;
      SecretConfig.storage = storage;
      await storage.write('huggingface_api_key', 'secure-hf');
      await SecretConfig.load(allowAssetFallback: false, persistToSecureStorage: false);

      final LayeredRenderOrchestrationHfTokenProvider provider =
          LayeredRenderOrchestrationHfTokenProvider(
            runtime: AppRuntimeConfig(flavor: Flavor.staging, skeletonDelay: Duration.zero),
            remoteConfig: _FakeRemoteConfig(),
            storage: storage,
            callableTokenOverride: () async => 'from-callable',
          );

      expect(await provider.readHfTokenForUpstream(), 'from-callable');
      expect(
        await storage.read(LayeredRenderOrchestrationHfTokenProvider.cacheKey),
        'from-callable',
      );
    });

    test('migrates legacy RC cache key into primary cache', () async {
      FlavorManager.current = Flavor.dev;
      await storage.write(LayeredRenderOrchestrationHfTokenProvider.legacyRcCacheKey, 'legacy-rc');

      final LayeredRenderOrchestrationHfTokenProvider provider =
          LayeredRenderOrchestrationHfTokenProvider(
            runtime: AppRuntimeConfig(flavor: Flavor.dev, skeletonDelay: Duration.zero),
            remoteConfig: _FakeRemoteConfig(),
            storage: storage,
          );

      expect(await provider.readHfTokenForUpstream(), 'legacy-rc');
      expect(await storage.read(LayeredRenderOrchestrationHfTokenProvider.cacheKey), 'legacy-rc');
      expect(
        await storage.read(LayeredRenderOrchestrationHfTokenProvider.legacyRcCacheKey),
        isNull,
      );
    });

    test('clearRenderOrchestrationTokenCache removes primary and legacy keys', () async {
      FlavorManager.current = Flavor.dev;
      await storage.write(LayeredRenderOrchestrationHfTokenProvider.cacheKey, 'a');
      await storage.write(LayeredRenderOrchestrationHfTokenProvider.legacyRcCacheKey, 'b');

      final LayeredRenderOrchestrationHfTokenProvider provider =
          LayeredRenderOrchestrationHfTokenProvider(
            runtime: AppRuntimeConfig(flavor: Flavor.dev, skeletonDelay: Duration.zero),
            remoteConfig: _FakeRemoteConfig(),
            storage: storage,
          );

      await provider.clearRenderOrchestrationTokenCache();
      expect(await storage.read(LayeredRenderOrchestrationHfTokenProvider.cacheKey), isNull);
      expect(
        await storage.read(LayeredRenderOrchestrationHfTokenProvider.legacyRcCacheKey),
        isNull,
      );
    });

    test('single-flight: concurrent reads share one resolution', () async {
      FlavorManager.current = Flavor.dev;
      int getStringCalls = 0;
      final LayeredRenderOrchestrationHfTokenProvider provider =
          LayeredRenderOrchestrationHfTokenProvider(
            runtime: AppRuntimeConfig(flavor: Flavor.dev, skeletonDelay: Duration.zero),
            remoteConfig: _CountingRemoteConfig(onGetString: () => getStringCalls++, value: 'once'),
            storage: storage,
          );

      final List<String?> results = await Future.wait(<Future<String?>>[
        provider.readHfTokenForUpstream(),
        provider.readHfTokenForUpstream(),
        provider.readHfTokenForUpstream(),
      ]);

      expect(results, everyElement('once'));
      expect(getStringCalls, 1);
    });
  });
}

class _FakeRemoteConfig implements RemoteConfigService {
  _FakeRemoteConfig({this.strings = const <String, String>{}});

  final Map<String, String> strings;

  @override
  Future<void> clearCache() async {}

  @override
  Future<void> forceFetch() async {}

  @override
  bool getBool(final String key) => false;

  @override
  double getDouble(final String key) => 0;

  @override
  int getInt(final String key) => 0;

  @override
  String getString(final String key) => strings[key] ?? '';

  @override
  Future<void> initialize() async {}
}

class _CountingRemoteConfig implements RemoteConfigService {
  _CountingRemoteConfig({required this.onGetString, required this.value});

  final void Function() onGetString;
  final String value;

  @override
  Future<void> clearCache() async {}

  @override
  Future<void> forceFetch() async {}

  @override
  bool getBool(final String key) => false;

  @override
  double getDouble(final String key) => 0;

  @override
  int getInt(final String key) => 0;

  @override
  String getString(final String key) {
    onGetString();
    return value;
  }

  @override
  Future<void> initialize() async {}
}
