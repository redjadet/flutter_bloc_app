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
    'shared_preferences_chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/'
    'chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/counter/data/'
    'shared_preferences_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/shared/data/'
    'shared_preferences_locale_repository.dart';
import 'package:flutter_bloc_app/shared/data/'
    'shared_preferences_theme_repository.dart';
import 'package:flutter_bloc_app/shared/domain/locale_repository.dart';
import 'package:flutter_bloc_app/shared/domain/theme_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  _registerLazySingletonIfAbsent<CounterRepository>(
    () => SharedPreferencesCounterRepository(),
  );
  _registerLazySingletonIfAbsent<http.Client>(http.Client.new);
  _registerLazySingletonIfAbsent<HuggingFaceApiClient>(
    () => HuggingFaceApiClient(
      httpClient: getIt<http.Client>(),
      apiKey: SecretConfig.huggingfaceApiKey,
    ),
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
    () => SharedPreferencesChatHistoryRepository(),
  );
  _registerLazySingletonIfAbsent<LocaleRepository>(
    () => SharedPreferencesLocaleRepository(),
  );
  _registerLazySingletonIfAbsent<ThemeRepository>(
    () => SharedPreferencesThemeRepository(),
  );
  _registerLazySingletonIfAbsent<TimerService>(() => DefaultTimerService());
}

void ensureConfigured() {
  configureDependencies();
}

void _registerLazySingletonIfAbsent<T extends Object>(T Function() factory) {
  if (!getIt.isRegistered<T>()) {
    getIt.registerLazySingleton<T>(factory);
  }
}
