import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_factories.dart';
import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_remote_data_source.dart';
import 'package:flutter_bloc_app/shared/services/app_memory_service.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/storage/shared_preferences_migration_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/test_helpers_shared.dart';

export '../test/test_helpers_shared.dart'
    show
        FakeBackgroundSyncCoordinator,
        FakeNetworkStatusService,
        FakePendingSyncRepository,
        InMemoryRepository,
        MockCounterRepository,
        TestSetupOptions,
        installMockFirebasePlatformForTests,
        mockFirebaseOptions,
        resetFirebaseTestDelegate,
        waitForCounterCubitsToLoad;

Future<void> ensureFirebaseInitializedForTests() async {
  final String platformType = FirebasePlatform.instance.runtimeType.toString();
  if (platformType.contains('MethodChannelFirebase')) {
    installMockFirebasePlatformForTests();
  }

  if (Firebase.apps.isNotEmpty) {
    return;
  }

  await Firebase.initializeApp(options: mockFirebaseOptions);
}

Future<void> setupHiveForTesting() async {
  try {
    await Hive.initFlutter();
  } on Object catch (_) {
    // Repeated web init is fine; HiveService will verify storage when used.
  }
}

Future<void> setupTestDependencies([
  TestSetupOptions options = const TestSetupOptions(),
]) async {
  SharedPreferences.setMockInitialValues(
    options.initialSharedPreferencesValues ?? <String, Object>{},
  );
  if (options.useMockFirebasePlatform) {
    await ensureFirebaseInitializedForTests();
  }
  if (options.setFlavorToProd) {
    FlavorManager.current = Flavor.prod;
  }
  await getIt.reset();

  if (options.useMockFirebaseAuth) {
    getIt.registerSingleton<FirebaseAuth>(MockFirebaseAuth());
  }

  await configureDependencies();

  if (!options.useMockFirebaseAuth) {
    if (!getIt.isRegistered<FirebaseAuth>()) {
      getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
    }
  }

  await overrideNetworkAndSync();
  await overrideRemoteConfigRepositoryForWebSmoke();
  await overrideMemoryServicesForTests();
  if (options.overrideCounterRepository) {
    await overrideCounterRepository();
  }
  await getIt<SharedPreferencesMigrationService>().migrateIfNeeded();
}

Future<void> tearDownTestDependencies() async {
  await getIt.reset();
}

Future<void> overrideCounterRepository() async {
  if (getIt.isRegistered<CounterRepository>()) {
    await getIt.unregister<CounterRepository>();
  }
  getIt.registerSingleton<CounterRepository>(MockCounterRepository());
}

Future<void> overrideNetworkAndSync() async {
  if (getIt.isRegistered<BackgroundSyncCoordinator>()) {
    getIt.unregister<BackgroundSyncCoordinator>();
  }
  if (getIt.isRegistered<PendingSyncRepository>()) {
    getIt.unregister<PendingSyncRepository>();
  }
  if (getIt.isRegistered<NetworkStatusService>()) {
    getIt.unregister<NetworkStatusService>();
  }

  getIt
    ..registerLazySingleton<NetworkStatusService>(
      FakeNetworkStatusService.new,
    )
    ..registerLazySingleton<BackgroundSyncCoordinator>(
      FakeBackgroundSyncCoordinator.new,
    )
    ..registerLazySingleton<PendingSyncRepository>(
      FakePendingSyncRepository.new,
    );
}

Future<void> overrideMemoryServicesForTests() async {
  if (getIt.isRegistered<AppMemoryService>()) {
    await getIt.unregister<AppMemoryService>();
  }

  getIt.registerLazySingleton<AppMemoryService>(
    () => AppMemoryService(onImageCacheTrim: (final level) async {}),
  );
}

/// Web integration smoke uses fake Firebase bootstrap options, so the real
/// Remote Config client would try to contact Firebase Installations with
/// invalid credentials. Keep the browser lane offline and deterministic.
Future<void> overrideRemoteConfigRepositoryForWebSmoke() async {
  if (getIt.isRegistered<RemoteConfigRemoteDataSource>()) {
    await getIt.unregister<RemoteConfigRemoteDataSource>();
  }
  getIt.registerLazySingleton<RemoteConfigRemoteDataSource>(
    FakeRemoteConfigRemoteDataSource.new,
  );
}
