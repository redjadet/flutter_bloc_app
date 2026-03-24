import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/core/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/chart/data/api/coingecko_api.dart';
import 'package:flutter_bloc_app/features/chart/data/auth_aware_chart_remote_repository.dart';
import 'package:flutter_bloc_app/features/chart/data/chart_demo_cache_repository.dart';
import 'package:flutter_bloc_app/features/chart/data/direct_chart_remote_repository.dart';
import 'package:flutter_bloc_app/features/chart/data/firebase_chart_repository.dart';
import 'package:flutter_bloc_app/features/chart/data/offline_first_chart_repository.dart';
import 'package:flutter_bloc_app/features/chart/data/supabase_chart_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_cache_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_remote_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_repository.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';

void registerChartServices() {
  registerLazySingletonIfAbsent<CoingeckoApi>(
    () => CoingeckoApi(getIt<Dio>()),
  );
  registerLazySingletonIfAbsent<ChartCacheRepository>(
    () => ChartDemoCacheRepository(hiveService: getIt<HiveService>()),
  );
  if (!getIt.isRegistered<ChartRemoteRepository>(
    instanceName: 'directChartRemote',
  )) {
    getIt.registerLazySingleton<ChartRemoteRepository>(
      () => DirectChartRemoteRepository(api: getIt<CoingeckoApi>()),
      instanceName: 'directChartRemote',
    );
  }
  final ChartRemoteRepository directChartRemote = getIt<ChartRemoteRepository>(
    instanceName: 'directChartRemote',
  );
  registerLazySingletonIfAbsent<SupabaseChartRepository>(
    () => SupabaseChartRepository(liveDirectFallback: directChartRemote),
  );
  registerLazySingletonIfAbsent<FirebaseChartRepository>(
    () => FirebaseChartRepository(liveDirectFallback: directChartRemote),
  );
  registerLazySingletonIfAbsent<ChartRemoteRepository>(
    () => AuthAwareChartRemoteRepository(
      supabaseRemote: getIt<SupabaseChartRepository>(),
      firebaseRemote: getIt<FirebaseChartRepository>(),
      directRemote: getIt<ChartRemoteRepository>(
        instanceName: 'directChartRemote',
      ),
      isSupabaseSignedIn: () =>
          SupabaseBootstrapService.isSupabaseInitialized &&
          getIt<SupabaseAuthRepository>().currentUser != null,
      isFirebaseSignedIn: () =>
          getIt<FirebaseChartRepository>().hasSignedInUser,
    ),
  );
  registerLazySingletonIfAbsent<ChartRepository>(
    () => OfflineFirstChartRepository(
      remoteRepository: getIt<ChartRemoteRepository>(),
      cacheRepository: getIt<ChartCacheRepository>(),
    ),
  );
}
