import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/features/search/data/hive_search_cache_repository.dart';
import 'package:flutter_bloc_app/features/search/data/mock_search_repository.dart';
import 'package:flutter_bloc_app/features/search/data/offline_first_search_repository.dart';
import 'package:flutter_bloc_app/features/search/domain/search_cache_repository.dart';
import 'package:flutter_bloc_app/features/search/domain/search_repository.dart';
import 'package:networking/networking.dart';
import 'package:storage/storage.dart';

/// Registers all search-related services and repositories.
void registerSearchServices() {
  registerLazySingletonIfAbsent<SearchCacheRepository>(
    () => HiveSearchCacheRepository(hiveService: getIt<HiveService>()),
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
