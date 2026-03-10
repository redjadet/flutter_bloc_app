import 'package:flutter_bloc_app/features/chart/domain/chart_data_source.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_remote_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Selects Supabase-backed or direct remote based on sign-in state.
class AuthAwareChartRemoteRepository implements ChartRemoteRepository {
  AuthAwareChartRemoteRepository({
    required final ChartRemoteRepository supabaseRemote,
    required final ChartRemoteRepository directRemote,
    required final bool Function() isSupabaseSignedIn,
  }) : _supabaseRemote = supabaseRemote,
       _directRemote = directRemote,
       _isSupabaseSignedIn = isSupabaseSignedIn;

  final ChartRemoteRepository _supabaseRemote;
  final ChartRemoteRepository _directRemote;
  final bool Function() _isSupabaseSignedIn;
  ChartDataSource _lastSource = ChartDataSource.unknown;

  ChartRemoteRepository get _active {
    try {
      return _isSupabaseSignedIn() ? _supabaseRemote : _directRemote;
    } on Object catch (e, s) {
      AppLogger.warning(
        'AuthAwareChartRemoteRepository isSupabaseSignedIn failed, '
        'using direct remote',
      );
      AppLogger.error(
        'AuthAwareChartRemoteRepository._active',
        e,
        s,
      );
      return _directRemote;
    }
  }

  @override
  ChartDataSource get lastSource => _lastSource;

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() async {
    final ChartRemoteRepository active = _active;
    final List<ChartPoint> points = await active.fetchTrendingCounts();
    _lastSource = active.lastSource;
    return points;
  }
}
