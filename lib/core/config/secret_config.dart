import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

part 'secret_config_sources.dart';

class SecretConfig {
  SecretConfig._();

  static const String enableAssetSecretsDefine = 'ENABLE_ASSET_SECRETS';
  static const String _keyHfToken = 'huggingface_api_key';
  static const String _keyHfModel = 'huggingface_model';
  static const String _keyHfUseChatCompletions =
      'huggingface_use_chat_completions';
  static const String _keyGoogleMaps = 'google_maps_api_key';

  static bool _loaded = false;
  static String? _huggingfaceApiKey;
  static String? _huggingfaceModel;
  static bool _useChatCompletions = false;
  static String? _googleMapsApiKey;
  static SecretStorage? _configuredStorage;
  @visibleForTesting
  static AssetBundle? debugAssetBundle;
  @visibleForTesting
  static Map<String, dynamic>? debugEnvironment;

  static String? get huggingfaceApiKey => _huggingfaceApiKey;
  static String? get huggingfaceModel => _huggingfaceModel;
  static bool get useChatCompletions => _useChatCompletions;
  static String? get googleMapsApiKey => _googleMapsApiKey;

  static void configureStorage(final SecretStorage storage) {
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
    _useChatCompletions = false;
    _googleMapsApiKey = null;
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
    final bool assetFallbackAllowed =
        (_envAllowsAssetFallback || allowAssetFallback) && !kReleaseMode;

    try {
      final bool loadedFromSecure = await _loadFromSource(
        () => _readSecureSecrets(storage),
      );
      if (loadedFromSecure) {
        _loaded = true;
        return;
      }

      if (assetFallbackAllowed) {
        final bool loadedFromAssets = await _loadFromSource(
          () => _readAssetSecrets(),
          afterApply: () => _persistGoogleMapsKey(storage),
        );
        if (loadedFromAssets) {
          _loaded = true;
          return;
        }
      }

      final bool shouldPersistEnv = persistToSecureStorage ?? true;
      final bool loadedFromEnvironment = await _loadFromSource(
        () => _readEnvironmentSecrets(),
        afterApply: shouldPersistEnv
            ? () => _persistToSecureStorage(storage)
            : null,
      );
      if (loadedFromEnvironment) {
        _loaded = true;
        return;
      }

      AppLogger.warning(
        'SecretConfig: No Hugging Face credentials found in secure storage or '
        'environment. Chat features requiring remote access remain disabled.',
      );
    } on Exception catch (e, s) {
      AppLogger.warning('SecretConfig.load failed: $e');
      AppLogger.error('SecretConfig.load stack', e, s);
      _loaded = false;
    }
  }
}
