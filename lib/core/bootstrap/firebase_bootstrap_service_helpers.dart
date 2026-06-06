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
        final bool activated = await _activateAppleAppCheck(
          debugToken: debugToken,
          logSimulatorInfo: true,
        );
        if (!activated) {
          return;
        }
        break;
      case TargetPlatform.macOS:
        final bool activated = await _activateAppleAppCheck(
          debugToken: debugToken,
          logSimulatorInfo: false,
        );
        if (!activated) {
          return;
        }
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

/// Marks [FirebaseBootstrapService.isIosSimulatorInDebug] in debug iOS simulators.
/// Called from App Check activation and when reusing an existing Firebase app so
/// DI still skips RTDB remotes after hot restart or duplicate-app reuse.
Future<void> _markIosSimulatorInDebugIfNeeded() async {
  if (!kDebugMode || defaultTargetPlatform != TargetPlatform.iOS) {
    return;
  }
  try {
    final IosDeviceInfo info = await DeviceInfoPlugin().iosInfo;
    if (!info.isPhysicalDevice) {
      FirebaseBootstrapService.isIosSimulatorInDebug = true;
    }
  } on Exception catch (_) {
    // Best-effort; DI fallbacks remain disabled when detection fails.
  }
}

Future<bool> _activateAppleAppCheck({
  required final String debugToken,
  required final bool logSimulatorInfo,
}) async {
  if (kDebugMode && logSimulatorInfo) {
    await _markIosSimulatorInDebugIfNeeded();
    if (FirebaseBootstrapService.isIosSimulatorInDebug) {
      AppLogger.info(
        'iOS simulator detected; skipping Firebase App Check activation in debug.',
      );
      return false;
    }
  }

  await FirebaseAppCheck.instance.activate(
    providerApple: kDebugMode
        ? AppleDebugProvider(debugToken: debugToken)
        : const AppleAppAttestWithDeviceCheckFallbackProvider(),
  );
  return true;
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
      '${IntegrationLogMessages.appCheckDebugTokenPrefix} For a unique token, run with '
      '--dart-define=FIREBASE_APPCHECK_DEBUG_TOKEN=<token> and add it in '
      'Firebase Console → App Check → Manage debug tokens.',
    );
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
