import 'dart:async';

import 'package:flutter_bloc_app/core/constants.dart';
import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_bloc_app/features/chart/chart.dart';

class DelayedChartRepository extends ChartRepository {
  DelayedChartRepository({super.client, super.now});

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() async {
    if (FlavorManager.I.isDev) {
      await Future<void>.delayed(AppConstants.devSkeletonDelay);
    }
    return super.fetchTrendingCounts();
  }
}
