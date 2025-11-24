import 'dart:async';

import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_factories.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/core/di/register_remote_config_services.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/calculator/domain/payment_calculator.dart';
import 'package:flutter_bloc_app/features/chart/data/delayed_chart_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/chat_local_data_source.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_api_client.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_payload_builder.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_response_parser.dart';
import 'package:flutter_bloc_app/features/chat/data/mock_chat_list_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/offline_first_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_list_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/deeplink/data/app_links_deep_link_service.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_parser.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_service.dart';
import 'package:flutter_bloc_app/features/google_maps/data/sample_map_location_repository.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/countries_graphql_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/profile/data/mock_profile_repository.dart';
import 'package:flutter_bloc_app/features/profile/data/offline_first_profile_repository.dart';
import 'package:flutter_bloc_app/features/profile/data/profile_cache_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_repository.dart';
import 'package:flutter_bloc_app/features/search/data/mock_search_repository.dart';
import 'package:flutter_bloc_app/features/search/data/offline_first_search_repository.dart';
import 'package:flutter_bloc_app/features/search/data/search_cache_repository.dart';
import 'package:flutter_bloc_app/features/search/domain/search_repository.dart';
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
import 'package:http/http.dart' as http;

Future<void> registerAllDependencies() async {
  await _registerStorageServices();
  _registerCounterRepository();
  _registerHttpServices();
  _registerChatServices();
  _registerSettingsServices();
  _registerDeepLinkServices();
  _registerWebSocketServices();
  _registerMapServices();
  _registerProfileServices();
  registerRemoteConfigServices();
  _registerSearchServices();
  _registerUtilityServices();
  _registerSyncServices();
}

Future<void> _registerStorageServices() async {
  registerLazySingletonIfAbsent<HiveKeyManager>(HiveKeyManager.new);
  registerLazySingletonIfAbsent<HiveService>(
    () => HiveService(keyManager: getIt<HiveKeyManager>()),
  );
  await getIt<HiveService>().initialize();
  registerLazySingletonIfAbsent<SharedPreferencesMigrationService>(
    () => SharedPreferencesMigrationService(
      hiveService: getIt<HiveService>(),
    ),
  );
}

void _registerCounterRepository() {
  registerLazySingletonIfAbsent<CounterRepository>(createCounterRepository);
}

void _registerHttpServices() {
  registerLazySingletonIfAbsent<http.Client>(
    http.Client.new,
    dispose: (final client) => client.close(),
  );
  registerLazySingletonIfAbsent<ChartRepository>(
    () => DelayedChartRepository(client: getIt<http.Client>()),
  );
  registerLazySingletonIfAbsent<PaymentCalculator>(PaymentCalculator.new);
  registerLazySingletonIfAbsent<GraphqlDemoRepository>(
    () => CountriesGraphqlRepository(client: getIt<http.Client>()),
  );
}

void _registerChatServices() {
  registerLazySingletonIfAbsent<HuggingFaceApiClient>(
    () => HuggingFaceApiClient(
      httpClient: getIt<http.Client>(),
      apiKey: SecretConfig.huggingfaceApiKey,
    ),
    dispose: (final client) => client.dispose(),
  );
  registerLazySingletonIfAbsent<HuggingFacePayloadBuilder>(
    () => const HuggingFacePayloadBuilder(),
  );
  registerLazySingletonIfAbsent<HuggingFaceResponseParser>(
    () => const HuggingFaceResponseParser(
      fallbackMessage: HuggingfaceChatRepository.fallbackMessage,
    ),
  );
  registerLazySingletonIfAbsent<HuggingfaceChatRepository>(
    () => HuggingfaceChatRepository(
      apiClient: getIt<HuggingFaceApiClient>(),
      payloadBuilder: getIt<HuggingFacePayloadBuilder>(),
      responseParser: getIt<HuggingFaceResponseParser>(),
      model: SecretConfig.huggingfaceModel,
      useChatCompletions: SecretConfig.useChatCompletions,
    ),
  );
  registerLazySingletonIfAbsent<ChatHistoryRepository>(
    () => ChatLocalDataSource(hiveService: getIt<HiveService>()),
  );
  registerLazySingletonIfAbsent<ChatRepository>(
    () => OfflineFirstChatRepository(
      remoteRepository: getIt<HuggingfaceChatRepository>(),
      localDataSource: getIt<ChatHistoryRepository>(),
      pendingSyncRepository: getIt<PendingSyncRepository>(),
      registry: getIt<SyncableRepositoryRegistry>(),
    ),
  );
  registerLazySingletonIfAbsent<ChatListRepository>(
    MockChatListRepository.new,
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

void _registerProfileServices() {
  registerLazySingletonIfAbsent<ProfileCacheRepository>(
    () => ProfileCacheRepository(hiveService: getIt<HiveService>()),
  );
  registerLazySingletonIfAbsent<ProfileRepository>(
    () => OfflineFirstProfileRepository(
      remoteRepository: const MockProfileRepository(),
      cacheRepository: getIt<ProfileCacheRepository>(),
      networkStatusService: getIt<NetworkStatusService>(),
      registry: getIt<SyncableRepositoryRegistry>(),
    ),
  );
}

void _registerSearchServices() {
  registerLazySingletonIfAbsent<SearchCacheRepository>(
    () => SearchCacheRepository(hiveService: getIt<HiveService>()),
  );
  registerLazySingletonIfAbsent<SearchRepository>(
    () => OfflineFirstSearchRepository(
      remoteRepository: MockSearchRepository(),
      cacheRepository: getIt<SearchCacheRepository>(),
      networkStatusService: getIt<NetworkStatusService>(),
      registry: getIt<SyncableRepositoryRegistry>(),
    ),
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
    ConnectivityNetworkStatusService.new,
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
