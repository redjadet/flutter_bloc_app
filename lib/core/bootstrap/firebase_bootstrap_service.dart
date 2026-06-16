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
import 'package:flutter_bloc_app/shared/diagnostics/integration_log_messages.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

part 'firebase_bootstrap_service_app_check.part.dart';
part 'firebase_bootstrap_service_helpers.dart';

/// Service responsible for Firebase initialization and configuration
class FirebaseBootstrapService {
  static Future<bool>? _firebaseInitialization;

  /// Whether the default Firebase app has been created (e.g. for route guards
  /// and conditional UI such as the FCM demo entry).
  static bool get isFirebaseInitialized => Firebase.apps.isNotEmpty;

  /// Set during debug Firebase bootstrap when [DeviceInfoPlugin] reports a
  /// non-physical iOS device. Used for simulator-only auth keychain fallbacks.
  static bool isIosSimulatorInDebug = false;

  /// Best-effort iOS simulator detection for debug auth fallbacks when Firebase
  /// bootstrap is skipped (placeholder config, integration tests, hot restart).
  static Future<void> ensureIosSimulatorDebugFlag() async {
    await _markIosSimulatorInDebugIfNeeded();
  }

  /// Whether auth routing and local-only guest sign-in should work without a
  /// configured Firebase app (web debug, macOS debug, or iOS simulator debug).
  static bool get supportsDebugLocalGuestAuth {
    if (kReleaseMode) {
      return false;
    }
    if (kIsWeb) {
      return true;
    }
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return true;
    }
    return defaultTargetPlatform == TargetPlatform.iOS && isIosSimulatorInDebug;
  }

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
        await _prepareReusedFirebaseApp();
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

      final missingConfigFields = _missingFirebaseRequiredConfigFields(options);
      if (missingConfigFields.isNotEmpty) {
        AppLogger.info(
          'Firebase init skipped: missing Firebase config fields '
          '(${missingConfigFields.join(', ')}). Run `flutterfire configure`, '
          'or provide FIREBASE_* values through local direnv; see '
          'docs/firebase_setup.md.',
        );
        return false;
      }

      return _initializeConfiguredFirebase(options);
    } on FirebaseException catch (error, stackTrace) {
      if (error.code == 'duplicate-app') {
        AppLogger.warning(
          'Firebase already initialized natively. Reusing existing instance.',
        );
        Firebase.app();
        await _prepareReusedFirebaseApp();
        return true;
      }
      _logFirebaseInitializationFailure(error, stackTrace);
    } on Exception catch (error, stackTrace) {
      _logFirebaseInitializationFailure(error, stackTrace);
    }
    return false;
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

  /// Configure Firebase UI Auth providers
  static void configureFirebaseUI() {
    if (!isFirebaseInitialized) {
      AppLogger.info(
        'Firebase UI Auth configuration skipped: Firebase is not initialized.',
      );
      return;
    }

    final providers = <AuthProvider>[EmailAuthProvider()];

    final googleProvider = _createGoogleProvider();
    if (googleProvider case final provider?) {
      providers.add(provider);
    }

    FirebaseUIAuth.configureProviders(providers);
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

  static Future<bool> _initializeConfiguredFirebase(
    final FirebaseOptions options,
  ) async {
    await Firebase.initializeApp(options: options);
    AppLogger.info('Firebase initialized for project: ${options.projectId}');
    await _activateAppCheck();
    _enableDatabasePersistence();
    return true;
  }

  static Future<void> _prepareReusedFirebaseApp() async {
    await _markIosSimulatorInDebugIfNeeded();
    _enableDatabasePersistence();
  }

  @visibleForTesting
  static void resetIosSimulatorInDebugForTest() {
    isIosSimulatorInDebug = false;
  }

  static void _logFirebaseInitializationFailure(
    final Object error,
    final StackTrace stackTrace,
  ) {
    AppLogger.error('Firebase initialization failed', error, stackTrace);
  }
}
