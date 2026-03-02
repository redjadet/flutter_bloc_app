import 'dart:async';

import 'package:flutter_bloc_app/core/config/app_runtime_config.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_factories.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/core/di/register_chat_services.dart';
import 'package:flutter_bloc_app/core/di/register_genui_services.dart';
import 'package:flutter_bloc_app/core/di/register_http_services.dart';
import 'package:flutter_bloc_app/core/di/register_igaming_demo_services.dart';
import 'package:flutter_bloc_app/core/di/register_playlearn_services.dart';
import 'package:flutter_bloc_app/core/di/register_profile_services.dart';
import 'package:flutter_bloc_app/core/di/register_remote_config_services.dart';
import 'package:flutter_bloc_app/core/di/register_search_services.dart';
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
import 'package:flutter_bloc_app/features/settings/data/hive_locale_repository.dart';
import 'package:flutter_bloc_app/features/settings/data/hive_theme_repository.dart';
import 'package:flutter_bloc_app/features/settings/data/package_info_app_info_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/locale_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_repository.dart';
import 'package:flutter_bloc_app/features/websocket/data/echo_websocket_repository.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_repository.dart';
import 'package:flutter_bloc_app/shared/platform/biometric_authenticator.dart';
import 'package:flutter_bloc_app/shared/services/error_notification_service.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/storage/shared_preferences_migration_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';

Future<void> registerAllDependencies() async {
  _registerAppRuntimeConfig();
  await _registerStorageServices();
  _registerCounterRepository();
  registerHttpServices();
  registerChatServices();
  _registerSettingsServices();
  _registerDeepLinkServices();
  _registerWebSocketServices();
  _registerMapServices();
  registerProfileServices();
  registerRemoteConfigServices();
  registerSearchServices();
  registerTodoServices();
  registerGenUiServices();
  registerWalletConnectAuthServices();
  registerPlaylearnServices();
  registerIgamingDemoServices();
  _registerCameraGalleryServices();
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

void _registerCameraGalleryServices() {
  registerLazySingletonIfAbsent<CameraGalleryRepository>(
    ImagePickerCameraGalleryRepository.new,
  );
}

void _registerUtilityServices() {
  registerLazySingletonIfAbsent<TimerService>(DefaultTimerService.new);
  registerLazySingletonIfAbsent<BiometricAuthenticator>(
    LocalBiometricAuthenticator.new,
  );
  registerLazySingletonIfAbsent<ErrorNotificationService>(
    SnackbarErrorNotificationService.new,
  );
}

void _registerSyncServices() {
  registerLazySingletonIfAbsent<NetworkStatusService>(
    () => ConnectivityNetworkStatusService(
      timerService: getIt<TimerService>(),
    ),
    dispose: (final service) => service.dispose(),
  );
  registerLazySingletonIfAbsent<SyncableRepositoryRegistry>(
    SyncableRepositoryRegistry.new,
  );
  registerLazySingletonIfAbsent<PendingSyncRepository>(
    () => PendingSyncRepository(hiveService: getIt<HiveService>()),
  );
  registerLazySingletonIfAbsent<BackgroundSyncCoordinator>(
    () => BackgroundSyncCoordinator(
      repository: getIt<PendingSyncRepository>(),
      networkStatusService: getIt<NetworkStatusService>(),
      timerService: getIt<TimerService>(),
      registry: getIt<SyncableRepositoryRegistry>(),
    ),
    dispose: (final coordinator) => coordinator.dispose(),
  );
}
