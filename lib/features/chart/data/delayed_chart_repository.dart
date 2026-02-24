import 'dart:async';

import 'package:flutter_bloc_app/core/config/app_runtime_config.dart';
import 'package:flutter_bloc_app/features/chart/data/http_chart_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';

class DelayedChartRepository extends HttpChartRepository {
  DelayedChartRepository({
    super.client,
    super.now,
    final AppRuntimeConfig? appRuntimeConfig,
  }) : _config = appRuntimeConfig ?? AppRuntimeConfig.fromBootstrap();

  final AppRuntimeConfig _config;

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() async {
    if (_config.isDev) {
      await Future<void>.delayed(
        _config.skeletonDelay,
      );
    }
    return super.fetchTrendingCounts();
  }
}
