import 'package:flutter_bloc_app/features/chart/data/api/coingecko_api.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_repository.dart';
import 'package:flutter_bloc_app/shared/utils/isolate_json.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:meta/meta.dart';

class HttpChartRepository extends ChartRepository {
  HttpChartRepository({
    required final CoingeckoApi api,
    final DateTime Function()? now,
  }) : _api = api,
       _now = now ?? DateTime.now;

  static const Map<String, String> _marketChartQuery = <String, String>{
    'vs_currency': 'usd',
    'days': '7',
    'interval': 'daily',
  };
  static const String _acceptHeader = 'application/json';
  static const Duration _cacheDuration = Duration(minutes: 3);
  static List<ChartPoint>? _cached;
  static DateTime? _lastFetched;

  final CoingeckoApi _api;
  final DateTime Function() _now;

  @visibleForTesting
  static void clearCache() {
    _cached = null;
    _lastFetched = null;
  }

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() async {
    final now = _now();
    final List<ChartPoint>? cached = _cached;
    final DateTime? lastFetched = _lastFetched;
    if (cached != null &&
        lastFetched != null &&
        now.difference(lastFetched) < _cacheDuration) {
      return cached;
    }
    try {
      final String body = await _api.getBitcoinMarketChart(
        _marketChartQuery,
        _acceptHeader,
      );
      if (body.isEmpty) {
        throw const FormatException('Empty response body');
      }
      final Map<String, dynamic> decoded = await decodeJsonMap(body);
      final List<ChartPoint> data = _parseFromMap(decoded);
      return _cache(data, now);
    } on FormatException catch (error) {
      AppLogger.warning(
        'HttpChartRepository.fetchTrendingCounts invalid payload: '
        '${error.message}',
      );
      return _cached ?? _cache(_fallbackData(now), now);
    } on Exception catch (error, stackTrace) {
      AppLogger.warning(
        'HttpChartRepository.fetchTrendingCounts fallback due to error',
      );
      AppLogger.error('HttpChartRepository failure', error, stackTrace);
      return _cached ?? _cache(_fallbackData(now), now);
    }
  }

  List<ChartPoint> _cache(
    final List<ChartPoint> data,
    final DateTime fetchedAt,
  ) {
    final List<ChartPoint> cached = List<ChartPoint>.unmodifiable(data);
    _cached = cached;
    _lastFetched = fetchedAt;
    return cached;
  }

  @override
  List<ChartPoint>? getCachedTrendingCounts() => _cached;

  /// Parses the market_chart response map into chart points.
  /// Keeps validation and fallback semantics in the repository.
  List<ChartPoint> _parseFromMap(final Map<String, dynamic> decoded) {
    final dynamic prices = decoded['prices'];
    if (prices is! List) {
      throw const FormatException('Invalid chart payload content');
    }

    final data =
        prices
            .whereType<List<dynamic>>()
            .where((final item) => item.length >= 2)
            .map(ChartPoint.fromApi)
            .toList()
          ..sort((final a, final b) => a.date.compareTo(b.date));

    if (data.isEmpty) {
      throw const FormatException('Chart payload missing points');
    }

    return data;
  }

  List<ChartPoint> _fallbackData(final DateTime now) {
    final base = now.toUtc();
    const values = <double>[27150, 27320, 26980, 27560, 28040, 28410, 28200];
    return List<ChartPoint>.generate(values.length, (final index) {
      final date = base.subtract(Duration(days: values.length - index - 1));
      return ChartPoint(date: date, value: values[index]);
    });
  }
}
