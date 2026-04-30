part of 'secret_config.dart';

class SecretConfig {
  SecretConfig._();

  /// When true, a base URL is non-empty and the app may attempt orchestration
  /// before composite chat.
  static bool get chatRenderDemoEnabled =>
      _ChatOrchestrationDefines.fastApiCloudEnabled ||
      _ChatOrchestrationDefines.renderEnabled;

  /// Never fall through to Supabase/direct after a retryable orchestration failure.
  static bool get chatRenderDemoStrict =>
      _ChatOrchestrationDefines.fastApiCloudStrict ||
      _ChatOrchestrationDefines.renderStrict;

  /// HTTPS origin of the orchestration FastAPI service (no trailing slash), e.g.
  /// `https://render-chat-api.fastapicloud.dev`.
  static String get chatRenderDemoBaseUrl {
    final String preferred = _ChatOrchestrationDefines.fastApiCloudBaseUrl
        .trim();
    if (preferred.isNotEmpty) return preferred;
    return _ChatOrchestrationDefines.renderBaseUrl;
  }

  /// Optional shared secret header for the demo service when configured.
  static String get chatRenderDemoSecret {
    final String preferred = _ChatOrchestrationDefines.fastApiCloudSecret
        .trim();
    if (preferred.isNotEmpty) return preferred;
    return _ChatOrchestrationDefines.renderSecret;
  }

  /// Render FastAPI demo is configured via compile-time defines (enabled flag,
  /// non-empty base URL, `https` in release). Used for UI transport hints so the
  /// chat chip matches the Render path when the demo is wired; actual sends
  /// still require Firebase + tokens (see `register_chat_services`).
  static bool get isChatRenderDemoSurface {
    if (!chatRenderDemoEnabled) {
      return false;
    }
    final String base = chatRenderDemoBaseUrl.trim();
    if (base.isEmpty) {
      return false;
    }
    if (kReleaseMode) {
      final Uri? parsed = Uri.tryParse(base);
      if (parsed == null || parsed.scheme != 'https') {
        return false;
      }
    }
    return true;
  }

  /// Optional Cloud Function name (non-dev) that returns a short-lived HF read
  /// token for orchestration. Empty disables the Callable path (falls back to
  /// `huggingface_api_key` from secrets when present).
  static String get chatRenderHfReadTokenCallable {
    final String preferred = _ChatOrchestrationDefines
        .fastApiCloudHfReadTokenCallable
        .trim();
    if (preferred.isNotEmpty) return preferred;
    return _ChatOrchestrationDefines.renderHfReadTokenCallable;
  }

  /// Firebase Functions region for `chatRenderHfReadTokenCallable`.
  static String get chatRenderHfReadTokenCallableRegion {
    final String preferred = _ChatOrchestrationDefines
        .fastApiCloudHfReadTokenCallableRegion
        .trim();
    if (preferred.isNotEmpty) return preferred;
    return _ChatOrchestrationDefines.renderHfReadTokenCallableRegion;
  }

  static const String enableAssetSecretsDefine = 'ENABLE_ASSET_SECRETS';
  static const String _keyHfToken = 'huggingface_api_key';
  static const String _keyHfModel = 'huggingface_model';
  static const String _keyHfUseChatCompletions =
      'huggingface_use_chat_completions';
  static const String _keyGoogleMaps = 'google_maps_api_key';
  static const String _keyGeminiApiKey = 'gemini_api_key';
  static const String _keySupabaseUrl = 'supabase_url';
  static const String _keySupabaseAnonKey = 'supabase_anon_key';
  static const String _keySupabaseConfigVersion = 'supabase_config_version';
  static const String _keySupabaseFirebaseProjectId =
      'supabase_firebase_project_id';

  static bool _loaded = false;
  static String? _huggingfaceApiKey;
  static String? _huggingfaceModel;
  static bool? _useChatCompletions;
  static String? _googleMapsApiKey;
  static String? _geminiApiKey;
  static String? _supabaseUrl;
  static String? _supabaseAnonKey;
  static String? _supabaseConfigVersion;
  static String? _supabaseFirebaseProjectId;
  static SecretStorage? _configuredStorage;
  @visibleForTesting
  static AssetBundle? debugAssetBundle;
  @visibleForTesting
  static Map<String, dynamic>? debugEnvironment;

  static String? get huggingfaceApiKey => _huggingfaceApiKey;
  static String? get huggingfaceModel => _huggingfaceModel;
  static bool get useChatCompletions => _useChatCompletions ?? true;
  static String? get googleMapsApiKey => _googleMapsApiKey;
  static String? get geminiApiKey => _geminiApiKey;
  static String? get supabaseUrl => _supabaseUrl;
  static String? get supabaseAnonKey => _supabaseAnonKey;
  static String? get supabaseConfigVersion => _supabaseConfigVersion;
  static String? get supabaseFirebaseProjectId => _supabaseFirebaseProjectId;

  static SecretStorage? get storage => _configuredStorage;
  static set storage(final SecretStorage storage) {
    _configuredStorage = storage;
  }

  @visibleForTesting
  static void resetForTest() {
    _configuredStorage = null;
    debugAssetBundle = null;
    debugEnvironment = null;
    _loaded = false;
    _huggingfaceApiKey = null;
    _huggingfaceModel = null;
    _useChatCompletions = null;
    _googleMapsApiKey = null;
    _geminiApiKey = null;
    _supabaseUrl = null;
    _supabaseAnonKey = null;
    _supabaseConfigVersion = null;
    _supabaseFirebaseProjectId = null;
  }

  /// Applies Supabase config at runtime (for example, after a callable returns).
  ///
  /// This intentionally overwrites existing in-memory values when non-empty
  /// values are provided, to support rotation via `version`.
  static void applySupabaseConfig({
    required final String supabaseUrl,
    required final String supabaseAnonKey,
    required final String version,
    final String? firebaseProjectId,
  }) {
    final String url = supabaseUrl.trim();
    final String key = supabaseAnonKey.trim();
    final String ver = version.trim();
    if (url.isEmpty || key.isEmpty || ver.isEmpty) {
      AppLogger.warning(
        'SecretConfig.applySupabaseConfig ignored: blank values provided.',
      );
      return;
    }

    _supabaseUrl = url;
    _supabaseAnonKey = key;
    _supabaseConfigVersion = ver;
    final String? projectId = firebaseProjectId?.trim();
    _supabaseFirebaseProjectId = (projectId == null || projectId.isEmpty)
        ? null
        : projectId;
  }

  static Future<void> persistSupabaseConfig(
    final SecretStorage storage, {
    required final String supabaseUrl,
    required final String supabaseAnonKey,
    required final String version,
    final String? firebaseProjectId,
  }) async {
    final String url = supabaseUrl.trim();
    final String key = supabaseAnonKey.trim();
    final String ver = version.trim();
    if (url.isEmpty || key.isEmpty || ver.isEmpty) {
      throw StateError('Supabase config persistence received blank values.');
    }

    await storage.withoutLogsAsync(() async {
      await storage.write(_keySupabaseUrl, url);
      await storage.write(_keySupabaseAnonKey, key);
      await storage.write(_keySupabaseConfigVersion, ver);
      final String? projectId = firebaseProjectId?.trim();
      if (projectId != null && projectId.isNotEmpty) {
        await storage.write(_keySupabaseFirebaseProjectId, projectId);
      } else {
        await storage.delete(_keySupabaseFirebaseProjectId);
      }
    });
  }

  static Future<void> clearSupabaseConfig(final SecretStorage storage) async {
    await storage.withoutLogsAsync(() async {
      await storage.delete(_keySupabaseUrl);
      await storage.delete(_keySupabaseAnonKey);
      await storage.delete(_keySupabaseConfigVersion);
      await storage.delete(_keySupabaseFirebaseProjectId);
    });
  }

  static const bool _envAllowsAssetFallback = bool.fromEnvironment(
    enableAssetSecretsDefine,
  );

  static Future<void> load({
    final bool? persistToSecureStorage,
    final bool allowAssetFallback = false,
  }) async {
    if (_loaded) return;

    final SecretStorage storage =
        _configuredStorage ?? createDefaultSecretStorage();
    // In debug, allow local asset secrets by default so `flutter run` works
    // without repeated dart-define flags. Release remains disabled.
    final bool assetFallbackAllowed =
        (_envAllowsAssetFallback || allowAssetFallback || kDebugMode) &&
        !kReleaseMode;

    try {
      var hadPreEnvSecretsApply = false;
      final bool loadedFromSecure = await _loadFromSource(
        () => _readSecureSecrets(storage),
      );
      if (loadedFromSecure) {
        hadPreEnvSecretsApply = true;
        _logHuggingFaceTokenDiagnostics(source: 'secure_storage');
        if (_needsRemoteFallback) {
          AppLogger.warning(
            'SecretConfig: secure storage is partial; continuing fallback to '
            'asset/env sources for missing credentials.',
          );
        } else {
          _loaded = true;
          return;
        }
      }

      if (assetFallbackAllowed) {
        final bool loadedFromAssets = await _loadFromSource(
          _readAssetSecrets,
          afterApply: () => _persistGoogleMapsKey(storage),
        );
        if (loadedFromAssets) {
          hadPreEnvSecretsApply = true;
          _logHuggingFaceTokenDiagnostics(source: 'asset_secrets');
          if (!_needsRemoteFallback) {
            _loaded = true;
            return;
          }
        }
      }

      final bool shouldPersistEnv = persistToSecureStorage ?? true;
      final bool loadedFromEnvironment = await _loadFromSource(
        _readEnvironmentSecrets,
        afterApply: shouldPersistEnv
            ? () => _persistToSecureStorage(storage)
            : null,
      );
      if (loadedFromEnvironment) {
        _logHuggingFaceTokenDiagnostics(source: 'dart_define_env');
        _loaded = true;
        return;
      }

      if (hadPreEnvSecretsApply) {
        _loaded = true;
        return;
      }

      AppLogger.warning(
        'SecretConfig: No credentials found in secure storage or '
        'environment. Features requiring remote access (Hugging Face, Gemini, '
        'Supabase) remain disabled.',
      );
      _logHuggingFaceTokenDiagnostics(source: 'none');
    } on Exception catch (error, stackTrace) {
      AppLogger.warning('SecretConfig.load failed');
      AppLogger.error('SecretConfig.load', error, stackTrace);
      _loaded = false;
    }
  }

  static void _logHuggingFaceTokenDiagnostics({required final String source}) {
    if (kReleaseMode) {
      // Never log any token material in release builds (even masked).
      return;
    }
    final String? token = _huggingfaceApiKey;
    final String? model = _huggingfaceModel;
    if (token == null || token.isEmpty) {
      AppLogger.warning(
        'SecretConfig: Hugging Face token not loaded (source=$source).',
      );
      return;
    }

    final String suffix = token.length > 4
        ? token.substring(token.length - 4)
        : token;
    final String selectedModel = model ?? 'HuggingFaceH4/zephyr-7b-beta';
    AppLogger.info(
      'SecretConfig: Hugging Face token loaded '
      '(source=$source, len=${token.length}, suffix=***$suffix, model=$selectedModel)',
    );
  }

  static bool get _hasHuggingFaceToken {
    final String? token = _huggingfaceApiKey;
    return token != null && token.isNotEmpty;
  }

  static bool get _needsRemoteFallback {
    final bool hfMissing = !_hasHuggingFaceToken;
    final bool supabaseMissing =
        (_supabaseUrl == null || _supabaseUrl!.trim().isEmpty) ||
        (_supabaseAnonKey == null || _supabaseAnonKey!.trim().isEmpty);
    // Maps/Gemini are optional; focus on features that hard-fail or log noisy skips.
    return hfMissing || supabaseMissing;
  }
}
