import 'dart:convert';

import 'package:flutter_bloc_app/features/chart/chart.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:http/http.dart' as http;

class ChartRepository {
  ChartRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static final Uri _endpoint = Uri.parse(
    'https://api.coingecko.com/api/v3/coins/bitcoin/market_chart'
    '?vs_currency=usd&days=7&interval=daily',
  );
  static const Duration _cacheDuration = Duration(minutes: 3);
  static List<ChartPoint>? _cached;
  static DateTime? _lastFetched;

  Future<List<ChartPoint>> fetchTrendingCounts() async {
    final now = DateTime.now();
    if (_cached != null &&
        _lastFetched != null &&
        now.difference(_lastFetched!) < _cacheDuration) {
      return _cached!;
    }
    try {
      final http.Response response = await _client.get(
        _endpoint,
        headers: {'accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final parsed = _parseBody(response.body);
        _cached = parsed;
        _lastFetched = now;
        return parsed;
      }
      AppLogger.warning(
        'ChartRepository.fetchTrendingCounts fallback '
        'due to status ${response.statusCode}',
      );
      if (_cached != null) {
        return _cached!;
      }
    } catch (e, s) {
      AppLogger.warning('ChartRepository.fetchTrendingCounts falling back');
      AppLogger.debug('ChartRepository error details: $e');
      AppLogger.error('ChartRepository failure', e, s);
      if (_cached != null) {
        return _cached!;
      }
    }
    final fallback = _fallbackData;
    _cached = fallback;
    _lastFetched = now;
    return fallback;
  }

  List<ChartPoint> _parseBody(String body) {
    final dynamic decoded = json.decode(body);
    if (decoded is Map<String, dynamic> && decoded['prices'] is List<dynamic>) {
      final data =
          (decoded['prices'] as List<dynamic>)
              .whereType<List<dynamic>>()
              .where(
                (item) => item.length >= 2 && item[0] is num && item[1] is num,
              )
              .map(ChartPoint.fromApi)
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));
      if (data.isNotEmpty) {
        return data;
      }
    }
    throw const FormatException('Invalid chart payload');
  }

  List<ChartPoint> get _fallbackData {
    final now = DateTime.now().toUtc();
    final values = <double>[27150, 27320, 26980, 27560, 28040, 28410, 28200];
    return List<ChartPoint>.generate(values.length, (index) {
      final date = now.subtract(Duration(days: values.length - index - 1));
      return ChartPoint(date: date, value: values[index]);
    });
  }
}
