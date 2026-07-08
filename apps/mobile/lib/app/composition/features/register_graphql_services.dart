import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/app/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/app/diagnostics/graphql_cache_clear_port.dart';
import 'package:flutter_bloc_app/app/http/supabase/supabase_session_manager.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/auth_aware_graphql_remote_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/countries_graphql_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/graphql_cache_clear_port_adapter.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/graphql_demo_cache_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/offline_first_graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/supabase_graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_cache_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:storage/storage.dart';

void registerGraphqlServices() {
  registerLazySingletonIfAbsent<GraphqlCacheRepository>(
    () => GraphqlDemoCacheRepository(hiveService: getIt<HiveService>()),
  );
  registerLazySingletonIfAbsent<GraphqlCacheClearPort>(
    () => GraphqlCacheClearPortAdapter(getIt<GraphqlCacheRepository>()),
  );

  registerLazySingletonIfAbsent<GraphqlDemoRepository>(
    () => OfflineFirstGraphqlDemoRepository(
      remoteRepository: AuthAwareGraphqlRemoteRepository(
        supabaseRemote: SupabaseGraphqlDemoRepository(
          readAccessToken: () =>
              getIt<SupabaseSessionManager>().getAccessToken(),
        ),
        directRemote: CountriesGraphqlRepository(client: getIt<Dio>()),
        isSupabaseSignedIn: () =>
            SupabaseBootstrapService.isSupabaseInitialized &&
            getIt<SupabaseAuthRepository>().currentUser != null,
      ),
      cacheRepository: getIt<GraphqlCacheRepository>(),
    ),
  );
}
