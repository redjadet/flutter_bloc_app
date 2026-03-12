import 'package:flutter_bloc_app/features/chart/domain/chart_data_source.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';

/// Contract describing how chart data is provided to the domain layer.
abstract class ChartRepository {
  const ChartRepository();

  Future<List<ChartPoint>> fetchTrendingCounts();

  /// Loads cached points from persistent storage when available.
  ///
  /// This is used by the presentation layer to render cached data immediately
  /// before triggering a refresh on first open.
  Future<List<ChartPoint>> loadCachedTrendingCounts() async =>
      getCachedTrendingCounts() ?? const <ChartPoint>[];

  /// Forces a refresh from the active remote when supported.
  ///
  /// Default implementations delegate to [fetchTrendingCounts].
  Future<List<ChartPoint>> refreshTrendingCounts() => fetchTrendingCounts();

  /// Optional local cache hook to surface previously fetched points instantly.
  /// Default is no cache.
  List<ChartPoint>? getCachedTrendingCounts() => null;

  /// Last source that successfully returned data (for telemetry/optional badge).
  ChartDataSource get lastSource => ChartDataSource.unknown;

  Future<List<ChartPoint>> call() => fetchTrendingCounts();
}
