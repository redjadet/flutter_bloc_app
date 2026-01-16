import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/profile/data/mock_profile_repository.dart';
import 'package:flutter_bloc_app/features/profile/data/offline_first_profile_repository.dart';
import 'package:flutter_bloc_app/features/profile/data/profile_cache_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_cache_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_repository.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';

/// Registers all profile-related services and repositories.
void registerProfileServices() {
  registerLazySingletonIfAbsent<ProfileCacheRepository>(
    () => HiveProfileCacheRepository(hiveService: getIt<HiveService>()),
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
