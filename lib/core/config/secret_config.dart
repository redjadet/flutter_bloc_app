import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

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

  static void configureStorage(SecretStorage storage) {
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
    bool? persistToSecureStorage,
    bool allowAssetFallback = false,
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

  static Future<Map<String, dynamic>?> _readSecureSecrets(
    SecretStorage storage,
  ) async {
    try {
      final String? token = await storage.read(_keyHfToken);
      final String? model = await storage.read(_keyHfModel);
      final String? flag = await storage.read(_keyHfUseChatCompletions);
      final String? mapsKey = await storage.read(_keyGoogleMaps);
      if ((token == null || token.isEmpty) &&
          (model == null || model.isEmpty) &&
          (flag == null || flag.isEmpty) &&
          (mapsKey == null || mapsKey.isEmpty)) {
        return null;
      }
      return <String, dynamic>{
        'HUGGINGFACE_API_KEY': token,
        'HUGGINGFACE_MODEL': model,
        'HUGGINGFACE_USE_CHAT_COMPLETIONS': flag == 'true',
        'GOOGLE_MAPS_API_KEY': mapsKey,
      };
    } on Exception catch (e) {
      AppLogger.warning('SecretConfig secure read failed: $e');
      return null;
    }
  }

  static Future<void> _persistToSecureStorage(SecretStorage storage) async {
    final String? token = _huggingfaceApiKey;
    final String? model = _huggingfaceModel;
    if (token != null) {
      await storage.write(_keyHfToken, token);
    }
    if (model != null) {
      await storage.write(_keyHfModel, model);
    }
    await storage.write(
      _keyHfUseChatCompletions,
      _useChatCompletions.toString(),
    );
    final String? mapsKey = _googleMapsApiKey;
    if (mapsKey != null) {
      await storage.write(_keyGoogleMaps, mapsKey);
    }
  }

  static void _applySecrets(Map<String, dynamic> json) {
    final String? token = (json['HUGGINGFACE_API_KEY'] as String?)?.trim();
    _huggingfaceApiKey = (token?.isEmpty ?? true) ? null : token;
    final String? model = (json['HUGGINGFACE_MODEL'] as String?)?.trim();
    _huggingfaceModel = (model?.isEmpty ?? true) ? null : model;
    final Object? flag = json['HUGGINGFACE_USE_CHAT_COMPLETIONS'];
    if (flag is bool) {
      _useChatCompletions = flag;
    } else if (flag is String) {
      _useChatCompletions = flag.toLowerCase() == 'true';
    } else {
      _useChatCompletions = false;
    }
    final String? mapsKey = (json['GOOGLE_MAPS_API_KEY'] as String?)?.trim();
    _googleMapsApiKey = (mapsKey?.isEmpty ?? true) ? null : mapsKey;
  }

  static bool _hasSecrets(Map<String, dynamic>? source) {
    if (source == null) return false;
    final String? token = (source['HUGGINGFACE_API_KEY'] as String?)?.trim();
    final String? model = (source['HUGGINGFACE_MODEL'] as String?)?.trim();
    final Object? flag = source['HUGGINGFACE_USE_CHAT_COMPLETIONS'];
    final String? maps = (source['GOOGLE_MAPS_API_KEY'] as String?)?.trim();

    final bool hasToken = token != null && token.isNotEmpty;
    final bool hasModel = model != null && model.isNotEmpty;
    final bool hasFlag =
        flag is bool || (flag is String && flag.trim().isNotEmpty);
    final bool hasMaps = maps != null && maps.isNotEmpty;

    return hasToken || hasModel || hasFlag || hasMaps;
  }

  static Map<String, dynamic>? _readEnvironmentSecrets() {
    const String token = String.fromEnvironment('HUGGINGFACE_API_KEY');
    const String model = String.fromEnvironment('HUGGINGFACE_MODEL');
    const String completionFlagRaw = String.fromEnvironment(
      'HUGGINGFACE_USE_CHAT_COMPLETIONS',
    );
    const String mapsKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

    final Map<String, dynamic> result = <String, dynamic>{};
    if (token.isNotEmpty) {
      result['HUGGINGFACE_API_KEY'] = token;
    }
    if (model.isNotEmpty) {
      result['HUGGINGFACE_MODEL'] = model;
    }
    if (completionFlagRaw.isNotEmpty) {
      result['HUGGINGFACE_USE_CHAT_COMPLETIONS'] = completionFlagRaw;
    }
    if (mapsKey.isNotEmpty) {
      result['GOOGLE_MAPS_API_KEY'] = mapsKey;
    }

    if (debugEnvironment != null) {
      result.addAll(debugEnvironment!);
    }

    return result.isEmpty ? null : result;
  }

  static Future<Map<String, dynamic>?> _readAssetSecrets() async {
    const String assetPath = 'assets/config/secrets.json';
    final AssetBundle bundle = debugAssetBundle ?? rootBundle;
    final String? raw = await bundle
        .loadString(assetPath)
        .then<String?>((value) => value)
        .catchError(
          (Object _) => null,
          test: (Object error) => error is FlutterError,
        );
    if (raw == null) {
      // Asset not bundled; ignore silently for developers without a local file.
      return null;
    }

    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      AppLogger.warning(
        'SecretConfig: Asset $assetPath does not contain a JSON object.',
      );
    } on FormatException catch (e) {
      AppLogger.warning('SecretConfig asset parse failed: $e');
    } on Exception catch (e) {
      AppLogger.warning('SecretConfig asset read failed: $e');
    }
    return null;
  }

  static Future<void> _persistGoogleMapsKey(SecretStorage storage) async {
    final String? mapsKey = _googleMapsApiKey;
    if (mapsKey != null) {
      await storage.write(_keyGoogleMaps, mapsKey);
    }
  }

  static Future<bool> _loadFromSource(
    FutureOr<Map<String, dynamic>?> Function() read, {
    Future<void> Function()? afterApply,
  }) async {
    final Map<String, dynamic>? secrets =
        await Future<Map<String, dynamic>?>.value(read());
    if (!_hasSecrets(secrets)) {
      return false;
    }

    _applySecrets(secrets!);
    if (afterApply != null) {
      await afterApply();
    }
    return true;
  }
}
