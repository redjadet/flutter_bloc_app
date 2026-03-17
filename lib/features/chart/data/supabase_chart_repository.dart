import 'package:flutter_bloc_app/core/supabase/edge_then_tables.dart';
import 'package:flutter_bloc_app/features/chart/data/chart_points_parser.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_exception.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_source.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_remote_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseChartRepository implements ChartRemoteRepository {
  SupabaseChartRepository({
    final String? Function()? readAccessToken,
    final Future<FunctionResponse> Function({
      required String functionName,
      required String accessToken,
      required Map<String, dynamic> body,
    })?
    invokeEdgeFunction,
    final Future<Object?> Function()? fetchTableRows,
  }) : _readAccessToken = readAccessToken ?? _defaultReadAccessToken,
       _invokeEdgeFunction = invokeEdgeFunction ?? _defaultInvokeEdgeFunction,
       _fetchTableRows = fetchTableRows ?? _defaultFetchTableRows;

  static const String _tableName = 'chart_trending_points';
  static const String _syncFunction = 'sync-chart-trending';
  static const String _authorizationHeader = 'Authorization';

  final String? Function() _readAccessToken;
  final Future<FunctionResponse> Function({
    required String functionName,
    required String accessToken,
    required Map<String, dynamic> body,
  })
  _invokeEdgeFunction;
  final Future<Object?> Function() _fetchTableRows;

  @override
  ChartDataSource get lastSource => _lastSource;

  ChartDataSource _lastSource = ChartDataSource.supabaseTables;

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() async {
    final SupabaseEdgeThenTablesResult<ChartPoint> result =
        await runSupabaseEdgeThenTables<ChartPoint>(
          tryEdge: _tryFetchFromEdge,
          fetchTables: _fetchFromTables,
          onPostgrestException: (final e) =>
              ChartDataException(e.message, cause: e),
          onGenericException: (final msg, final cause) =>
              ChartDataException(msg, cause: cause),
          logContext: 'SupabaseChartRepository.fetchTrendingCounts',
          genericFailureMessage: 'Failed to load chart data from Supabase',
        );
    _lastSource = result.fromEdge
        ? ChartDataSource.supabaseEdge
        : ChartDataSource.supabaseTables;
    return result.result;
  }

  Future<List<ChartPoint>> _tryFetchFromEdge() async {
    try {
      final String? accessToken = _readAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        return const <ChartPoint>[];
      }
      final FunctionResponse response = await _invokeEdgeFunction(
        functionName: _syncFunction,
        accessToken: accessToken,
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
      return parseChartPointsResilient(raw);
    } on Object catch (error, stackTrace) {
      AppLogger.warning(
        'SupabaseChartRepository edge failed (${error.runtimeType})',
      );
      AppLogger.error(
        'SupabaseChartRepository._tryFetchFromEdge',
        error,
        stackTrace,
      );
      return const <ChartPoint>[];
    }
  }

  Future<List<ChartPoint>> _fetchFromTables() async {
    final Object? raw = await _fetchTableRows();
    return _mapPoints(raw);
  }

  List<ChartPoint> _mapPoints(final Object? raw) {
    final List<dynamic>? list = listFromDynamic(raw);
    if (list == null || list.isEmpty) {
      return const <ChartPoint>[];
    }
    return parseChartPointsResilient(list);
  }

  static String? _defaultReadAccessToken() =>
      Supabase.instance.client.auth.currentSession?.accessToken;

  static Future<FunctionResponse> _defaultInvokeEdgeFunction({
    required final String functionName,
    required final String accessToken,
    required final Map<String, dynamic> body,
  }) {
    return Supabase.instance.client.functions.invoke(
      functionName,
      headers: <String, String>{
        _authorizationHeader: 'Bearer $accessToken',
      },
      body: body,
    );
  }

  static Future<Object?> _defaultFetchTableRows() {
    return Supabase.instance.client
        .from(_tableName)
        .select('date_utc, value')
        .order('date_utc');
  }
}
