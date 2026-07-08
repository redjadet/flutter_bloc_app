import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/app/diagnostics/profile_cache_controls_port.dart';
import 'package:flutter_bloc_app/features/profile/data/mock_profile_repository.dart';
import 'package:flutter_bloc_app/features/profile/data/offline_first_profile_repository.dart';
import 'package:flutter_bloc_app/features/profile/data/profile_cache_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_cache_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_repository.dart';
import 'package:networking/networking.dart';
import 'package:storage/storage.dart';

/// Registers all profile-related services and repositories.
void registerProfileServices() {
  registerLazySingletonIfAbsent<ProfileCacheRepository>(
    () => HiveProfileCacheRepository(hiveService: getIt<HiveService>()),
  );
  registerLazySingletonIfAbsent<ProfileCacheControlsPort>(
    () => getIt<ProfileCacheRepository>(),
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
