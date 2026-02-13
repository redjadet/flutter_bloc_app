import 'dart:async';

import 'package:flutter_bloc_app/core/constants/constants.dart';
import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_bloc_app/features/chart/data/http_chart_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';

class DelayedChartRepository extends HttpChartRepository {
  DelayedChartRepository({super.client, super.now});

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() async {
    if (FlavorManager.I.isDev) {
      await Future<void>.delayed(AppConstants.devSkeletonDelay);
    }
    return super.fetchTrendingCounts();
  }
}
