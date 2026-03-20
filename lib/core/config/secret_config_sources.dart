part of 'secret_config.dart';

final List<_SecretStorageField> _secureStorageFields = <_SecretStorageField>[
  _SecretStorageField(
    storageKey: SecretConfig._keyHfToken,
    envKey: 'HUGGINGFACE_API_KEY',
    readValue: () => SecretConfig._huggingfaceApiKey,
    applyValue: (final value) => SecretConfig._huggingfaceApiKey = value,
  ),
  _SecretStorageField(
    storageKey: SecretConfig._keyHfModel,
    envKey: 'HUGGINGFACE_MODEL',
    readValue: () => SecretConfig._huggingfaceModel,
    applyValue: (final value) => SecretConfig._huggingfaceModel = value,
  ),
  _SecretStorageField(
    storageKey: SecretConfig._keyGoogleMaps,
    envKey: 'GOOGLE_MAPS_API_KEY',
    readValue: () => SecretConfig._googleMapsApiKey,
    applyValue: (final value) => SecretConfig._googleMapsApiKey = value,
  ),
  _SecretStorageField(
    storageKey: SecretConfig._keyGeminiApiKey,
    envKey: 'GEMINI_API_KEY',
    readValue: () => SecretConfig._geminiApiKey,
    applyValue: (final value) => SecretConfig._geminiApiKey = value,
  ),
  _SecretStorageField(
    storageKey: SecretConfig._keySupabaseUrl,
    envKey: 'SUPABASE_URL',
    readValue: () => SecretConfig._supabaseUrl,
    applyValue: (final value) => SecretConfig._supabaseUrl = value,
  ),
  _SecretStorageField(
    storageKey: SecretConfig._keySupabaseAnonKey,
    envKey: 'SUPABASE_ANON_KEY',
    readValue: () => SecretConfig._supabaseAnonKey,
    applyValue: (final value) => SecretConfig._supabaseAnonKey = value,
  ),
];

Future<Map<String, dynamic>?> _readSecureSecrets(
  final SecretStorage storage,
) async {
  try {
    final Map<String, dynamic> secrets = <String, dynamic>{};
    for (final _SecretStorageField field in _secureStorageFields) {
      final String? value = await storage.read(field.storageKey);
      if (value == null || value.isEmpty) {
        continue;
      }
      secrets[field.envKey] = value;
    }

    final String? flag = await storage.read(
      SecretConfig._keyHfUseChatCompletions,
    );
    if (flag != null && flag.isNotEmpty) {
      secrets['HUGGINGFACE_USE_CHAT_COMPLETIONS'] = flag == 'true';
    }

    if (secrets.isEmpty) {
      return null;
    }
    return secrets;
  } on Exception {
    AppLogger.warning('SecretConfig secure read failed');
    return null;
  }
}

Future<void> _persistToSecureStorage(final SecretStorage storage) async {
  for (final _SecretStorageField field in _secureStorageFields) {
    await field.persist(storage);
  }
  await storage.write(
    SecretConfig._keyHfUseChatCompletions,
    SecretConfig._useChatCompletions.toString(),
  );
}

void _applySecrets(final Map<String, dynamic> json) {
  for (final _SecretStorageField field in _secureStorageFields) {
    field.applyNormalized(json[field.envKey]);
  }

  final Object? flag = json['HUGGINGFACE_USE_CHAT_COMPLETIONS'];
  if (flag is bool) {
    SecretConfig._useChatCompletions = flag;
  } else if (flag is String) {
    SecretConfig._useChatCompletions = flag.toLowerCase() == 'true';
  } else {
    SecretConfig._useChatCompletions = false;
  }
  final String? googleKey = stringFromDynamic(json['GOOGLE_API_KEY'])?.trim();
  final String? geminiKey = SecretConfig._geminiApiKey;
  final String? resolvedKey = (geminiKey?.isNotEmpty ?? false)
      ? geminiKey
      : googleKey;
  SecretConfig._geminiApiKey = (resolvedKey?.isEmpty ?? true)
      ? null
      : resolvedKey;
}

bool _hasSecrets(final Map<String, dynamic>? source) {
  if (source == null) return false;
  final Object? flag = source['HUGGINGFACE_USE_CHAT_COMPLETIONS'];
  final String? googleKey = stringFromDynamic(source['GOOGLE_API_KEY'])?.trim();
  final bool hasConfiguredField = _secureStorageFields.any(
    (final field) => field.normalizedFrom(source[field.envKey]) != null,
  );
  final bool hasFlag =
      flag is bool || (flag is String && flag.trim().isNotEmpty);
  final bool hasGoogleKey = googleKey != null && googleKey.isNotEmpty;

  return hasConfiguredField || hasFlag || hasGoogleKey;
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
  const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

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
  if (supabaseUrl.isNotEmpty) {
    result['SUPABASE_URL'] = supabaseUrl;
  }
  if (supabaseAnonKey.isNotEmpty) {
    result['SUPABASE_ANON_KEY'] = supabaseAnonKey;
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
  } on FormatException {
    AppLogger.warning('SecretConfig asset parse failed');
  } on Exception {
    AppLogger.warning('SecretConfig asset read failed');
  }
  return null;
}

Future<void> _persistGoogleMapsKey(final SecretStorage storage) async {
  await _secureStorageFields
      .firstWhere(
        (final field) => field.storageKey == SecretConfig._keyGoogleMaps,
      )
      .persist(storage);
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

final class _SecretStorageField {
  const _SecretStorageField({
    required this.storageKey,
    required this.envKey,
    required this.readValue,
    required this.applyValue,
  });

  final String storageKey;
  final String envKey;
  final String? Function() readValue;
  final void Function(String? value) applyValue;

  String? normalizedFrom(final Object? sourceValue) {
    final String? value = stringFromDynamic(sourceValue)?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  void applyNormalized(final Object? sourceValue) {
    applyValue(normalizedFrom(sourceValue));
  }

  Future<void> persist(final SecretStorage storage) async {
    final String? value = readValue();
    if (value case final persistedValue?) {
      await storage.write(storageKey, persistedValue);
    }
  }
}
