import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

class HttpChartRepository extends ChartRepository {
  HttpChartRepository({
    final http.Client? client,
    final DateTime Function()? now,
  }) : _client = client ?? http.Client(),
       _now = now ?? DateTime.now;

  final http.Client _client;
  final DateTime Function() _now;
  static final Uri _endpoint = Uri.parse(
    'https://api.coingecko.com/api/v3/coins/bitcoin/market_chart'
    '?vs_currency=usd&days=7&interval=daily',
  );
  static const Map<String, String> _headers = {
    HttpHeaders.acceptHeader: 'application/json',
  };
  static const Duration _cacheDuration = Duration(minutes: 3);
  static List<ChartPoint>? _cached;
  static DateTime? _lastFetched;

  @visibleForTesting
  static void clearCache() {
    _cached = null;
    _lastFetched = null;
  }

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() async {
    final now = _now();
    if (_hasFreshCache(now)) {
      return _cached!;
    }
    try {
      final http.Response response = await _client.get(
        _endpoint,
        headers: _headers,
      );
      if (response.statusCode == HttpStatus.ok) {
        final parsed = _parseBody(response.body);
        return _cache(parsed, now);
      }
      AppLogger.warning(
        'HttpChartRepository.fetchTrendingCounts fallback due to status '
        '${response.statusCode}',
      );
      return _cached ?? _cache(_fallbackData(now), now);
    } on FormatException catch (error) {
      AppLogger.warning(
        'HttpChartRepository.fetchTrendingCounts invalid payload: '
        '${error.message}',
      );
      return _cached ?? _cache(_fallbackData(now), now);
    } on Exception catch (error, stackTrace) {
      AppLogger.warning('HttpChartRepository.fetchTrendingCounts falling back');
      AppLogger.error('HttpChartRepository failure', error, stackTrace);
      return _cached ?? _cache(_fallbackData(now), now);
    }
  }

  bool _hasFreshCache(final DateTime now) {
    if (_cached == null || _lastFetched == null) {
      return false;
    }
    return now.difference(_lastFetched!) < _cacheDuration;
  }

  List<ChartPoint> _cache(
    final List<ChartPoint> data,
    final DateTime fetchedAt,
  ) {
    _cached = data;
    _lastFetched = fetchedAt;
    return data;
  }

  List<ChartPoint> _parseBody(final String body) {
    final dynamic decoded = json.decode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid chart payload shape');
    }
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
