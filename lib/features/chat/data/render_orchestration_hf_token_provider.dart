import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc_app/core/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/config/app_runtime_config.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/features/remote_config/data/repositories/remote_config_repository.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_service.dart';
import 'package:flutter_bloc_app/shared/firebase/auth_helpers.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';

/// Hugging Face read token for Render `X-HF-Authorization` (per send).
///
/// The layered implementation caches upstream material in secure storage, then:
/// **dev** — Remote Config `RENDER_CHAT_DEMO_HF_READ_TOKEN` (optional force-fetch);
/// **non-dev** — optional Callable (`CHAT_RENDER_HF_READ_TOKEN_CALLABLE`) returning
/// JSON with `hf_read_token` or `token`; then compile-time / asset HF key.
abstract class RenderOrchestrationHfTokenProvider {
  Future<String?> readHfTokenForUpstream();

  /// Clears demo-scoped material cached for Render (e.g. after Firebase sign-out).
  Future<void> clearRenderOrchestrationTokenCache();
}

/// Reads only compile-time / asset Hugging Face key (tests / minimal wiring).
class SecretConfigRenderOrchestrationHfTokenProvider implements RenderOrchestrationHfTokenProvider {
  const SecretConfigRenderOrchestrationHfTokenProvider();

  @override
  Future<void> clearRenderOrchestrationTokenCache() async {}

  @override
  Future<String?> readHfTokenForUpstream() async {
    final String? t = SecretConfig.huggingfaceApiKey?.trim();
    if (t == null || t.isEmpty) {
      return null;
    }
    return t;
  }
}

/// Single-flight resolver: Remote Config (dev), Callable (non-dev when configured),
/// then `SecretConfig.huggingfaceApiKey`.
class LayeredRenderOrchestrationHfTokenProvider implements RenderOrchestrationHfTokenProvider {
  LayeredRenderOrchestrationHfTokenProvider({
    required final AppRuntimeConfig runtime,
    required final RemoteConfigService remoteConfig,
    required final SecretStorage storage,
    final FirebaseAuth? firebaseAuth,
    final Future<String?> Function()? callableTokenOverride,
  }) : _runtime = runtime,
       _remoteConfig = remoteConfig,
       _storage = storage,
       _firebaseAuth = firebaseAuth,
       _callableTokenOverride = callableTokenOverride;

  /// Current cache key for any orchestration HF material (RC or Callable).
  static const String cacheKey = 'render_chat_orchestration_hf_token_v1';

  /// Previous dev-only key; still cleared and read for one-version migration.
  static const String legacyRcCacheKey = 'render_chat_demo_rc_hf_read_token_v1';

  final AppRuntimeConfig _runtime;
  final RemoteConfigService _remoteConfig;
  final SecretStorage _storage;
  final FirebaseAuth? _firebaseAuth;
  final Future<String?> Function()? _callableTokenOverride;

  Future<String?>? _inFlight;
  bool _devRemoteFetchAttempted = false;

  @override
  Future<void> clearRenderOrchestrationTokenCache() async {
    await _storage.delete(cacheKey);
    await _storage.delete(legacyRcCacheKey);
  }

  @override
  Future<String?> readHfTokenForUpstream() async {
    final Future<String?>? existing = _inFlight;
    if (existing != null) {
      return existing;
    }
    final Future<String?> future = _resolve();
    _inFlight = future;
    try {
      return await future;
    } finally {
      if (identical(_inFlight, future)) {
        _inFlight = null;
      }
    }
  }

  Future<String?> _resolve() async {
    final String? fromSecret = SecretConfig.huggingfaceApiKey?.trim();

    final String? cached = await _readAnyCache();
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    if (_runtime.isDev) {
      String? fromRc = _readRemoteConfigToken();
      if ((fromRc == null || fromRc.isEmpty) &&
          !_devRemoteFetchAttempted &&
          FirebaseBootstrapService.isFirebaseInitialized) {
        _devRemoteFetchAttempted = true;
        try {
          await _remoteConfig.forceFetch();
        } on Exception catch (e, _) {
          AppLogger.info(
            'LayeredRenderOrchestrationHfTokenProvider: Remote Config forceFetch failed ($e)',
          );
        }
        fromRc = _readRemoteConfigToken();
      }
      if (fromRc != null && fromRc.isNotEmpty) {
        await _writeCache(fromRc);
        return fromRc;
      }
    } else {
      final String? fromCallable = await _tryCallableToken();
      if (fromCallable != null && fromCallable.isNotEmpty) {
        await _writeCache(fromCallable);
        return fromCallable;
      }
    }

    if (fromSecret != null && fromSecret.isNotEmpty) {
      return fromSecret;
    }
    return null;
  }

  Future<String?> _readAnyCache() async {
    final String? primary = (await _storage.read(cacheKey))?.trim();
    if (primary != null && primary.isNotEmpty) {
      return primary;
    }
    final String? legacy = (await _storage.read(legacyRcCacheKey))?.trim();
    if (legacy != null && legacy.isNotEmpty) {
      await _writeCache(legacy);
      await _storage.delete(legacyRcCacheKey);
      return legacy;
    }
    return null;
  }

  Future<void> _writeCache(final String token) async {
    await _storage.write(cacheKey, token);
  }

  Future<String?> _tryCallableToken() async {
    final Future<String?> Function()? override = _callableTokenOverride;
    if (override != null) {
      final String? t = (await override())?.trim();
      return (t == null || t.isEmpty) ? null : t;
    }
    final String callableName = SecretConfig.chatRenderHfReadTokenCallable.trim();
    if (callableName.isEmpty) {
      return null;
    }
    if (!FirebaseBootstrapService.isFirebaseInitialized) {
      return null;
    }
    final FirebaseAuth? auth = _firebaseAuth ?? _tryFirebaseAuth();
    if (auth == null) {
      return null;
    }
    try {
      final User user = await waitForAuthUser(auth);
      await user.getIdToken(true);
    } on FirebaseAuthException catch (e, _) {
      AppLogger.info(
        'LayeredRenderOrchestrationHfTokenProvider: Callable skipped (auth ${e.code})',
      );
      return null;
    }
    try {
      final String region = SecretConfig.chatRenderHfReadTokenCallableRegion.trim().isEmpty
          ? 'us-central1'
          : SecretConfig.chatRenderHfReadTokenCallableRegion.trim();
      final FirebaseFunctions functions = FirebaseFunctions.instanceFor(
        app: Firebase.app(),
        region: region,
      );
      final HttpsCallable callable = functions.httpsCallable(callableName);
      final HttpsCallableResult<dynamic> result = await callable.call(
        <String, dynamic>{},
      );
      final Map<String, dynamic>? map = mapFromDynamic(result.data);
      final String? token =
          stringFromDynamicTrimmed(map?['hf_read_token']) ??
          stringFromDynamicTrimmed(map?['token']);
      return token;
    } on FirebaseFunctionsException catch (e, _) {
      AppLogger.info(
        'LayeredRenderOrchestrationHfTokenProvider: Callable failed (${e.code})',
      );
      return null;
    } on Exception catch (e, _) {
      AppLogger.info(
        'LayeredRenderOrchestrationHfTokenProvider: Callable error ($e)',
      );
      return null;
    }
  }

  FirebaseAuth? _tryFirebaseAuth() {
    try {
      return FirebaseAuth.instance;
    } on Object {
      return null;
    }
  }

  String? _readRemoteConfigToken() {
    try {
      final String raw = _remoteConfig.getString(
        RemoteConfigRepository.renderChatDemoHfReadTokenKey,
      );
      final String trimmed = raw.trim();
      if (trimmed.isEmpty) {
        return null;
      }
      return trimmed;
    } on Exception catch (e, _) {
      AppLogger.debug(
        'LayeredRenderOrchestrationHfTokenProvider._readRemoteConfigToken: $e',
      );
      return null;
    }
  }
}
