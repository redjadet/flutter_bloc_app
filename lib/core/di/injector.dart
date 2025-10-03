import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/chat/data/'
    'huggingface_api_client.dart';
import 'package:flutter_bloc_app/features/chat/data/'
    'huggingface_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/'
    'huggingface_payload_builder.dart';
import 'package:flutter_bloc_app/features/chat/data/'
    'huggingface_response_parser.dart';
import 'package:flutter_bloc_app/features/chat/data/'
    'secure_chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/'
    'chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/counter/data/'
    'realtime_database_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/data/'
    'shared_preferences_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/'
    'countries_graphql_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/'
    'graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/settings/data/'
    'shared_preferences_locale_repository.dart';
import 'package:flutter_bloc_app/features/settings/data/'
    'shared_preferences_theme_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/locale_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_repository.dart';
import 'package:flutter_bloc_app/shared/platform/biometric_authenticator.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  _registerLazySingletonIfAbsent<CounterRepository>(_createCounterRepository);
  _registerLazySingletonIfAbsent<http.Client>(
    http.Client.new,
    dispose: (client) => client.close(),
  );
  _registerLazySingletonIfAbsent<GraphqlDemoRepository>(
    () => CountriesGraphqlRepository(client: getIt<http.Client>()),
  );
  _registerLazySingletonIfAbsent<HuggingFaceApiClient>(
    () => HuggingFaceApiClient(
      httpClient: getIt<http.Client>(),
      apiKey: SecretConfig.huggingfaceApiKey,
    ),
    dispose: (client) => client.dispose(),
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
    () => SecureChatHistoryRepository(),
  );
  _registerLazySingletonIfAbsent<LocaleRepository>(
    () => SharedPreferencesLocaleRepository(),
  );
  _registerLazySingletonIfAbsent<ThemeRepository>(
    () => SharedPreferencesThemeRepository(),
  );
  _registerLazySingletonIfAbsent<TimerService>(() => DefaultTimerService());
  _registerLazySingletonIfAbsent<BiometricAuthenticator>(
    () => LocalBiometricAuthenticator(),
  );
}

void ensureConfigured() {
  configureDependencies();
}

CounterRepository _createCounterRepository() {
  if (Firebase.apps.isNotEmpty) {
    try {
      final FirebaseApp app = Firebase.app();
      final FirebaseDatabase database = FirebaseDatabase.instanceFor(app: app);
      database.setPersistenceEnabled(true);
      final FirebaseAuth auth = FirebaseAuth.instanceFor(app: app);
      return RealtimeDatabaseCounterRepository(database: database, auth: auth);
    } catch (error, stackTrace) {
      AppLogger.error(
        'Falling back to SharedPreferencesCounterRepository',
        error,
        stackTrace,
      );
    }
  }
  return SharedPreferencesCounterRepository();
}

void _registerLazySingletonIfAbsent<T extends Object>(
  T Function() factory, {
  void Function(T instance)? dispose,
}) {
  if (!getIt.isRegistered<T>()) {
    getIt.registerLazySingleton<T>(factory, dispose: dispose);
  }
}
