import 'package:flutter_bloc_app/core/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_source.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_remote_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseChartRepository implements ChartRemoteRepository {
  static const String _tableName = 'chart_trending_points';
  static const String _syncFunction = 'sync-chart-trending';
  static const String _authorizationHeader = 'Authorization';

  @override
  ChartDataSource get lastSource => _lastSource;

  ChartDataSource _lastSource = ChartDataSource.supabaseTables;

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() async {
    _ensureConfigured();
    try {
      final List<ChartPoint> fromEdge = await _tryFetchFromEdge();
      if (fromEdge.isNotEmpty) {
        _lastSource = ChartDataSource.supabaseEdge;
        return fromEdge;
      }

      final List<ChartPoint> fromTables = await _fetchFromTables();
      _lastSource = ChartDataSource.supabaseTables;
      return fromTables;
    } on PostgrestException catch (e, s) {
      AppLogger.error('SupabaseChartRepository.fetchTrendingCounts', e, s);
      throw Exception(e.message);
    } on Object catch (e, s) {
      AppLogger.error('SupabaseChartRepository.fetchTrendingCounts', e, s);
      throw Exception('Failed to load chart data from Supabase');
    }
  }

  Future<List<ChartPoint>> _tryFetchFromEdge() async {
    try {
      final String? accessToken =
          Supabase.instance.client.auth.currentSession?.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        return const <ChartPoint>[];
      }
      final FunctionResponse response = await Supabase.instance.client.functions
          .invoke(
            _syncFunction,
            headers: <String, String>{
              _authorizationHeader: 'Bearer $accessToken',
            },
            body: <String, dynamic>{},
          );
      if (response.status < 200 || response.status >= 300) {
        AppLogger.warning(
          'SupabaseChartRepository edge returned status ${response.status}',
        );
        return const <ChartPoint>[];
      }
      final Map<String, dynamic>? json = mapFromDynamic(response.data);
      final List<dynamic>? raw = listFromDynamic(json?['points']);
      if (raw == null) {
        return const <ChartPoint>[];
      }
      return _parsePointsResilient(raw);
    } on Object catch (e, s) {
      AppLogger.warning(
        'SupabaseChartRepository edge failed (${e.runtimeType})',
      );
      AppLogger.error(
        'SupabaseChartRepository._tryFetchFromEdge',
        e,
        s,
      );
      return const <ChartPoint>[];
    }
  }

  Future<List<ChartPoint>> _fetchFromTables() async {
    final dynamic raw = await Supabase.instance.client
        .from(_tableName)
        .select('date_utc, value')
        .order('date_utc');
    return _mapPoints(raw);
  }

  void _ensureConfigured() {
    if (!SupabaseBootstrapService.isSupabaseInitialized) {
      throw StateError('Supabase is not configured');
    }
  }

  List<ChartPoint> _parsePointsResilient(final List<dynamic> raw) {
    final List<ChartPoint> out = <ChartPoint>[];
    for (final dynamic item in raw) {
      final Map<String, dynamic>? map = mapFromDynamic(item);
      if (map == null) continue;
      final String? dateUtc = map['date_utc'] as String?;
      final Object? valueObj = map['value'];
      if (dateUtc == null || dateUtc.isEmpty) continue;
      final DateTime? date = DateTime.tryParse(dateUtc);
      if (date == null) continue;
      final double? value = valueObj is num
          ? valueObj.toDouble()
          : double.tryParse(valueObj?.toString() ?? '');
      if (value == null) continue;
      try {
        out.add(ChartPoint(date: date.toUtc(), value: value));
      } on Object catch (e, s) {
        AppLogger.warning(
          'SupabaseChartRepository skip invalid point row',
        );
        AppLogger.error(
          'SupabaseChartRepository._parsePointsResilient',
          e,
          s,
        );
      }
    }
    return List<ChartPoint>.unmodifiable(out);
  }

  List<ChartPoint> _mapPoints(final Object? raw) {
    final List<dynamic>? list = listFromDynamic(raw);
    if (list == null || list.isEmpty) {
      return const <ChartPoint>[];
    }
    return _parsePointsResilient(list);
  }
}
