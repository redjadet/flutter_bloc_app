part of 'firebase_bootstrap_service.dart';

FirebaseOptions? _resolveFirebaseOptions() {
  if (kIsWeb) {
    AppLogger.warning(
      'Firebase configuration has not been generated for web. Skip initialization.',
    );
    return null;
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return DefaultFirebaseOptions.android;
    case TargetPlatform.iOS:
      return DefaultFirebaseOptions.ios;
    case TargetPlatform.macOS:
      return DefaultFirebaseOptions.macos;
    default:
      AppLogger.warning(
        'Firebase configuration not available for platform $defaultTargetPlatform. '
        'Skip initialization.',
      );
      return null;
  }
}

List<String> _missingFirebaseRequiredConfigFields(
  final FirebaseOptions options,
) {
  final missing = <String>[];
  void addIfMissing(final String label, final String? value) {
    if (_isPlaceholderFirebaseValue(value)) {
      missing.add(label);
    }
  }

  addIfMissing('projectId', options.projectId);
  addIfMissing('appId', options.appId);
  addIfMissing('apiKey', options.apiKey);
  addIfMissing('messagingSenderId', options.messagingSenderId);
  addIfMissing('storageBucket', options.storageBucket);
  addIfMissing('databaseURL', options.databaseURL);
  return missing;
}

bool _isPlaceholderFirebaseValue(final String? value) {
  if (value == null || value.isEmpty) {
    return true;
  }

  const List<String> exactPlaceholders = <String>[
    'your-project-id',
    'YOUR_ANDROID_API_KEY',
    'YOUR_IOS_API_KEY',
    'YOUR_MACOS_API_KEY',
    '1:000000000000:android:placeholder',
    '1:000000000000:ios:placeholder',
    '000000000000',
  ];

  if (exactPlaceholders.contains(value)) {
    return true;
  }
  if (value == 'your-project-id.appspot.com') {
    return true;
  }
  return value.startsWith('YOUR_') && value.endsWith('_KEY');
}

GoogleProvider? _createGoogleProvider() {
  if (kIsWeb) {
    return null;
  }

  try {
    final TargetPlatform platform = defaultTargetPlatform;
    if (!_supportsGoogleProvider(platform)) {
      return null;
    }

    final FirebaseOptions options = Firebase.app().options;
    final bool isIOS = platform == TargetPlatform.iOS;
    final String? platformClientId = isIOS
        ? options.iosClientId
        : options.androidClientId;

    return GoogleProvider(
      clientId: _resolveGoogleClientId(options, platformClientId),
      iOSPreferPlist: isIOS && (platformClientId?.isEmpty ?? true),
    );
  } on FirebaseException catch (error, stackTrace) {
    AppLogger.warning(
      'Skipping Google sign-in configuration: ${error.message}',
    );
    AppLogger.debug('Google provider configuration stack trace\n$stackTrace');
    return null;
  } on Exception catch (error, stackTrace) {
    AppLogger.warning('Skipping Google sign-in configuration: $error');
    AppLogger.debug('Google provider configuration stack trace\n$stackTrace');
    return null;
  }
}

bool _supportsGoogleProvider(final TargetPlatform platform) {
  return platform == TargetPlatform.android || platform == TargetPlatform.iOS;
}

String _resolveGoogleClientId(
  final FirebaseOptions options,
  final String? platformClientId,
) {
  return switch (platformClientId) {
    final id? when id.trim().isNotEmpty => id.trim(),
    _ => options.appId,
  };
}
