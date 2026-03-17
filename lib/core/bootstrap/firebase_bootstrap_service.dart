import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/firebase_options.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Service responsible for Firebase initialization and configuration
class FirebaseBootstrapService {
  static Future<bool>? _firebaseInitialization;

  /// Whether the default Firebase app has been created (e.g. for route guards
  /// and conditional UI such as the FCM demo entry).
  static bool get isFirebaseInitialized => Firebase.apps.isNotEmpty;

  /// Initialize Firebase with platform-specific configuration
  static Future<bool> initializeFirebase() => _firebaseInitialization ??=
      _initializeFirebaseOnce().then((final initialized) {
        if (!initialized) {
          _firebaseInitialization = null;
        }
        return initialized;
      });

  static Future<bool> _initializeFirebaseOnce() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        AppLogger.debug(
          'Firebase already initialized: '
          '${Firebase.apps.map((final app) => app.name).join(', ')}',
        );
        // Enable persistence even if Firebase was already initialized
        _enableDatabasePersistence();
        return true;
      }

      final options = _resolveFirebaseOptions();
      if (options == null) {
        AppLogger.info(
          'Firebase init skipped: platform not supported or web. '
          'See docs/firebase_setup.md to run with Firebase.',
        );
        return false;
      }

      if (_usesPlaceholderValues(options)) {
        AppLogger.info(
          'Firebase init skipped: lib/firebase_options.dart has placeholder '
          'values. Run `flutterfire configure` to generate real config, or see '
          'docs/firebase_setup.md.',
        );
        return false;
      }

      await Firebase.initializeApp(options: options);
      AppLogger.info('Firebase initialized for project: ${options.projectId}');

      await _activateAppCheck();

      // Enable persistence immediately after initialization, before any database usage
      _enableDatabasePersistence();

      return true;
    } on FirebaseException catch (error, stackTrace) {
      if (error.code == 'duplicate-app') {
        AppLogger.warning(
          'Firebase already initialized natively. Reusing existing instance.',
        );
        Firebase.app();
        // Enable persistence even if Firebase was already initialized natively
        _enableDatabasePersistence();
        return true;
      }
      AppLogger.error('Firebase initialization failed', error, stackTrace);
    } on Exception catch (error, stackTrace) {
      AppLogger.error('Firebase initialization failed', error, stackTrace);
    }
    return false;
  }

  static FirebaseOptions? _resolveFirebaseOptions() {
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

  /// Enable Firebase Database persistence.
  /// Must be called before any database operations.
  static void _enableDatabasePersistence() {
    try {
      final FirebaseApp app = Firebase.app();
      FirebaseDatabase.instanceFor(app: app).setPersistenceEnabled(true);
      AppLogger.debug('Firebase Database persistence enabled');
    } on Exception catch (error, stackTrace) {
      // If persistence is already enabled or fails, log but don't fail initialization
      AppLogger.warning(
        'Failed to enable Firebase Database persistence: $error',
      );
      AppLogger.debug('Persistence setup stack trace\n$stackTrace');
    }
  }

  static Future<void> _activateAppCheck() async {
    if (kIsWeb) return;

    try {
      const debugTokenEnv = String.fromEnvironment(
        'FIREBASE_APPCHECK_DEBUG_TOKEN',
      );
      // On Apple simulators, attestation providers are unsupported; ensure debug
      // provider always has a token so it doesn't fall back to DeviceCheck/AppAttest.
      final debugToken = debugTokenEnv.isEmpty
          ? 'flutter_bloc_app_debug'
          : debugTokenEnv;

      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          await FirebaseAppCheck.instance.activate(
            providerAndroid: kDebugMode
                ? AndroidDebugProvider(
                    debugToken: debugToken,
                  )
                : const AndroidPlayIntegrityProvider(),
          );
          break;
        case TargetPlatform.iOS:
          if (kDebugMode) {
            final info = await DeviceInfoPlugin().iosInfo;
            if (!info.isPhysicalDevice) {
              AppLogger.info(
                'iOS simulator detected; using Firebase App Check debug provider.',
              );
            }
          }
          await FirebaseAppCheck.instance.activate(
            providerApple: kDebugMode
                ? AppleDebugProvider(
                    debugToken: debugToken,
                  )
                : const AppleAppAttestWithDeviceCheckFallbackProvider(),
          );
          break;
        case TargetPlatform.macOS:
          await FirebaseAppCheck.instance.activate(
            providerApple: kDebugMode
                ? AppleDebugProvider(
                    debugToken: debugToken,
                  )
                : const AppleAppAttestWithDeviceCheckFallbackProvider(),
          );
          break;
        default:
          return;
      }

      AppLogger.info(
        'Firebase App Check activated (${kDebugMode ? 'debug' : 'release'} mode)',
      );
      await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
      if (kDebugMode) {
        AppLogger.info('Firebase App Check debug token: $debugToken');
        if (debugTokenEnv.isEmpty) {
          AppLogger.warning(
            'Using default App Check debug token. For a unique token, run with '
            '--dart-define=FIREBASE_APPCHECK_DEBUG_TOKEN=<token> and add it in '
            'Firebase Console → App Check → Manage debug tokens.',
          );
        }
      }
    } on Exception catch (error, stackTrace) {
      AppLogger.warning('Firebase App Check activation failed: $error');
      AppLogger.debug('App Check activation stack trace\n$stackTrace');
    }
  }

  static bool _usesPlaceholderValues(final FirebaseOptions options) {
    // Match exact placeholder values from firebase_options_fallback.dart so we
    // do not skip real configs (e.g. project IDs that contain "placeholder").
    bool isPlaceholder(final String? value) {
      if (value == null || value.isEmpty) return true;
      const exactPlaceholders = [
        'your-project-id',
        'YOUR_ANDROID_API_KEY',
        'YOUR_IOS_API_KEY',
        'YOUR_MACOS_API_KEY',
        '1:000000000000:android:placeholder',
        '1:000000000000:ios:placeholder',
        '000000000000',
      ];
      if (exactPlaceholders.contains(value)) return true;
      if (value == 'your-project-id.appspot.com') return true;
      if (value.startsWith('YOUR_') && value.endsWith('_KEY')) return true;
      return false;
    }

    return isPlaceholder(options.projectId) ||
        isPlaceholder(options.appId) ||
        isPlaceholder(options.apiKey) ||
        isPlaceholder(options.messagingSenderId) ||
        isPlaceholder(options.storageBucket);
  }

  /// Configure Firebase UI Auth providers
  static void configureFirebaseUI() {
    final providers = <AuthProvider>[EmailAuthProvider()];

    final googleProvider = _createGoogleProvider();
    if (googleProvider case final provider?) {
      providers.add(provider);
    }

    FirebaseUIAuth.configureProviders(providers);
  }

  static GoogleProvider? _createGoogleProvider() {
    if (kIsWeb) return null;

    try {
      final platform = defaultTargetPlatform;
      if (platform != TargetPlatform.android &&
          platform != TargetPlatform.iOS) {
        return null;
      }

      final options = Firebase.app().options;
      final isIOS = platform == TargetPlatform.iOS;
      final platformClientId = isIOS
          ? options.iosClientId
          : options.androidClientId;
      final preferPlist = isIOS && (platformClientId?.isEmpty ?? true);

      final resolvedClientId = switch (platformClientId) {
        final id? when id.trim().isNotEmpty => id.trim(),
        _ => options.appId,
      };

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

  /// Register global crash reporting handlers
  static void registerCrashlyticsHandlers() {
    final previousFlutterHandler = FlutterError.onError;
    FlutterError.onError = (final details) {
      unawaited(FirebaseCrashlytics.instance.recordFlutterFatalError(details));
      previousFlutterHandler?.call(details);
    };

    final previousPlatformHandler = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (final error, final stackTrace) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          fatal: true,
        ),
      );
      return previousPlatformHandler?.call(error, stackTrace) ?? true;
    };
  }
}
