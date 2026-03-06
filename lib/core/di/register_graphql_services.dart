import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/countries_graphql_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/graphql_demo_cache_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/offline_first_graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_cache_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';

void registerGraphqlServices() {
  registerLazySingletonIfAbsent<GraphqlCacheRepository>(
    () => GraphqlDemoCacheRepository(hiveService: getIt<HiveService>()),
  );

  registerLazySingletonIfAbsent<GraphqlDemoRepository>(
    () => OfflineFirstGraphqlDemoRepository(
      remoteRepository: CountriesGraphqlRepository(client: getIt<Dio>()),
      cacheRepository: getIt<GraphqlCacheRepository>(),
    ),
  );
}
