import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/shared_prefs_chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/counter/data/shared_prefs_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/shared/data/shared_prefs_locale_repository.dart';
import 'package:flutter_bloc_app/shared/data/shared_prefs_theme_repository.dart';
import 'package:flutter_bloc_app/shared/domain/locale_repository.dart';
import 'package:flutter_bloc_app/shared/domain/theme_repository.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Repositories (lazy singletons)
  getIt.registerLazySingleton<CounterRepository>(
    () => SharedPreferencesCounterRepository(),
  );
  getIt.registerLazySingleton<ChatRepository>(
    () => HuggingfaceChatRepository(
      apiKey: SecretConfig.huggingfaceApiKey,
      model: SecretConfig.huggingfaceModel,
      useChatCompletions: SecretConfig.useChatCompletions,
    ),
  );
  getIt.registerLazySingleton<ChatHistoryRepository>(
    () => SharedPrefsChatHistoryRepository(),
  );
  getIt.registerLazySingleton<LocaleRepository>(
    () => SharedPreferencesLocaleRepository(),
  );
  getIt.registerLazySingleton<ThemeRepository>(
    () => SharedPreferencesThemeRepository(),
  );
  getIt.registerLazySingleton<TimerService>(() => DefaultTimerService());
}

void ensureConfigured() {
  if (!getIt.isRegistered<CounterRepository>()) {
    getIt.registerLazySingleton<CounterRepository>(
      () => SharedPreferencesCounterRepository(),
    );
  }
  if (!getIt.isRegistered<ChatRepository>()) {
    getIt.registerLazySingleton<ChatRepository>(
      () => HuggingfaceChatRepository(
        apiKey: SecretConfig.huggingfaceApiKey,
        model: SecretConfig.huggingfaceModel,
        useChatCompletions: SecretConfig.useChatCompletions,
      ),
    );
  }
  if (!getIt.isRegistered<ChatHistoryRepository>()) {
    getIt.registerLazySingleton<ChatHistoryRepository>(
      () => SharedPrefsChatHistoryRepository(),
    );
  }
  if (!getIt.isRegistered<LocaleRepository>()) {
    getIt.registerLazySingleton<LocaleRepository>(
      () => SharedPreferencesLocaleRepository(),
    );
  }
  if (!getIt.isRegistered<ThemeRepository>()) {
    getIt.registerLazySingleton<ThemeRepository>(
      () => SharedPreferencesThemeRepository(),
    );
  }
  if (!getIt.isRegistered<TimerService>()) {
    getIt.registerLazySingleton<TimerService>(() => DefaultTimerService());
  }
}
