import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app.dart';
import 'package:flutter_bloc_app/core/bootstrap/app_version_service.dart';
import 'package:flutter_bloc_app/core/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/config/app_runtime_config.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_bloc_app/core/platform_init.dart';
import 'package:flutter_bloc_app/shared/storage/shared_preferences_migration_service.dart';
import 'package:flutter_bloc_app/shared/utils/initialization_guard.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Coordinates the application bootstrap process
class BootstrapCoordinator {
  @visibleForTesting
  static void Function() ensureBindingInitialized =
      WidgetsFlutterBinding.ensureInitialized;

  @visibleForTesting
  static Future<void> Function() initializePlatform = PlatformInit.initialize;

  @visibleForTesting
  static Future<void> Function({
    required bool allowAssetFallback,
  })
  loadSecrets =
      ({
        required final allowAssetFallback,
      }) => SecretConfig.load(allowAssetFallback: allowAssetFallback);

  @visibleForTesting
  static Future<void> Function() loadAppVersion =
      AppVersionService.loadAppVersion;

  @visibleForTesting
  static Future<bool> Function() initializeFirebase =
      FirebaseBootstrapService.initializeFirebase;

  @visibleForTesting
  static void Function() configureFirebaseUi =
      FirebaseBootstrapService.configureFirebaseUI;

  @visibleForTesting
  static void Function() registerCrashlyticsHandlers =
      FirebaseBootstrapService.registerCrashlyticsHandlers;

  @visibleForTesting
  static Future<void> Function() initializeSupabase =
      SupabaseBootstrapService.initializeSupabase;

  @visibleForTesting
  static Future<void> Function() setupDependencies = configureDependencies;

  @visibleForTesting
  static AppRuntimeConfig Function() readRuntimeConfig = () =>
      getIt<AppRuntimeConfig>();

  @visibleForTesting
  static Future<void> Function() runMigration = () {
    return InitializationGuard.executeSafely(
      () => getIt<SharedPreferencesMigrationService>().migrateIfNeeded(),
      context: 'bootstrapApp',
      failureMessage: 'Migration failed during app startup. App will continue.',
    );
  };

  @visibleForTesting
  static void Function(Widget app) startApp = runApp;

  /// Run the complete application bootstrap with the given flavor
  static Future<void> bootstrapApp(final Flavor flavor) async {
    ensureBindingInitialized();

    // Set flavor early
    FlavorManager.current = flavor;

    // Initialize platform
    await initializePlatform();

    // Load secrets with flavor-appropriate fallbacks
    await _loadSecrets();

    // Load app version for DI
    await loadAppVersion();

    // Initialize Firebase if configured
    final firebaseReady = await initializeFirebase();
    if (firebaseReady) {
      configureFirebaseUi();
      registerCrashlyticsHandlers();
    }

    // Initialize Supabase if URL and anon key are configured
    await initializeSupabase();

    // Setup dependency injection
    await setupDependencies();

    // Materialize app runtime config at init (single place for feature/endpoint control)
    readRuntimeConfig();

    // Run migration (non-blocking, graceful failure)
    await runMigration();

    // Start the app
    startApp(const MyApp());
  }

  static Future<void> _loadSecrets() async {
    const enableAssetSecrets = bool.fromEnvironment(
      SecretConfig.enableAssetSecretsDefine,
      defaultValue: true,
    );

    if (!FlavorManager.I.isDev && enableAssetSecrets) {
      AppLogger.warning(
        'ENABLE_ASSET_SECRETS is true outside dev flavor; ignoring asset fallback.',
      );
    }

    final bool allowAssets =
        enableAssetSecrets && FlavorManager.I.isDev && kDebugMode;
    await loadSecrets(allowAssetFallback: allowAssets);
  }

  @visibleForTesting
  static void resetForTest() {
    ensureBindingInitialized = WidgetsFlutterBinding.ensureInitialized;
    initializePlatform = PlatformInit.initialize;
    loadSecrets =
        ({
          required final allowAssetFallback,
        }) => SecretConfig.load(allowAssetFallback: allowAssetFallback);
    loadAppVersion = AppVersionService.loadAppVersion;
    initializeFirebase = FirebaseBootstrapService.initializeFirebase;
    configureFirebaseUi = FirebaseBootstrapService.configureFirebaseUI;
    registerCrashlyticsHandlers =
        FirebaseBootstrapService.registerCrashlyticsHandlers;
    initializeSupabase = SupabaseBootstrapService.initializeSupabase;
    setupDependencies = configureDependencies;
    readRuntimeConfig = () => getIt<AppRuntimeConfig>();
    runMigration = () {
      return InitializationGuard.executeSafely(
        () => getIt<SharedPreferencesMigrationService>().migrateIfNeeded(),
        context: 'bootstrapApp',
        failureMessage:
            'Migration failed during app startup. App will continue.',
      );
    };
    startApp = runApp;
  }
}
