import 'package:flutter_bloc_app/features/chart/domain/chart_data_exception.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_source.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';

/// Remote data source contract for chart trending counts.
///
/// Implementations provide data from a single upstream (e.g. direct CoinGecko,
/// Supabase Edge with table fallback, Firebase callable + Firestore).
/// The direct HTTP implementation may be wired as a shared fallback so Edge or
/// cloud call failures still query a public API before stale Firestore/Postgres
/// snapshots. The offline-first repository wraps the auth-aware remote and
/// handles persistent cache.
///
/// **Empty results:** Prefer [lastSource] together with the returned list.
/// Some implementations throw [ChartDataException] when every stage produced no
/// usable points (so offline-first code does not cache that as a success).
/// Others may return an empty [List] with [ChartDataSource.unknown] for the same
/// situation—check the concrete repository’s behavior in tests or docs.
abstract class ChartRemoteRepository {
  ChartDataSource get lastSource;

  Future<List<ChartPoint>> fetchTrendingCounts();
}
