import 'package:flutter_bloc_app/features/chart/domain/chart_data_source.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_remote_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Selects Supabase, Firebase, or direct remote based on sign-in state.
///
/// Concurrent [fetchTrendingCounts] calls **share** one in-flight request only
/// when they resolve to the **same** delegate instance (identity). If sign-in
/// changes between two overlapping calls, each delegate keeps its own in-flight
/// work (see tests).
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

  /// One in-flight future per concrete delegate instance so a concurrent call
  /// that resolves to a **different** active remote (e.g. auth flips mid-await)
  /// does not incorrectly await another delegate’s work.
  ///
  /// Values are wrapped so [Map.remove] does not surface a bare [Future] (which
  /// trips `unawaited_futures` when clearing the slot after `await`).
  final Map<ChartRemoteRepository, _ChartFetchInFlight> _inFlightByDelegate =
      Map<ChartRemoteRepository, _ChartFetchInFlight>.identity();

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
    final _ChartFetchInFlight? slot = _inFlightByDelegate[active];
    final Future<List<ChartPoint>>? existing = slot?.future;
    if (existing != null) {
      return existing;
    }
    final Future<List<ChartPoint>> future = _fetchFromActive(active);
    _inFlightByDelegate[active] = _ChartFetchInFlight(future);
    try {
      return await future;
    } finally {
      final _ChartFetchInFlight? held = _inFlightByDelegate[active];
      if (held != null && identical(held.future, future)) {
        _inFlightByDelegate.remove(active);
      }
    }
  }

  Future<List<ChartPoint>> _fetchFromActive(
    final ChartRemoteRepository active,
  ) async {
    try {
      final List<ChartPoint> points = await active.fetchTrendingCounts();
      _lastSource = active.lastSource;
      return points;
    } on Object {
      _lastSource = ChartDataSource.unknown;
      rethrow;
    }
  }
}

final class _ChartFetchInFlight {
  _ChartFetchInFlight(this.future);

  final Future<List<ChartPoint>> future;
}
