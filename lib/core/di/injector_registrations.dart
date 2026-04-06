import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/core/config/app_runtime_config.dart';
import 'package:flutter_bloc_app/core/config/supabase_config_coordinator.dart';
import 'package:flutter_bloc_app/core/config/supabase_config_provider.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_factories.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/core/di/register_auth_services.dart';
import 'package:flutter_bloc_app/core/di/register_calculator_services.dart';
import 'package:flutter_bloc_app/core/di/register_case_study_demo_services.dart';
import 'package:flutter_bloc_app/core/di/register_chart_services.dart';
import 'package:flutter_bloc_app/core/di/register_chat_services.dart';
import 'package:flutter_bloc_app/core/di/register_fcm_demo_services.dart';
import 'package:flutter_bloc_app/core/di/register_genui_services.dart';
import 'package:flutter_bloc_app/core/di/register_graphql_services.dart';
import 'package:flutter_bloc_app/core/di/register_http_services.dart';
import 'package:flutter_bloc_app/core/di/register_igaming_demo_services.dart';
import 'package:flutter_bloc_app/core/di/register_in_app_purchase_demo_services.dart';
import 'package:flutter_bloc_app/core/di/register_iot_demo_services.dart';
import 'package:flutter_bloc_app/core/di/register_playlearn_services.dart';
import 'package:flutter_bloc_app/core/di/register_profile_services.dart';
import 'package:flutter_bloc_app/core/di/register_remote_config_services.dart';
import 'package:flutter_bloc_app/core/di/register_search_services.dart';
import 'package:flutter_bloc_app/core/di/register_supabase_services.dart';
import 'package:flutter_bloc_app/core/di/register_todo_services.dart';
import 'package:flutter_bloc_app/core/di/register_walletconnect_auth_services.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/camera_gallery/data/image_picker_camera_gallery_repository.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/deeplink/data/app_links_deep_link_service.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_parser.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_service.dart';
import 'package:flutter_bloc_app/features/google_maps/data/sample_map_location_repository.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/data/iot_demo_realtime_subscription.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_service.dart';
import 'package:flutter_bloc_app/features/scapes/data/mock_scapes_repository.dart';
import 'package:flutter_bloc_app/features/scapes/domain/scapes_repository.dart';
import 'package:flutter_bloc_app/features/settings/data/hive_locale_repository.dart';
import 'package:flutter_bloc_app/features/settings/data/hive_theme_repository.dart';
import 'package:flutter_bloc_app/features/settings/data/package_info_app_info_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/locale_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_repository.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/features/websocket/data/echo_websocket_repository.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_repository.dart';
import 'package:flutter_bloc_app/shared/platform/biometric_authenticator.dart';
import 'package:flutter_bloc_app/shared/services/app_image_cache_manager.dart';
import 'package:flutter_bloc_app/shared/services/app_memory_service.dart';
import 'package:flutter_bloc_app/shared/services/error_notification_service.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/storage/shared_preferences_migration_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';

const bool _isFlutterTestProcess = bool.fromEnvironment('FLUTTER_TEST');

Future<void> registerAllDependencies() async {
  _registerAppRuntimeConfig();
  await _registerStorageServices();
  _registerCounterRepository();
  registerAuthServices();
  registerRemoteConfigServices();
  _registerSupabaseConfigServices();
  registerSupabaseServices();
  _registerTimerAndNetworkStatus();
  registerHttpServices();
  registerChartServices();
  registerCalculatorServices();
  registerGraphqlServices();
  registerChatServices();
  registerCaseStudyDemoServices();
  _registerSettingsServices();
  _registerDeepLinkServices();
  _registerWebSocketServices();
  _registerMapServices();
  registerProfileServices();
  registerSearchServices();
  registerTodoServices();
  registerGenUiServices();
  registerWalletConnectAuthServices();
  registerPlaylearnServices();
  registerIgamingDemoServices();
  registerFcmDemoServices();
  registerIotDemoServices();
  registerInAppPurchaseDemoServices();
  _registerMemoryServices();
  _registerCameraGalleryServices();
  _registerScapesServices();
  _registerUtilityServices();
  _registerSyncServices();
}

void _registerAppRuntimeConfig() {
  registerLazySingletonIfAbsent<AppRuntimeConfig>(
    AppRuntimeConfig.fromBootstrap,
  );
}

Future<void> _registerStorageServices() async {
  registerLazySingletonIfAbsent<HiveKeyManager>(HiveKeyManager.new);
  registerLazySingletonIfAbsent<HiveService>(
    () => HiveService(keyManager: getIt<HiveKeyManager>()),
  );
  registerLazySingletonIfAbsent<SharedPreferencesMigrationService>(
    () => SharedPreferencesMigrationService(
      hiveService: getIt<HiveService>(),
    ),
  );
}

void _registerCounterRepository() {
  registerLazySingletonIfAbsent<CounterRepository>(createCounterRepository);
}

void _registerSupabaseConfigServices() {
  registerLazySingletonIfAbsent<SupabaseConfigProvider>(
    () => SupabaseConfigProvider(remoteConfig: getIt<RemoteConfigService>()),
  );
  registerLazySingletonIfAbsent<SupabaseConfigCoordinator>(
    () => SupabaseConfigCoordinator(
      auth: getIt<FirebaseAuth>(),
      provider: getIt<SupabaseConfigProvider>(),
    ),
    dispose: (final coordinator) => coordinator.dispose(),
  );
}

/// `registerHttpServices` builds `Dio` with `NetworkStatusService`; chart setup
/// can eagerly resolve HTTP clients, so network status must exist first.
void _registerTimerAndNetworkStatus() {
  registerLazySingletonIfAbsent<TimerService>(DefaultTimerService.new);
  registerLazySingletonIfAbsent<NetworkStatusService>(
    () => ConnectivityNetworkStatusService(
      timerService: getIt<TimerService>(),
    ),
    dispose: (final service) => service.dispose(),
  );
}

void _registerSettingsServices() {
  registerLazySingletonIfAbsent<LocaleRepository>(
    () => HiveLocaleRepository(hiveService: getIt<HiveService>()),
  );
  registerLazySingletonIfAbsent<ThemeRepository>(
    () => HiveThemeRepository(hiveService: getIt<HiveService>()),
  );
  registerLazySingletonIfAbsent<AppInfoRepository>(
    () => const PackageInfoAppInfoRepository(),
  );
}

void _registerDeepLinkServices() {
  registerLazySingletonIfAbsent<DeepLinkParser>(() => const DeepLinkParser());
  registerLazySingletonIfAbsent<DeepLinkService>(AppLinksDeepLinkService.new);
}

void _registerWebSocketServices() {
  registerLazySingletonIfAbsent<WebsocketRepository>(
    EchoWebsocketRepository.new,
    dispose: (final repository) => repository.dispose(),
  );
}

void _registerMapServices() {
  registerLazySingletonIfAbsent<MapLocationRepository>(
    () => const SampleMapLocationRepository(),
  );
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
            onImageCacheTrim: (final level) async {},
          )
        : AppMemoryService(
            imageCacheManager: getIt<AppImageCacheManager>(),
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
