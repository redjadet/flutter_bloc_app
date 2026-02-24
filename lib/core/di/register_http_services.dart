import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/core/config/app_runtime_config.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/calculator/domain/payment_calculator.dart';
import 'package:flutter_bloc_app/features/chart/data/delayed_chart_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/countries_graphql_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/graphql_demo_cache_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/offline_first_graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_cache_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';
import 'package:flutter_bloc_app/main_bootstrap.dart';
import 'package:flutter_bloc_app/shared/http/resilient_http_client.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/services/retry_notification_service.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:http/http.dart' as http;

void registerHttpServices() {
  registerLazySingletonIfAbsent<http.Client>(
    http.Client.new,
    dispose: (final client) => client.close(),
  );

  registerLazySingletonIfAbsent<RetryNotificationService>(
    InMemoryRetryNotificationService.new,
    dispose: (final service) => service.dispose(),
  );

  registerLazySingletonIfAbsent<ResilientHttpClient>(
    () => ResilientHttpClient(
      innerClient: getIt<http.Client>(),
      networkStatusService: getIt<NetworkStatusService>(),
      userAgent: 'FlutterBlocApp/${getAppVersion()}',
      firebaseAuth: getIt.isRegistered<FirebaseAuth>()
          ? getIt<FirebaseAuth>()
          : null,
      retryNotificationService: getIt<RetryNotificationService>(),
    ),
    dispose: (final client) => client.close(),
  );

  registerLazySingletonIfAbsent<ChartRepository>(
    () => DelayedChartRepository(
      client: getIt<ResilientHttpClient>(),
      appRuntimeConfig: getIt<AppRuntimeConfig>(),
    ),
  );

  registerLazySingletonIfAbsent<PaymentCalculator>(PaymentCalculator.new);

  registerLazySingletonIfAbsent<GraphqlCacheRepository>(
    () => GraphqlDemoCacheRepository(hiveService: getIt<HiveService>()),
  );

  registerLazySingletonIfAbsent<GraphqlDemoRepository>(
    () => OfflineFirstGraphqlDemoRepository(
      remoteRepository: CountriesGraphqlRepository(
        client: getIt<ResilientHttpClient>(),
      ),
      cacheRepository: getIt<GraphqlCacheRepository>(),
    ),
  );
}
