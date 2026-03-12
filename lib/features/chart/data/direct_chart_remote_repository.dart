import 'package:flutter_bloc_app/features/chart/data/api/coingecko_api.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_source.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_remote_repository.dart';
import 'package:flutter_bloc_app/shared/utils/isolate_json.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Fetches chart trending data directly from CoinGecko (used when Supabase
/// is not configured or user is not signed in).
class DirectChartRemoteRepository implements ChartRemoteRepository {
  DirectChartRemoteRepository({required final CoingeckoApi api}) : _api = api;

  static const Map<String, String> _marketChartQuery = <String, String>{
    'vs_currency': 'usd',
    'days': '7',
    'interval': 'daily',
  };
  static const String _acceptHeader = 'application/json';

  final CoingeckoApi _api;

  @override
  ChartDataSource get lastSource => ChartDataSource.remote;

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() async {
    final String body = await _api.getBitcoinMarketChart(
      _marketChartQuery,
      _acceptHeader,
    );
    if (body.isEmpty) {
      throw const FormatException('Empty response body');
    }
    final Map<String, dynamic> decoded = await decodeJsonMap(body);
    return _parseFromMap(decoded);
  }

  List<ChartPoint> _parseFromMap(final Map<String, dynamic> decoded) {
    final dynamic prices = decoded['prices'];
    if (prices is! List) {
      throw const FormatException('Invalid chart payload content');
    }
    final List<ChartPoint> data = _parsePricesResilient(prices);
    if (data.isEmpty) {
      throw const FormatException('Chart payload missing points');
    }
    return data;
  }

  /// Parses price entries resiliently; skips invalid entries and logs.
  List<ChartPoint> _parsePricesResilient(final List<dynamic> raw) {
    final List<ChartPoint> out = <ChartPoint>[];
    for (final dynamic item in raw) {
      if (item is! List<dynamic> || item.length < 2) continue;
      try {
        out.add(ChartPoint.fromApi(item));
      } on Object catch (error, stackTrace) {
        AppLogger.warning(
          'DirectChartRemoteRepository skip invalid price entry',
        );
        AppLogger.error(
          'DirectChartRemoteRepository._parsePricesResilient',
          error,
          stackTrace,
        );
      }
    }
    out.sort((final a, final b) => a.date.compareTo(b.date));
    return out;
  }
}
