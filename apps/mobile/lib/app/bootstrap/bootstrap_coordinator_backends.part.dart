part of 'bootstrap_coordinator.dart';

void _scheduleBackendInitAfterFirstFrame(final Future<void> Function() work) {
  // runApp may not have scheduled a frame yet; force one so deferred work runs.
  WidgetsBinding.instance
    ..addPostFrameCallback((_) {
      unawaited(work());
    })
    ..ensureVisualUpdate();
}

Future<void> _initializeBackends() async {
  final Future<void> supabaseFuture = BootstrapCoordinator.initializeSupabase();
  await _initializeFirebase();
  await supabaseFuture;
}

Future<void> _initializeFirebase() async {
  final bool firebaseReady = await BootstrapCoordinator.initializeFirebase();
  if (firebaseReady) {
    BootstrapCoordinator.configureFirebaseUi();
    BootstrapCoordinator.registerCrashlyticsHandlers();
  }
}

Future<void> _initializeSupabaseDeferred() async {
  try {
    await BootstrapCoordinator.initializeSupabase();
  } on Object catch (error, stackTrace) {
    AppLogger.warning('Deferred Supabase initialization failed');
    AppLogger.error(
      'BootstrapCoordinator._initializeSupabaseDeferred',
      error,
      stackTrace,
    );
  } finally {
    BootstrapCoordinator.readBackendAvailability();
    BootstrapCoordinator.notifyBackendAvailabilityUpdated();
  }
}

Future<void> _finishCoreAndStartApp() async {
  await BootstrapCoordinator.setupDependencies();
  BootstrapCoordinator.readRuntimeConfig();
  BootstrapCoordinator.readBackendAvailability();
  await BootstrapCoordinator.runMigration();
  BootstrapCoordinator.startApp(const MyApp());
}

Future<void> _loadSecrets() async {
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
  await BootstrapCoordinator.loadSecrets(allowAssetFallback: allowAssets);
}
