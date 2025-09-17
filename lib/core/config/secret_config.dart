import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

class SecretConfig {
  SecretConfig._();

  static const String _assetPath = 'assets/config/secrets.json';
  static bool _loaded = false;
  static String? _huggingfaceApiKey;
  static String? _huggingfaceModel;
  static bool _useChatCompletions = false;

  static String? get huggingfaceApiKey => _huggingfaceApiKey;
  static String? get huggingfaceModel => _huggingfaceModel;
  static bool get useChatCompletions => _useChatCompletions;

  static Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final String raw = await rootBundle.loadString(_assetPath);
      final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
      final String? token = (json['HUGGINGFACE_API_KEY'] as String?)?.trim();
      _huggingfaceApiKey = (token?.isEmpty ?? true) ? null : token;
      final String? model = (json['HUGGINGFACE_MODEL'] as String?)?.trim();
      _huggingfaceModel = (model?.isEmpty ?? true) ? null : model;
      final Object? flag = json['HUGGINGFACE_USE_CHAT_COMPLETIONS'];
      _useChatCompletions = flag is bool ? flag : false;
    } catch (e, s) {
      AppLogger.warning('SecretConfig.load failed: $e');
      AppLogger.error('SecretConfig.load stack', e, s);
    }
  }
}
