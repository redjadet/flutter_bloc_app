import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';

/// Local cache for chart trending counts (e.g. Hive-backed).
abstract class ChartCacheRepository {
  Future<List<ChartPoint>> readTrendingCounts({Duration? maxAge});

  Future<void> writeTrendingCounts(List<ChartPoint> points);
}
