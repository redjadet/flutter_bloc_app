import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:feature_flags/feature_flags.dart';
import 'package:flutter_bloc_app/app/config/app_runtime_config.dart';
import 'package:flutter_bloc_app/app/config/flavor.dart';
import 'package:flutter_bloc_app/app/config/secret_config.dart';
import 'package:flutter_bloc_app/features/chat/data/render_orchestration_hf_token_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LayeredRenderOrchestrationHfTokenProvider', () {
    late InMemorySecretStorage storage;

    setUp(() {
      storage = InMemorySecretStorage();
      SecretConfig.resetForTest();
      SecretConfig.debugEnvironment = <String, dynamic>{};
    });

    tearDown(() {
      SecretConfig.resetForTest();
      FlavorManager.current = Flavor.dev;
    });

    test(
      'dev: reads Remote Config token, persists to secure storage',
      () async {
        FlavorManager.current = Flavor.dev;
        final LayeredRenderOrchestrationHfTokenProvider provider =
            LayeredRenderOrchestrationHfTokenProvider(
              runtime: AppRuntimeConfig(
                flavor: Flavor.dev,
                skeletonDelay: Duration.zero,
              ),
              remoteTokenPort: _FakeRemoteTokenPort(token: '  rc-hf  '),
              storage: storage,
            );

        final String? first = await provider.readHfTokenForUpstream();
        expect(first, 'rc-hf');

        final String? cached = await storage.read(
          LayeredRenderOrchestrationHfTokenProvider.cacheKey,
        );
        expect(cached, 'rc-hf');
      },
    );

    test('dev: prefers secure storage over Remote Config', () async {
      FlavorManager.current = Flavor.dev;
      await storage.write(
        LayeredRenderOrchestrationHfTokenProvider.cacheKey,
        'cached-only',
      );

      final LayeredRenderOrchestrationHfTokenProvider provider =
          LayeredRenderOrchestrationHfTokenProvider(
            runtime: AppRuntimeConfig(
              flavor: Flavor.dev,
              skeletonDelay: Duration.zero,
            ),
            remoteTokenPort: _FakeRemoteTokenPort(token: 'from-rc'),
            storage: storage,
          );

      expect(await provider.readHfTokenForUpstream(), 'cached-only');
    });

    test(
      'non-dev: skips Remote Config, uses SecretConfig when loaded',
      () async {
        FlavorManager.current = Flavor.staging;
        SecretConfig.storage = storage;
        await storage.write('huggingface_api_key', 'secure-hf');
        await SecretConfig.load(
          allowAssetFallback: false,
          persistToSecureStorage: false,
        );

        final LayeredRenderOrchestrationHfTokenProvider provider =
            LayeredRenderOrchestrationHfTokenProvider(
              runtime: AppRuntimeConfig(
                flavor: Flavor.staging,
                skeletonDelay: Duration.zero,
              ),
              remoteTokenPort: _FakeRemoteTokenPort(token: 'from-rc'),
              storage: storage,
            );

        expect(await provider.readHfTokenForUpstream(), 'secure-hf');
      },
    );

    test('non-dev: Callable override wins before SecretConfig', () async {
      FlavorManager.current = Flavor.staging;
      SecretConfig.storage = storage;
      await storage.write('huggingface_api_key', 'secure-hf');
      await SecretConfig.load(
        allowAssetFallback: false,
        persistToSecureStorage: false,
      );

      final LayeredRenderOrchestrationHfTokenProvider provider =
          LayeredRenderOrchestrationHfTokenProvider(
            runtime: AppRuntimeConfig(
              flavor: Flavor.staging,
              skeletonDelay: Duration.zero,
            ),
            remoteTokenPort: _FakeRemoteTokenPort(),
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
      await storage.write(
        LayeredRenderOrchestrationHfTokenProvider.legacyRcCacheKey,
        'legacy-rc',
      );

      final LayeredRenderOrchestrationHfTokenProvider provider =
          LayeredRenderOrchestrationHfTokenProvider(
            runtime: AppRuntimeConfig(
              flavor: Flavor.dev,
              skeletonDelay: Duration.zero,
            ),
            remoteTokenPort: _FakeRemoteTokenPort(),
            storage: storage,
          );

      expect(await provider.readHfTokenForUpstream(), 'legacy-rc');
      expect(
        await storage.read(LayeredRenderOrchestrationHfTokenProvider.cacheKey),
        'legacy-rc',
      );
      expect(
        await storage.read(
          LayeredRenderOrchestrationHfTokenProvider.legacyRcCacheKey,
        ),
        isNull,
      );
    });

    test(
      'clearRenderOrchestrationTokenCache removes primary and legacy keys',
      () async {
        FlavorManager.current = Flavor.dev;
        await storage.write(
          LayeredRenderOrchestrationHfTokenProvider.cacheKey,
          'a',
        );
        await storage.write(
          LayeredRenderOrchestrationHfTokenProvider.legacyRcCacheKey,
          'b',
        );

        final LayeredRenderOrchestrationHfTokenProvider provider =
            LayeredRenderOrchestrationHfTokenProvider(
              runtime: AppRuntimeConfig(
                flavor: Flavor.dev,
                skeletonDelay: Duration.zero,
              ),
              remoteTokenPort: _FakeRemoteTokenPort(),
              storage: storage,
            );

        await provider.clearRenderOrchestrationTokenCache();
        expect(
          await storage.read(
            LayeredRenderOrchestrationHfTokenProvider.cacheKey,
          ),
          isNull,
        );
        expect(
          await storage.read(
            LayeredRenderOrchestrationHfTokenProvider.legacyRcCacheKey,
          ),
          isNull,
        );
      },
    );

    test('single-flight: concurrent reads share one resolution', () async {
      FlavorManager.current = Flavor.dev;
      int readCalls = 0;
      final LayeredRenderOrchestrationHfTokenProvider provider =
          LayeredRenderOrchestrationHfTokenProvider(
            runtime: AppRuntimeConfig(
              flavor: Flavor.dev,
              skeletonDelay: Duration.zero,
            ),
            remoteTokenPort: _CountingRemoteTokenPort(
              onRead: () => readCalls++,
              token: 'once',
            ),
            storage: storage,
          );

      final List<String?> results = await Future.wait(<Future<String?>>[
        provider.readHfTokenForUpstream(),
        provider.readHfTokenForUpstream(),
        provider.readHfTokenForUpstream(),
      ]);

      expect(results, everyElement('once'));
      expect(readCalls, 1);
    });
  });
}

class _FakeRemoteTokenPort implements RenderOrchestrationRemoteTokenPort {
  _FakeRemoteTokenPort({this.token});

  final String? token;

  @override
  Future<void> forceRefresh() async {}

  @override
  String? readDevToken() {
    final String? raw = token?.trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return raw;
  }
}

class _CountingRemoteTokenPort implements RenderOrchestrationRemoteTokenPort {
  _CountingRemoteTokenPort({required this.onRead, required this.token});

  final void Function() onRead;
  final String token;

  @override
  Future<void> forceRefresh() async {}

  @override
  String? readDevToken() {
    onRead();
    return token;
  }
}
