import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
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
import 'package:flutter_bloc_app/features/counter/data/hive_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/data/realtime_database_counter_repository.dart';
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
import 'package:flutter_bloc_app/shared/utils/initialization_guard.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Register Hive services first
  _registerLazySingletonIfAbsent<HiveKeyManager>(HiveKeyManager.new);
  _registerLazySingletonIfAbsent<HiveService>(
    () => HiveService(keyManager: getIt<HiveKeyManager>()),
  );
  // Initialize Hive - handle initialization failures gracefully
  await InitializationGuard.executeSafely(
    () => getIt<HiveService>().initialize(),
    context: 'configureDependencies',
    failureMessage:
        'Failed to initialize Hive during dependency configuration. '
        'App may not function correctly without storage.',
  );
  _registerLazySingletonIfAbsent<SharedPreferencesMigrationService>(
    () => SharedPreferencesMigrationService(
      hiveService: getIt<HiveService>(),
    ),
  );

  _registerLazySingletonIfAbsent<CounterRepository>(_createCounterRepository);
  _registerLazySingletonIfAbsent<http.Client>(
    http.Client.new,
    dispose: (final client) => client.close(),
  );
  _registerLazySingletonIfAbsent<ChartRepository>(
    () => DelayedChartRepository(client: getIt<http.Client>()),
  );
  _registerLazySingletonIfAbsent<PaymentCalculator>(PaymentCalculator.new);
  _registerLazySingletonIfAbsent<GraphqlDemoRepository>(
    () => CountriesGraphqlRepository(client: getIt<http.Client>()),
  );
  _registerLazySingletonIfAbsent<HuggingFaceApiClient>(
    () => HuggingFaceApiClient(
      httpClient: getIt<http.Client>(),
      apiKey: SecretConfig.huggingfaceApiKey,
    ),
    dispose: (final client) => client.dispose(),
  );
  _registerLazySingletonIfAbsent<HuggingFacePayloadBuilder>(
    () => const HuggingFacePayloadBuilder(),
  );
  _registerLazySingletonIfAbsent<HuggingFaceResponseParser>(
    () => const HuggingFaceResponseParser(
      fallbackMessage: HuggingfaceChatRepository.fallbackMessage,
    ),
  );
  _registerLazySingletonIfAbsent<ChatRepository>(
    () => HuggingfaceChatRepository(
      apiClient: getIt<HuggingFaceApiClient>(),
      payloadBuilder: getIt<HuggingFacePayloadBuilder>(),
      responseParser: getIt<HuggingFaceResponseParser>(),
      model: SecretConfig.huggingfaceModel,
      useChatCompletions: SecretConfig.useChatCompletions,
    ),
  );
  _registerLazySingletonIfAbsent<ChatHistoryRepository>(
    SecureChatHistoryRepository.new,
  );
  _registerLazySingletonIfAbsent<ChatListRepository>(
    MockChatListRepository.new,
  );
  _registerLazySingletonIfAbsent<LocaleRepository>(
    () => HiveLocaleRepository(hiveService: getIt<HiveService>()),
  );
  _registerLazySingletonIfAbsent<ThemeRepository>(
    () => HiveThemeRepository(hiveService: getIt<HiveService>()),
  );
  _registerLazySingletonIfAbsent<DeepLinkParser>(() => const DeepLinkParser());
  _registerLazySingletonIfAbsent<DeepLinkService>(AppLinksDeepLinkService.new);
  _registerLazySingletonIfAbsent<AppInfoRepository>(
    () => const PackageInfoAppInfoRepository(),
  );
  _registerLazySingletonIfAbsent<TimerService>(DefaultTimerService.new);
  _registerLazySingletonIfAbsent<BiometricAuthenticator>(
    LocalBiometricAuthenticator.new,
  );
  _registerLazySingletonIfAbsent<WebsocketRepository>(
    EchoWebsocketRepository.new,
    dispose: (final repository) => repository.dispose(),
  );
  _registerLazySingletonIfAbsent<MapLocationRepository>(
    () => const SampleMapLocationRepository(),
  );
  _registerLazySingletonIfAbsent<ProfileRepository>(
    MockProfileRepository.new,
  );
  _registerLazySingletonIfAbsent<ErrorNotificationService>(
    SnackbarErrorNotificationService.new,
  );
  _registerLazySingletonIfAbsent<RemoteConfigRepository>(
    _createRemoteConfigRepository,
    dispose: (final repository) => repository.dispose(),
  );
  _registerLazySingletonIfAbsent<RemoteConfigService>(
    () => getIt<RemoteConfigRepository>(),
  );
  _registerLazySingletonIfAbsent<RemoteConfigCubit>(
    () => RemoteConfigCubit(getIt<RemoteConfigService>()),
  );
  _registerLazySingletonIfAbsent<SearchRepository>(MockSearchRepository.new);
}

void ensureConfigured() {
  unawaited(configureDependencies());
}

CounterRepository _createCounterRepository() {
  if (Firebase.apps.isNotEmpty) {
    // coverage:ignore-start
    try {
      final FirebaseApp app = Firebase.app();
      final FirebaseDatabase database = FirebaseDatabase.instanceFor(app: app)
        ..setPersistenceEnabled(true);
      final FirebaseAuth auth = FirebaseAuth.instanceFor(app: app);
      return RealtimeDatabaseCounterRepository(database: database, auth: auth);
    } on FirebaseException catch (error, stackTrace) {
      AppLogger.error(
        'Falling back to HiveCounterRepository',
        error,
        stackTrace,
      );
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'Falling back to HiveCounterRepository',
        error,
        stackTrace,
      );
    }
    // coverage:ignore-end
  }
  return HiveCounterRepository(hiveService: getIt<HiveService>());
}

RemoteConfigRepository _createRemoteConfigRepository() {
  try {
    // Try to create with Firebase if available
    return RemoteConfigRepository(FirebaseRemoteConfig.instance);
  } on Exception {
    // If Firebase is not available (e.g., in tests), create a fake implementation
    return _FakeRemoteConfigRepository();
  }
}

class _FakeRemoteConfigRepository implements RemoteConfigRepository {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> forceFetch() async {}

  @override
  String getString(final String key) => '';

  @override
  bool getBool(final String key) => false;

  @override
  int getInt(final String key) => 0;

  @override
  double getDouble(final String key) => 0;

  @override
  Future<void> dispose() async {}
}

void _registerLazySingletonIfAbsent<T extends Object>(
  final T Function() factory, {
  final FutureOr<void> Function(T instance)? dispose,
}) {
  if (!getIt.isRegistered<T>()) {
    getIt.registerLazySingleton<T>(factory, dispose: dispose);
  }
}
