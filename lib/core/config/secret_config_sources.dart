part of 'secret_config.dart';

Future<Map<String, dynamic>?> _readSecureSecrets(
  final SecretStorage storage,
) async {
  try {
    final String? token = await storage.read(SecretConfig._keyHfToken);
    final String? model = await storage.read(SecretConfig._keyHfModel);
    final String? flag = await storage.read(
      SecretConfig._keyHfUseChatCompletions,
    );
    final String? mapsKey = await storage.read(SecretConfig._keyGoogleMaps);
    final String? geminiKey = await storage.read(SecretConfig._keyGeminiApiKey);
    if ((token == null || token.isEmpty) &&
        (model == null || model.isEmpty) &&
        (flag == null || flag.isEmpty) &&
        (mapsKey == null || mapsKey.isEmpty) &&
        (geminiKey == null || geminiKey.isEmpty)) {
      return null;
    }
    return <String, dynamic>{
      'HUGGINGFACE_API_KEY': token,
      'HUGGINGFACE_MODEL': model,
      'HUGGINGFACE_USE_CHAT_COMPLETIONS': flag == 'true',
      'GOOGLE_MAPS_API_KEY': mapsKey,
      'GEMINI_API_KEY': geminiKey,
    };
  } on Exception catch (e) {
    AppLogger.warning('SecretConfig secure read failed: $e');
    return null;
  }
}

Future<void> _persistToSecureStorage(final SecretStorage storage) async {
  final String? token = SecretConfig._huggingfaceApiKey;
  final String? model = SecretConfig._huggingfaceModel;
  if (token case final value?) {
    await storage.write(SecretConfig._keyHfToken, value);
  }
  if (model case final value?) {
    await storage.write(SecretConfig._keyHfModel, value);
  }
  await storage.write(
    SecretConfig._keyHfUseChatCompletions,
    SecretConfig._useChatCompletions.toString(),
  );
  final String? mapsKey = SecretConfig._googleMapsApiKey;
  if (mapsKey case final value?) {
    await storage.write(SecretConfig._keyGoogleMaps, value);
  }
  final String? geminiKey = SecretConfig._geminiApiKey;
  if (geminiKey case final value?) {
    await storage.write(SecretConfig._keyGeminiApiKey, value);
  }
}

void _applySecrets(final Map<String, dynamic> json) {
  final String? token = (json['HUGGINGFACE_API_KEY'] as String?)?.trim();
  SecretConfig._huggingfaceApiKey = (token?.isEmpty ?? true) ? null : token;
  final String? model = (json['HUGGINGFACE_MODEL'] as String?)?.trim();
  SecretConfig._huggingfaceModel = (model?.isEmpty ?? true) ? null : model;

  final Object? flag = json['HUGGINGFACE_USE_CHAT_COMPLETIONS'];
  if (flag is bool) {
    SecretConfig._useChatCompletions = flag;
  } else if (flag is String) {
    SecretConfig._useChatCompletions = flag.toLowerCase() == 'true';
  } else {
    SecretConfig._useChatCompletions = false;
  }

  final String? mapsKey = (json['GOOGLE_MAPS_API_KEY'] as String?)?.trim();
  SecretConfig._googleMapsApiKey = (mapsKey?.isEmpty ?? true) ? null : mapsKey;

  final String? geminiKey = (json['GEMINI_API_KEY'] as String?)?.trim();
  final String? googleKey = (json['GOOGLE_API_KEY'] as String?)?.trim();
  final String? resolvedKey = (geminiKey?.isNotEmpty ?? false)
      ? geminiKey
      : googleKey;
  SecretConfig._geminiApiKey = (resolvedKey?.isEmpty ?? true)
      ? null
      : resolvedKey;
}

bool _hasSecrets(final Map<String, dynamic>? source) {
  if (source == null) return false;
  final String? token = (source['HUGGINGFACE_API_KEY'] as String?)?.trim();
  final String? model = (source['HUGGINGFACE_MODEL'] as String?)?.trim();
  final Object? flag = source['HUGGINGFACE_USE_CHAT_COMPLETIONS'];
  final String? maps = (source['GOOGLE_MAPS_API_KEY'] as String?)?.trim();
  final String? gemini = (source['GEMINI_API_KEY'] as String?)?.trim();
  final String? googleKey = (source['GOOGLE_API_KEY'] as String?)?.trim();

  final bool hasToken = token != null && token.isNotEmpty;
  final bool hasModel = model != null && model.isNotEmpty;
  final bool hasFlag =
      flag is bool || (flag is String && flag.trim().isNotEmpty);
  final bool hasMaps = maps != null && maps.isNotEmpty;
  final bool hasGemini = gemini != null && gemini.isNotEmpty;
  final bool hasGoogleKey = googleKey != null && googleKey.isNotEmpty;

  return hasToken ||
      hasModel ||
      hasFlag ||
      hasMaps ||
      hasGemini ||
      hasGoogleKey;
}

Map<String, dynamic>? _readEnvironmentSecrets() {
  const String token = String.fromEnvironment('HUGGINGFACE_API_KEY');
  const String model = String.fromEnvironment('HUGGINGFACE_MODEL');
  const String completionFlagRaw = String.fromEnvironment(
    'HUGGINGFACE_USE_CHAT_COMPLETIONS',
  );
  const String mapsKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  const String geminiKey = String.fromEnvironment('GEMINI_API_KEY');
  const String googleKey = String.fromEnvironment('GOOGLE_API_KEY');
  final String resolvedKey = geminiKey.isNotEmpty ? geminiKey : googleKey;

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
  if (resolvedKey.isNotEmpty) {
    result['GEMINI_API_KEY'] = resolvedKey;
  }

  if (SecretConfig.debugEnvironment case final env?) {
    result.addAll(env);
  }

  return result.isEmpty ? null : result;
}

Future<Map<String, dynamic>?> _readAssetSecrets() async {
  const String assetPath = 'assets/config/secrets.json';
  final AssetBundle bundle = SecretConfig.debugAssetBundle ?? rootBundle;
  final String? raw = await bundle
      .loadString(assetPath)
      .then<String?>((final value) => value)
      .catchError(
        (Object _) => null,
        test: (final error) => error is FlutterError,
      );
  if (raw == null) {
    // Asset not bundled; ignore silently for developers without a local file.
    return null;
  }

  try {
    // check-ignore: small payload (<8KB) - config files are small
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

Future<void> _persistGoogleMapsKey(final SecretStorage storage) async {
  final String? mapsKey = SecretConfig._googleMapsApiKey;
  if (mapsKey case final value?) {
    await storage.write(SecretConfig._keyGoogleMaps, value);
  }
}

Future<bool> _loadFromSource(
  final FutureOr<Map<String, dynamic>?> Function() read, {
  final Future<void> Function()? afterApply,
}) async {
  final Map<String, dynamic>? secrets =
      await Future<Map<String, dynamic>?>.value(read());
  if (secrets case final s? when _hasSecrets(s)) {
    _applySecrets(s);
    if (afterApply case final runAfterApply?) await runAfterApply();
    return true;
  }
  return false;
}
