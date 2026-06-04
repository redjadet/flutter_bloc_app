part of '../injector_registrations.dart';

Future<void> registerDemoServices() async {
  registerIgamingDemoServices();
  registerFcmDemoServices();
  registerRealtimeMarketServices();
  registerIotDemoServices();
  registerInAppPurchaseDemoServices();
  registerStaffAppDemoServices();
  registerAiDecisionDemoServices();
  registerEventBusDemoServices();
  registerOnlineTherapyDemoServices();
  _registerMemoryServices();
  _registerCameraGalleryServices();
  _registerScapesServices();
  _registerUtilityServices();
  _registerSyncServices();
}

void _registerMemoryServices() {
  if (!_isFlutterTestProcess) {
    registerLazySingletonIfAbsent<AppImageCacheManager>(
      AppImageCacheManager.new,
      dispose: (final manager) => manager.dispose(),
    );
  }
  registerLazySingletonIfAbsent<AppMemoryService>(
    () => _isFlutterTestProcess
        ? AppMemoryService(
            onImageCacheTrim: (level) async {},
          )
        : AppMemoryService(
            imageCacheManager: getIt<AppImageCacheManager>(),
            onChartMemoryTrim: (level) async {
              HttpChartRepository.trimMemory(level);
            },
          ),
  );
}

void _registerCameraGalleryServices() {
  registerLazySingletonIfAbsent<CameraGalleryRepository>(
    ImagePickerCameraGalleryRepository.new,
  );
}

void _registerScapesServices() {
  registerLazySingletonIfAbsent<ScapesRepository>(MockScapesRepository.new);
}

void _registerUtilityServices() {
  registerLazySingletonIfAbsent<BiometricAuthenticator>(
    LocalBiometricAuthenticator.new,
  );
  registerLazySingletonIfAbsent<ErrorNotificationService>(
    SnackbarErrorNotificationService.new,
  );
}

void _registerSyncServices() {
  registerLazySingletonIfAbsent<SyncableRepositoryRegistry>(
    SyncableRepositoryRegistry.new,
  );
  registerLazySingletonIfAbsent<PendingSyncRepository>(
    () => PendingSyncRepository(hiveService: getIt<HiveService>()),
    dispose: (final repository) => repository.dispose(),
  );
  registerLazySingletonIfAbsent<BackgroundSyncCoordinator>(
    () {
      final IotDemoRealtimeSubscription realtime =
          getIt<IotDemoRealtimeSubscription>();
      return BackgroundSyncCoordinator(
        repository: getIt<PendingSyncRepository>(),
        networkStatusService: getIt<NetworkStatusService>(),
        timerService: getIt<TimerService>(),
        registry: getIt<SyncableRepositoryRegistry>(),
        getSyncSupabaseUserId: () =>
            getIt<SupabaseAuthRepository>().currentUser?.id,
        startIotDemoRealtimeSubscription: (final onSyncRequested) =>
            realtime.start(onSyncRequested),
        stopIotDemoRealtimeSubscription: () => unawaited(realtime.stop()),
      );
    },
    dispose: (final coordinator) => coordinator.dispose(),
  );
}
