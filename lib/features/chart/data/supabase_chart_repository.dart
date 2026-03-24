import 'package:flutter_bloc_app/core/supabase/edge_then_tables.dart';
import 'package:flutter_bloc_app/features/chart/data/chart_live_direct_fallback.dart';
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
    final ChartRemoteRepository? liveDirectFallback,
  }) : _readAccessToken = readAccessToken ?? _defaultReadAccessToken,
       _invokeEdgeFunction = invokeEdgeFunction ?? _defaultInvokeEdgeFunction,
       _fetchTableRows = fetchTableRows ?? _defaultFetchTableRows,
       _liveDirectFallback = liveDirectFallback;

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
  final ChartRemoteRepository? _liveDirectFallback;

  Future<List<ChartPoint>>? _inFlightFetch;

  @override
  ChartDataSource get lastSource => _lastSource;

  ChartDataSource _lastSource = ChartDataSource.unknown;

  /// Thrown when edge, direct fallback, and tables all yield no points, so
  /// offline-first layers do not persist an empty list as a successful refresh.
  static const String noChartPointsMessage =
      'Failed to load chart data from Supabase (no points available)';

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() async {
    final existing = _inFlightFetch;
    if (existing != null) {
      return existing;
    }
    final future = _fetchTrendingCountsInternal();
    _inFlightFetch = future;
    try {
      return await future;
    } finally {
      if (identical(_inFlightFetch, future)) {
        _inFlightFetch = null;
      }
    }
  }

  Future<List<ChartPoint>> _fetchTrendingCountsInternal() async {
    ensureSupabaseConfigured();
    try {
      final List<ChartPoint> fromEdge = await _tryFetchFromEdge();
      if (fromEdge.isNotEmpty) {
        _lastSource = ChartDataSource.supabaseEdge;
        return fromEdge;
      }
      final List<ChartPoint>? liveDirect = await tryLiveDirectChartPoints(
        fallback: _liveDirectFallback,
        guardAgainstIdenticalTo: this,
        loggerTag: 'SupabaseChartRepository',
        successDebugDetail:
            'using direct CoinGecko after Supabase edge miss or empty payload',
      );
      if (liveDirect != null) {
        _lastSource = ChartDataSource.remote;
        return liveDirect;
      }
      final List<ChartPoint> fromTables = await _fetchFromTables();
      if (fromTables.isEmpty) {
        _lastSource = ChartDataSource.unknown;
        throw ChartDataException(noChartPointsMessage);
      }
      _lastSource = ChartDataSource.supabaseTables;
      return fromTables;
    } on PostgrestException catch (error, stackTrace) {
      _rethrowAsChartFailure(error.message, error, stackTrace);
    } on ChartDataException {
      rethrow;
    } on Object catch (error, stackTrace) {
      _rethrowAsChartFailure(
        'Failed to load chart data from Supabase',
        error,
        stackTrace,
      );
    }
  }

  Never _rethrowAsChartFailure(
    final String message,
    final Object cause,
    final StackTrace stackTrace,
  ) {
    _lastSource = ChartDataSource.unknown;
    AppLogger.error(
      'SupabaseChartRepository.fetchTrendingCounts',
      cause,
      stackTrace,
    );
    throw ChartDataException(message, cause: cause);
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
