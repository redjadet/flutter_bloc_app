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

Future<void> _activateAppCheck() async {
  if (kIsWeb) {
    return;
  }

  try {
    const String debugTokenEnv = String.fromEnvironment(
      'FIREBASE_APPCHECK_DEBUG_TOKEN',
    );
    final String debugToken = _resolveAppCheckDebugToken(debugTokenEnv);

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        await FirebaseAppCheck.instance.activate(
          providerAndroid: kDebugMode
              ? AndroidDebugProvider(debugToken: debugToken)
              : const AndroidPlayIntegrityProvider(),
        );
        break;
      case TargetPlatform.iOS:
        await _activateAppleAppCheck(
          debugToken: debugToken,
          logSimulatorInfo: true,
        );
        break;
      case TargetPlatform.macOS:
        await _activateAppleAppCheck(
          debugToken: debugToken,
          logSimulatorInfo: false,
        );
        break;
      default:
        return;
    }

    AppLogger.info(
      'Firebase App Check activated (${kDebugMode ? 'debug' : 'release'} mode)',
    );
    await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
    _logAppCheckDebugToken(debugToken, debugTokenEnv);
  } on Exception catch (error, stackTrace) {
    AppLogger.warning('Firebase App Check activation failed: $error');
    AppLogger.debug('App Check activation stack trace\n$stackTrace');
  }
}

Future<void> _activateAppleAppCheck({
  required final String debugToken,
  required final bool logSimulatorInfo,
}) async {
  if (kDebugMode && logSimulatorInfo) {
    final IosDeviceInfo info = await DeviceInfoPlugin().iosInfo;
    if (!info.isPhysicalDevice) {
      AppLogger.info(
        'iOS simulator detected; using Firebase App Check debug provider.',
      );
    }
  }

  await FirebaseAppCheck.instance.activate(
    providerApple: kDebugMode
        ? AppleDebugProvider(debugToken: debugToken)
        : const AppleAppAttestWithDeviceCheckFallbackProvider(),
  );
}

String _resolveAppCheckDebugToken(final String debugTokenEnv) {
  return debugTokenEnv.isEmpty ? 'flutter_bloc_app_debug' : debugTokenEnv;
}

void _logAppCheckDebugToken(
  final String debugToken,
  final String debugTokenEnv,
) {
  if (!kDebugMode) {
    return;
  }

  AppLogger.info('Firebase App Check debug token: $debugToken');
  if (debugTokenEnv.isEmpty) {
    AppLogger.warning(
      'Using default App Check debug token. For a unique token, run with '
      '--dart-define=FIREBASE_APPCHECK_DEBUG_TOKEN=<token> and add it in '
      'Firebase Console → App Check → Manage debug tokens.',
    );
  }
}

bool _usesPlaceholderValues(final FirebaseOptions options) {
  return _isPlaceholderFirebaseValue(options.projectId) ||
      _isPlaceholderFirebaseValue(options.appId) ||
      _isPlaceholderFirebaseValue(options.apiKey) ||
      _isPlaceholderFirebaseValue(options.messagingSenderId) ||
      _isPlaceholderFirebaseValue(options.storageBucket);
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
