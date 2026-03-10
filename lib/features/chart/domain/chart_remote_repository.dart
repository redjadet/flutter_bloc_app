import 'package:flutter_bloc_app/features/chart/domain/chart_data_source.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';

/// Remote data source contract for chart trending counts.
///
/// Implementations provide data from a single upstream (e.g. direct CoinGecko,
/// Supabase Edge + table fallback). The offline-first repository wraps this
/// and is responsible for caching and fallback behavior.
abstract class ChartRemoteRepository {
  ChartDataSource get lastSource;

  Future<List<ChartPoint>> fetchTrendingCounts();
}
