part of '../injector_registrations.dart';

Future<void> registerCoreServices() async {
  _registerAppRuntimeConfig();
  _registerBackendAvailability();
  await _registerStorageServices();
}

void _registerAppRuntimeConfig() {
  registerLazySingletonIfAbsent<AppRuntimeConfig>(
    AppRuntimeConfig.fromBootstrap,
  );
}

void _registerBackendAvailability() {
  if (!getIt.isRegistered<BackendAvailability>()) {
    getIt.registerFactory<BackendAvailability>(
      BackendAvailability.fromBootstrap,
    );
  }
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
