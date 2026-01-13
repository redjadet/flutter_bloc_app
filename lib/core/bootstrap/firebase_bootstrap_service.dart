import 'dart:async';

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

  static bool _usesPlaceholderValues(final FirebaseOptions options) {
    bool containsPlaceholder(final String? value) {
      if (value == null || value.isEmpty) return true;
      const markers = [
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

  /// Configure Firebase UI Auth providers
  static void configureFirebaseUI() {
    final providers = <AuthProvider>[EmailAuthProvider()];

    final googleProvider = _createGoogleProvider();
    if (googleProvider != null) {
      providers.add(googleProvider);
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

      final resolvedClientId = (platformClientId?.trim().isNotEmpty ?? false)
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
