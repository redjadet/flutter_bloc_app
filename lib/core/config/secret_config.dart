import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

class SecretConfig {
  SecretConfig._();

  static const String _assetPath = 'assets/config/secrets.json';
  static const String _keyHfToken = 'huggingface_api_key';
  static const String _keyHfModel = 'huggingface_model';
  static const String _keyHfUseChatCompletions =
      'huggingface_use_chat_completions';

  static bool _loaded = false;
  static String? _huggingfaceApiKey;
  static String? _huggingfaceModel;
  static bool _useChatCompletions = false;
  static SecretStorage? _configuredStorage;

  static String? get huggingfaceApiKey => _huggingfaceApiKey;
  static String? get huggingfaceModel => _huggingfaceModel;
  static bool get useChatCompletions => _useChatCompletions;

  static void configureStorage(SecretStorage storage) {
    _configuredStorage = storage;
  }

  static Future<void> load({bool? persistToSecureStorage}) async {
    if (_loaded) return;
    _loaded = true;
    final bool shouldPersist = persistToSecureStorage ?? kReleaseMode;
    final SecretStorage storage =
        _configuredStorage ?? FlutterSecureSecretStorage();
    try {
      final Map<String, dynamic>? stored = await _readSecureSecrets(storage);
      if (stored != null && stored.isNotEmpty) {
        _applySecrets(stored);
        return;
      }

      final String raw = await rootBundle.loadString(_assetPath);
      final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
      _applySecrets(json);

      if (shouldPersist) {
        await _persistToSecureStorage(storage);
      }
    } catch (e, s) {
      AppLogger.warning('SecretConfig.load failed: $e');
      AppLogger.error('SecretConfig.load stack', e, s);
    }
  }

  static Future<Map<String, dynamic>?> _readSecureSecrets(
    SecretStorage storage,
  ) async {
    try {
      final String? token = await storage.read(_keyHfToken);
      final String? model = await storage.read(_keyHfModel);
      final String? flag = await storage.read(_keyHfUseChatCompletions);
      if ((token == null || token.isEmpty) &&
          (model == null || model.isEmpty) &&
          (flag == null || flag.isEmpty)) {
        return null;
      }
      return <String, dynamic>{
        'HUGGINGFACE_API_KEY': token,
        'HUGGINGFACE_MODEL': model,
        'HUGGINGFACE_USE_CHAT_COMPLETIONS': flag == 'true',
      };
    } catch (e) {
      AppLogger.warning('SecretConfig secure read failed: $e');
      return null;
    }
  }

  static Future<void> _persistToSecureStorage(SecretStorage storage) async {
    if (_huggingfaceApiKey != null) {
      await storage.write(_keyHfToken, _huggingfaceApiKey!);
    }
    if (_huggingfaceModel != null) {
      await storage.write(_keyHfModel, _huggingfaceModel!);
    }
    await storage.write(
      _keyHfUseChatCompletions,
      _useChatCompletions.toString(),
    );
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
  }
}
