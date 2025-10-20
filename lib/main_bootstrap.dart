import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_bloc_app/core/platform_init.dart';
import 'package:flutter_bloc_app/firebase_options.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

Future<void> runAppWithFlavor(final Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  const bool enableAssetSecrets = bool.fromEnvironment(
    SecretConfig.enableAssetSecretsDefine,
    defaultValue: true,
  );
  final bool firebaseReady = await _initializeFirebase();
  if (firebaseReady) {
    _configureFirebaseUI();
    _registerCrashlyticsGlobalHandlers();
  }
  FlavorManager.set(flavor);
  await PlatformInit.initialize();
  if (!FlavorManager.I.isDev && enableAssetSecrets) {
    AppLogger.warning(
      'ENABLE_ASSET_SECRETS is true outside dev flavor; ignoring asset fallback.',
    );
  }
  final bool allowAssets =
      enableAssetSecrets && (FlavorManager.I.isDev || kDebugMode);

  await SecretConfig.load(allowAssetFallback: allowAssets);
  await configureDependencies();
  runApp(const MyApp());
}

Future<bool>? _firebaseInitialization;

Future<bool> _initializeFirebase() => _firebaseInitialization ??=
    _initializeFirebaseOnce().then((final bool initialized) {
      if (!initialized) {
        _firebaseInitialization = null;
      }
      return initialized;
    });

Future<bool> _initializeFirebaseOnce() async {
  try {
    if (Firebase.apps.isNotEmpty) {
      AppLogger.debug(
        'Firebase already initialized: '
        '${Firebase.apps.map((final FirebaseApp app) => app.name).join(', ')}',
      );
      return true;
    }

    final FirebaseOptions? options = _resolveFirebaseOptions();
    if (options == null) {
      return false;
    }
    if (_usesPlaceholderValues(options)) {
      AppLogger.warning(
        'Firebase configuration uses placeholder values. Skip initialization.',
      );
      return false;
    }

    await Firebase.initializeApp(options: options);
    AppLogger.info('Firebase initialized for project: ${options.projectId}');
    return true;
  } on FirebaseException catch (error, stackTrace) {
    if (error.code == 'duplicate-app') {
      AppLogger.warning(
        'Firebase already initialized natively. Reusing existing instance.',
      );
      Firebase.app();
      return true;
    }
    AppLogger.error('Firebase initialization failed', error, stackTrace);
  } on Exception catch (error, stackTrace) {
    AppLogger.error('Firebase initialization failed', error, stackTrace);
  }
  return false;
}

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

void _configureFirebaseUI() {
  final List<AuthProvider> providers = <AuthProvider>[EmailAuthProvider()];

  final GoogleProvider? googleProvider = _createGoogleProvider();
  if (googleProvider != null) {
    providers.add(googleProvider);
  }

  FirebaseUIAuth.configureProviders(providers);
}

GoogleProvider? _createGoogleProvider() {
  if (kIsWeb) return null;

  try {
    final TargetPlatform platform = defaultTargetPlatform;
    if (platform != TargetPlatform.android && platform != TargetPlatform.iOS) {
      return null;
    }

    final FirebaseOptions options = Firebase.app().options;
    final bool isIOS = platform == TargetPlatform.iOS;
    final String? platformClientId = isIOS
        ? options.iosClientId
        : options.androidClientId;
    final bool preferPlist = isIOS && (platformClientId?.isEmpty ?? true);

    final String resolvedClientId =
        (platformClientId?.trim().isNotEmpty ?? false)
        ? platformClientId!.trim()
        : options.appId;

    return GoogleProvider(
      clientId: resolvedClientId,
      iOSPreferPlist: preferPlist,
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

bool _usesPlaceholderValues(final FirebaseOptions options) {
  bool containsPlaceholder(final String? value) {
    if (value == null || value.isEmpty) return true;
    const List<String> markers = <String>[
      'your-project-id',
      'YOUR_',
      'placeholder',
      '000000000000',
    ];
    return markers.any(value.contains);
  }

  return containsPlaceholder(options.projectId) ||
      containsPlaceholder(options.appId) ||
      containsPlaceholder(options.apiKey) ||
      containsPlaceholder(options.messagingSenderId) ||
      containsPlaceholder(options.storageBucket);
}

void _registerCrashlyticsGlobalHandlers() {
  final FlutterExceptionHandler? previousFlutterHandler = FlutterError.onError;
  FlutterError.onError = (final FlutterErrorDetails details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    previousFlutterHandler?.call(details);
  };

  final bool Function(Object, StackTrace)? previousPlatformHandler =
      PlatformDispatcher.instance.onError;
  PlatformDispatcher
      .instance
      .onError = (final Object error, final StackTrace stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
    return previousPlatformHandler?.call(error, stackTrace) ?? true;
  };
}
