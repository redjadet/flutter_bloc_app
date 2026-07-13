import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app.dart';
import 'package:flutter_bloc_app/app/bootstrap/app_version_service.dart';
import 'package:flutter_bloc_app/app/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/app/bootstrap/initialization_guard.dart';
import 'package:flutter_bloc_app/app/bootstrap/platform_init.dart';
import 'package:flutter_bloc_app/app/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/app/bootstrap/web_launch_splash.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/config/app_runtime_config.dart';
import 'package:flutter_bloc_app/app/config/backend_availability.dart';
import 'package:flutter_bloc_app/app/config/flavor.dart';
import 'package:flutter_bloc_app/app/config/secret_config.dart';
import 'package:storage/storage.dart';

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
  static BackendAvailability Function() readBackendAvailability = () =>
      getIt.isRegistered<BackendAvailability>()
      ? getIt<BackendAvailability>()
      : BackendAvailability.fromBootstrap();

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

  /// Whether to paint [WebLaunchSplash] before async bootstrap finishes.
  /// Defaults to [kIsWeb]; overridable in tests.
  @visibleForTesting
  static bool Function() shouldShowWebLaunchSplash = () => kIsWeb;

  /// Whether Supabase may finish after first [MyApp] paint.
  ///
  /// Firebase must finish before DI: [MyApp] resolves its auth repository while
  /// creating its router, and that registration selects its implementation
  /// from Firebase availability. Supabase remains optional on web.
  @visibleForTesting
  static bool Function() shouldDeferBackendInit = () => kIsWeb;

  @visibleForTesting
  static void Function(Future<void> Function() work) scheduleDeferredWork =
      _scheduleBackendInitAfterFirstFrame;

  @visibleForTesting
  static void Function() notifyBackendAvailabilityUpdated =
      BackendAvailabilityUpdates.instance.notifyUpdated;

  /// Run the complete application bootstrap with the given flavor
  static Future<void> bootstrapApp(final Flavor flavor) async {
    ensureBindingInitialized();

    // Set flavor early
    FlavorManager.current = flavor;

    // Web: paint a splash immediately so the canvas is not blank while the
    // remaining async bootstrap (secrets, backends, DI, migration) runs.
    // Native hosts already show a platform splash; HTML covers pre-Dart load.
    if (shouldShowWebLaunchSplash()) {
      startApp(const WebLaunchSplash());
    }

    // Initialize platform
    await initializePlatform();

    // Secrets and version are independent; overlap their I/O on web/desktop.
    await Future.wait<void>(<Future<void>>[_loadSecrets(), loadAppVersion()]);

    if (shouldDeferBackendInit()) {
      // Firebase determines DI registrations used by MyApp's router. Defer
      // only optional Supabase so configured Firebase auth is never replaced
      // by the web-local guest implementation for this app lifetime.
      await _initializeFirebase();
      await _finishCoreAndStartApp();
      scheduleDeferredWork(_initializeSupabaseDeferred);
      return;
    }

    await _initializeBackends();
    await _finishCoreAndStartApp();
  }

  static void _scheduleBackendInitAfterFirstFrame(
    final Future<void> Function() work,
  ) {
    final WidgetsBinding _ = WidgetsBinding.instance
      ..addPostFrameCallback((_) {
        unawaited(work());
      })
      // runApp may not have scheduled a frame yet; force one so deferred work runs.
      ..ensureVisualUpdate();
  }

  static Future<void> _initializeBackends() async {
    final Future<void> supabaseFuture = initializeSupabase();
    await _initializeFirebase();
    await supabaseFuture;
  }

  static Future<void> _initializeFirebase() async {
    final bool firebaseReady = await initializeFirebase();
    if (firebaseReady) {
      configureFirebaseUi();
      registerCrashlyticsHandlers();
    }
  }

  static Future<void> _initializeSupabaseDeferred() async {
    try {
      await initializeSupabase();
    } on Object catch (error, stackTrace) {
      AppLogger.warning('Deferred Supabase initialization failed');
      AppLogger.error(
        'BootstrapCoordinator._initializeSupabaseDeferred',
        error,
        stackTrace,
      );
    } finally {
      readBackendAvailability();
      notifyBackendAvailabilityUpdated();
    }
  }

  static Future<void> _finishCoreAndStartApp() async {
    await setupDependencies();
    readRuntimeConfig();
    readBackendAvailability();
    await runMigration();
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
    readBackendAvailability = () => getIt.isRegistered<BackendAvailability>()
        ? getIt<BackendAvailability>()
        : BackendAvailability.fromBootstrap();
    runMigration = () {
      return InitializationGuard.executeSafely(
        () => getIt<SharedPreferencesMigrationService>().migrateIfNeeded(),
        context: 'bootstrapApp',
        failureMessage:
            'Migration failed during app startup. App will continue.',
      );
    };
    startApp = runApp;
    shouldShowWebLaunchSplash = () => kIsWeb;
    shouldDeferBackendInit = () => kIsWeb;
    scheduleDeferredWork = _scheduleBackendInitAfterFirstFrame;
    notifyBackendAvailabilityUpdated =
        BackendAvailabilityUpdates.instance.notifyUpdated;
  }
}
