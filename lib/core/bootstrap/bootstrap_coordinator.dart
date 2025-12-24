import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app.dart';
import 'package:flutter_bloc_app/core/bootstrap/app_version_service.dart';
import 'package:flutter_bloc_app/core/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_bloc_app/core/platform_init.dart';
import 'package:flutter_bloc_app/shared/storage/shared_preferences_migration_service.dart';
import 'package:flutter_bloc_app/shared/utils/initialization_guard.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Coordinates the application bootstrap process
class BootstrapCoordinator {
  /// Run the complete application bootstrap with the given flavor
  static Future<void> bootstrapApp(final Flavor flavor) async {
    WidgetsFlutterBinding.ensureInitialized();

    // Set flavor early
    FlavorManager.current = flavor;

    // Initialize platform
    await PlatformInit.initialize();

    // Load secrets with flavor-appropriate fallbacks
    await _loadSecrets();

    // Load app version for DI
    await AppVersionService.loadAppVersion();

    // Initialize Firebase if configured
    final firebaseReady = await FirebaseBootstrapService.initializeFirebase();
    if (firebaseReady) {
      FirebaseBootstrapService.configureFirebaseUI();
      FirebaseBootstrapService.registerCrashlyticsHandlers();
    }

    // Setup dependency injection
    await configureDependencies();

    // Run migration (non-blocking, graceful failure)
    await InitializationGuard.executeSafely(
      () => getIt<SharedPreferencesMigrationService>().migrateIfNeeded(),
      context: 'bootstrapApp',
      failureMessage: 'Migration failed during app startup. App will continue.',
    );

    // Start the app
    runApp(const MyApp());
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

    final allowAssets =
        enableAssetSecrets && (FlavorManager.I.isDev || kDebugMode);
    await SecretConfig.load(allowAssetFallback: allowAssets);
  }
}
