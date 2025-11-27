import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_factories.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/remote_config/data/offline_first_remote_config_repository.dart';
import 'package:flutter_bloc_app/features/remote_config/data/remote_config_cache_repository.dart';
import 'package:flutter_bloc_app/features/remote_config/data/repositories/remote_config_repository.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_service.dart';
import 'package:flutter_bloc_app/features/remote_config/presentation/cubit/remote_config_cubit.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';

void registerRemoteConfigServices() {
  registerLazySingletonIfAbsent<RemoteConfigRepository>(
    createRemoteConfigRepository,
    dispose: (final repository) => repository.dispose(),
  );
  registerLazySingletonIfAbsent<RemoteConfigCacheRepository>(
    () => RemoteConfigCacheRepository(hiveService: getIt<HiveService>()),
  );
  registerLazySingletonIfAbsent<RemoteConfigService>(
    () => OfflineFirstRemoteConfigRepository(
      remoteRepository: getIt<RemoteConfigRepository>(),
      cacheRepository: getIt<RemoteConfigCacheRepository>(),
      networkStatusService: getIt<NetworkStatusService>(),
      registry: getIt<SyncableRepositoryRegistry>(),
    ),
  );
  registerLazySingletonIfAbsent<RemoteConfigCubit>(
    () => RemoteConfigCubit(getIt<RemoteConfigService>()),
  );
}
