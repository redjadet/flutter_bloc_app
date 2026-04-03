import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';

part 'secret_config_sources.dart';

class SecretConfig {
  SecretConfig._();

  static const String enableAssetSecretsDefine = 'ENABLE_ASSET_SECRETS';
  static const String _keyHfToken = 'huggingface_api_key';
  static const String _keyHfModel = 'huggingface_model';
  static const String _keyHfUseChatCompletions =
      'huggingface_use_chat_completions';
  static const String _keyGoogleMaps = 'google_maps_api_key';
  static const String _keyGeminiApiKey = 'gemini_api_key';
  static const String _keySupabaseUrl = 'supabase_url';
  static const String _keySupabaseAnonKey = 'supabase_anon_key';

  static bool _loaded = false;
  static String? _huggingfaceApiKey;
  static String? _huggingfaceModel;
  static bool? _useChatCompletions;
  static String? _googleMapsApiKey;
  static String? _geminiApiKey;
  static String? _supabaseUrl;
  static String? _supabaseAnonKey;
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
        _configuredStorage ?? FlutterSecureSecretStorage();
    // In debug, allow local asset secrets by default so `flutter run` works
    // without repeated dart-define flags. Release remains disabled.
    final bool assetFallbackAllowed =
        (_envAllowsAssetFallback || allowAssetFallback || kDebugMode) &&
        !kReleaseMode;

    try {
      final bool loadedFromSecure = await _loadFromSource(
        () => _readSecureSecrets(storage),
      );
      if (loadedFromSecure) {
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
