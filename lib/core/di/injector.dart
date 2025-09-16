import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/counter/data/shared_prefs_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/shared/data/shared_prefs_theme_repository.dart';
import 'package:flutter_bloc_app/shared/domain/theme_repository.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Repositories (lazy singletons)
  getIt.registerLazySingleton<CounterRepository>(
    () => SharedPreferencesCounterRepository(),
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
  if (!getIt.isRegistered<ThemeRepository>()) {
    getIt.registerLazySingleton<ThemeRepository>(
      () => SharedPreferencesThemeRepository(),
    );
  }
  if (!getIt.isRegistered<TimerService>()) {
    getIt.registerLazySingleton<TimerService>(() => DefaultTimerService());
  }
}
