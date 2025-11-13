import 'dart:async';

import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_factories.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/calculator/domain/payment_calculator.dart';
import 'package:flutter_bloc_app/features/chart/data/delayed_chart_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_api_client.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_payload_builder.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_response_parser.dart';
import 'package:flutter_bloc_app/features/chat/data/mock_chat_list_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/secure_chat_history_repository.dart';
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
import 'package:flutter_bloc_app/features/profile/domain/profile_repository.dart';
import 'package:flutter_bloc_app/features/remote_config/data/repositories/remote_config_repository.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_service.dart';
import 'package:flutter_bloc_app/features/remote_config/presentation/cubit/remote_config_cubit.dart';
import 'package:flutter_bloc_app/features/search/data/mock_search_repository.dart';
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
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/storage/shared_preferences_migration_service.dart';
import 'package:http/http.dart' as http;

/// Registers all application dependencies.
///
/// This function is called from `configureDependencies()` and organizes
/// registrations by category for better maintainability.
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
  _registerRemoteConfigServices();
  _registerSearchServices();
  _registerUtilityServices();
}

/// Registers storage-related services (Hive, migration).
Future<void> _registerStorageServices() async {
  // Register Hive services first (foundational storage layer)
  // These are singletons because they manage shared database connections and encryption keys
  registerLazySingletonIfAbsent<HiveKeyManager>(HiveKeyManager.new);
  registerLazySingletonIfAbsent<HiveService>(
    () => HiveService(keyManager: getIt<HiveKeyManager>()),
  );
  // Initialize Hive - handle initialization failures gracefully
  await getIt<HiveService>().initialize();
  registerLazySingletonIfAbsent<SharedPreferencesMigrationService>(
    () => SharedPreferencesMigrationService(
      hiveService: getIt<HiveService>(),
    ),
  );
}

/// Registers counter repository.
void _registerCounterRepository() {
  // Counter repository - singleton because it manages shared counter state
  // Uses factory function to conditionally create Firebase or Hive implementation
  registerLazySingletonIfAbsent<CounterRepository>(createCounterRepository);
}

/// Registers HTTP-related services.
void _registerHttpServices() {
  // HTTP client - singleton to reuse connections across all network requests
  // Dispose callback closes connections when app shuts down
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

/// Registers chat-related services.
void _registerChatServices() {
  // HuggingFace API client - singleton to reuse HTTP client and API key
  // Dispose callback cleans up internal resources (e.g., request interceptors)
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
  registerLazySingletonIfAbsent<ChatRepository>(
    () => HuggingfaceChatRepository(
      apiClient: getIt<HuggingFaceApiClient>(),
      payloadBuilder: getIt<HuggingFacePayloadBuilder>(),
      responseParser: getIt<HuggingFaceResponseParser>(),
      model: SecretConfig.huggingfaceModel,
      useChatCompletions: SecretConfig.useChatCompletions,
    ),
  );
  registerLazySingletonIfAbsent<ChatHistoryRepository>(
    SecureChatHistoryRepository.new,
  );
  registerLazySingletonIfAbsent<ChatListRepository>(
    MockChatListRepository.new,
  );
}

/// Registers settings-related services.
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

/// Registers deep link services.
void _registerDeepLinkServices() {
  registerLazySingletonIfAbsent<DeepLinkParser>(() => const DeepLinkParser());
  registerLazySingletonIfAbsent<DeepLinkService>(AppLinksDeepLinkService.new);
}

/// Registers WebSocket services.
void _registerWebSocketServices() {
  // WebSocket repository - singleton to maintain single WebSocket connection
  // Dispose callback closes WebSocket connection and cancels subscriptions
  registerLazySingletonIfAbsent<WebsocketRepository>(
    EchoWebsocketRepository.new,
    dispose: (final repository) => repository.dispose(),
  );
}

/// Registers map services.
void _registerMapServices() {
  registerLazySingletonIfAbsent<MapLocationRepository>(
    () => const SampleMapLocationRepository(),
  );
}

/// Registers profile services.
void _registerProfileServices() {
  registerLazySingletonIfAbsent<ProfileRepository>(
    MockProfileRepository.new,
  );
}

/// Registers remote config services.
void _registerRemoteConfigServices() {
  // Remote config repository - singleton to maintain single config subscription
  // Dispose callback cancels Firebase Remote Config update subscriptions
  registerLazySingletonIfAbsent<RemoteConfigRepository>(
    createRemoteConfigRepository,
    dispose: (final repository) => repository.dispose(),
  );
  registerLazySingletonIfAbsent<RemoteConfigService>(
    () => getIt<RemoteConfigRepository>(),
  );
  registerLazySingletonIfAbsent<RemoteConfigCubit>(
    () => RemoteConfigCubit(getIt<RemoteConfigService>()),
  );
}

/// Registers search services.
void _registerSearchServices() {
  registerLazySingletonIfAbsent<SearchRepository>(MockSearchRepository.new);
}

/// Registers utility services.
void _registerUtilityServices() {
  registerLazySingletonIfAbsent<TimerService>(DefaultTimerService.new);
  registerLazySingletonIfAbsent<BiometricAuthenticator>(
    LocalBiometricAuthenticator.new,
  );
  registerLazySingletonIfAbsent<ErrorNotificationService>(
    SnackbarErrorNotificationService.new,
  );
}
