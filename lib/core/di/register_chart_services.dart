import 'package:flutter_bloc_app/core/config/app_runtime_config.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/chart/data/delayed_chart_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_repository.dart';
import 'package:flutter_bloc_app/shared/http/resilient_http_client.dart';

void registerChartServices() {
  registerLazySingletonIfAbsent<ChartRepository>(
    () => DelayedChartRepository(
      client: getIt<ResilientHttpClient>(),
      appRuntimeConfig: getIt<AppRuntimeConfig>(),
    ),
  );
}
