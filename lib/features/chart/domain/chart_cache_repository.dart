import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';

/// Local cache for chart trending counts (e.g. Hive-backed).
abstract class ChartCacheRepository {
  Future<List<ChartPoint>> readTrendingCounts({final Duration? maxAge});

  Future<void> writeTrendingCounts(final List<ChartPoint> points);
}
