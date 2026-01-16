import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/search/data/mock_search_repository.dart';
import 'package:flutter_bloc_app/features/search/data/offline_first_search_repository.dart';
import 'package:flutter_bloc_app/features/search/data/search_cache_repository.dart';
import 'package:flutter_bloc_app/features/search/domain/search_repository.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';

/// Registers all search-related services and repositories.
void registerSearchServices() {
  registerLazySingletonIfAbsent<SearchCacheRepository>(
    () => SearchCacheRepository(hiveService: getIt<HiveService>()),
  );
  registerLazySingletonIfAbsent<SearchRepository>(
    () => OfflineFirstSearchRepository(
      remoteRepository: MockSearchRepository(),
      cacheRepository: getIt<SearchCacheRepository>(),
      networkStatusService: getIt<NetworkStatusService>(),
      registry: getIt<SyncableRepositoryRegistry>(),
    ),
  );
}
