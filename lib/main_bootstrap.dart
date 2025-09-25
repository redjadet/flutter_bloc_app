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

Future<void> runAppWithFlavor(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  final bool firebaseReady = await _initializeFirebase();
  if (firebaseReady) {
    _configureFirebaseUI();
    _registerCrashlyticsGlobalHandlers();
  }
  FlavorManager.set(flavor);
  await PlatformInit.initialize();
  await SecretConfig.load();
  await configureDependencies();
  runApp(const MyApp());
}

Future<bool> _initializeFirebase() async {
  try {
    final FirebaseOptions options = DefaultFirebaseOptions.currentPlatform;
    if (_usesPlaceholderValues(options)) {
      AppLogger.warning(
        'Firebase configuration uses placeholder values. Skip initialization.',
      );
      return false;
    }

    await Firebase.initializeApp(options: options);
    AppLogger.info('Firebase initialized for project: ${options.projectId}');
    return true;
  } on UnsupportedError catch (error, stackTrace) {
    AppLogger.warning('Firebase not configured: $error');
    AppLogger.debug('Skipping Firebase initialization\n$stackTrace');
  } catch (error, stackTrace) {
    AppLogger.error('Firebase initialization failed', error, stackTrace);
  }
  return false;
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
  } catch (error, stackTrace) {
    AppLogger.warning('Skipping Google sign-in configuration: $error');
    AppLogger.debug('Google provider configuration stack trace\n$stackTrace');
    return null;
  }
}

bool _usesPlaceholderValues(FirebaseOptions options) {
  bool containsPlaceholder(String? value) {
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
  FlutterError.onError = (FlutterErrorDetails details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    previousFlutterHandler?.call(details);
  };

  final bool Function(Object, StackTrace)? previousPlatformHandler =
      PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
    return previousPlatformHandler?.call(error, stackTrace) ?? true;
  };
}
