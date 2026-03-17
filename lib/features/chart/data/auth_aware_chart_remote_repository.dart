import 'package:flutter_bloc_app/features/chart/domain/chart_data_source.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_remote_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Selects Supabase, Firebase, or direct remote based on sign-in state.
class AuthAwareChartRemoteRepository implements ChartRemoteRepository {
  AuthAwareChartRemoteRepository({
    required final ChartRemoteRepository supabaseRemote,
    required final ChartRemoteRepository firebaseRemote,
    required final ChartRemoteRepository directRemote,
    required final bool Function() isSupabaseSignedIn,
    required final bool Function() isFirebaseSignedIn,
  }) : _supabaseRemote = supabaseRemote,
       _firebaseRemote = firebaseRemote,
       _directRemote = directRemote,
       _isSupabaseSignedIn = isSupabaseSignedIn,
       _isFirebaseSignedIn = isFirebaseSignedIn;

  final ChartRemoteRepository _supabaseRemote;
  final ChartRemoteRepository _firebaseRemote;
  final ChartRemoteRepository _directRemote;
  final bool Function() _isSupabaseSignedIn;
  final bool Function() _isFirebaseSignedIn;
  ChartDataSource _lastSource = ChartDataSource.unknown;

  ChartRemoteRepository get _active {
    try {
      if (_isSupabaseSignedIn()) return _supabaseRemote;
      if (_isFirebaseSignedIn()) return _firebaseRemote;
      return _directRemote;
    } on Object catch (error, stackTrace) {
      AppLogger.warning(
        'AuthAwareChartRemoteRepository auth check failed, using direct remote',
      );
      AppLogger.error(
        'AuthAwareChartRemoteRepository._active',
        error,
        stackTrace,
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
