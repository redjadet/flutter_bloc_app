import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/core/config/app_runtime_config.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/chart/data/api/coingecko_api.dart';
import 'package:flutter_bloc_app/features/chart/data/delayed_chart_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_repository.dart';

void registerChartServices() {
  registerLazySingletonIfAbsent<CoingeckoApi>(
    () => CoingeckoApi(getIt<Dio>()),
  );
  registerLazySingletonIfAbsent<ChartRepository>(
    () => DelayedChartRepository(
      api: getIt<CoingeckoApi>(),
      appRuntimeConfig: getIt<AppRuntimeConfig>(),
    ),
  );
}
