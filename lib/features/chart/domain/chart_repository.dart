import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';

/// Contract describing how chart data is provided to the domain layer.
abstract class ChartRepository {
  const ChartRepository();

  Future<List<ChartPoint>> fetchTrendingCounts();

  /// Optional local cache hook to surface previously fetched points instantly.
  /// Default is no cache.
  List<ChartPoint>? getCachedTrendingCounts() => null;

  Future<List<ChartPoint>> call() => fetchTrendingCounts();
}
