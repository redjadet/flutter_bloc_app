part of 'firebase_bootstrap_service.dart';

FirebaseOptions? _resolveFirebaseOptions() {
  final FirebaseOptions? override =
      FirebaseBootstrapService.debugOptionsOverride;
  if (override != null) {
    return override;
  }

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
  } on Object catch (error, stackTrace) {
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

/// Enable Firebase Database persistence.
/// Must be called before any database operations.
///
/// [FirebaseDatabase.setPersistenceEnabled] is typed `void` but still
/// schedules platform work that can fail asynchronously. Zone-guard so
/// plugin errors stay best-effort and never fail Firebase init.
Future<void> _enableDatabasePersistence() async {
  final Completer<void> done = Completer<void>();
  runZonedGuarded(
    () {
      try {
        final FirebaseApp app = Firebase.app();
        FirebaseDatabase.instanceFor(app: app).setPersistenceEnabled(true);
        AppLogger.debug('Firebase Database persistence enabled');
      } on Object catch (error, stackTrace) {
        AppLogger.warning(
          'Failed to enable Firebase Database persistence: $error',
        );
        AppLogger.debug('Persistence setup stack trace\n$stackTrace');
      } finally {
        scheduleMicrotask(() {
          if (!done.isCompleted) {
            done.complete();
          }
        });
      }
    },
    (error, stackTrace) {
      AppLogger.warning(
        'Failed to enable Firebase Database persistence: $error',
      );
      AppLogger.debug('Persistence setup stack trace\n$stackTrace');
      if (!done.isCompleted) {
        done.complete();
      }
    },
  );
  await done.future;
}

Future<bool> _initializeConfiguredFirebase(
  final FirebaseOptions options,
) async {
  await Firebase.initializeApp(options: options);
  AppLogger.info('Firebase initialized for project: ${options.projectId}');
  await _activateAppCheck();
  await _enableDatabasePersistence();
  return true;
}

Future<void> _prepareReusedFirebaseApp() async {
  await _markIosSimulatorInDebugIfNeeded();
  await _markAndroidEmulatorInDebugIfNeeded();
  await _enableDatabasePersistence();
}

void _logFirebaseInitializationFailure(
  final Object error,
  final StackTrace stackTrace,
) {
  AppLogger.error('Firebase initialization failed', error, stackTrace);
}
