import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';

/// Contract describing how chart data is provided to the domain layer.
abstract class ChartRepository {
  const ChartRepository();

  Future<List<ChartPoint>> fetchTrendingCounts();

  Future<List<ChartPoint>> call() => fetchTrendingCounts();
}
