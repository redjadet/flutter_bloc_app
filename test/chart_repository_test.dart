import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/features/chart/data/api/coingecko_api.dart';
import 'package:flutter_bloc_app/features/chart/data/http_chart_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const List<List<num>> prices = <List<num>>[
    <num>[1700000000000, 12345.67],
    <num>[1700086400000, 14321.89],
    <num>[1700172800000, 15678.01],
  ];
  const Map<String, Object> pricesPayload = <String, Object>{'prices': prices};

  Dio createMockDio(String Function() body, int statusCode) {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response<String>(
              requestOptions: options,
              data: body(),
              statusCode: statusCode,
            ),
          );
        },
      ),
    );
    return dio;
  }

  setUp(() {
    HttpChartRepository.clearCache();
  });

  test('fetchTrendingCounts parses payload and caches results', () async {
    int requestCount = 0;
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requestCount++;
          handler.resolve(
            Response<String>(
              requestOptions: options,
              data: jsonEncode(pricesPayload),
              statusCode: 200,
            ),
          );
        },
      ),
    );
    final api = CoingeckoApi(dio);
    final repository = HttpChartRepository(api: api);

    final first = await AppLogger.silenceAsync(
      () => repository.fetchTrendingCounts(),
    );
    final second = await AppLogger.silenceAsync(
      () => repository.fetchTrendingCounts(),
    );

    expect(first, hasLength(prices.length));
    expect(first.first.date.isBefore(first.last.date), isTrue);
    expect(
      identical(first, second),
      isTrue,
      reason: 'Second call should use cache',
    );
    expect(requestCount, 1);
  });

  test('fetchTrendingCounts returns cached data when request fails', () async {
    int requestCount = 0;
    DateTime current = DateTime(2024, 1, 1, 12);
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requestCount++;
          if (requestCount == 1) {
            handler.resolve(
              Response<String>(
                requestOptions: options,
                data: jsonEncode(pricesPayload),
                statusCode: 200,
              ),
            );
          } else {
            handler.resolve(
              Response<String>(
                requestOptions: options,
                data: 'server error',
                statusCode: 500,
              ),
            );
          }
        },
      ),
    );
    final api = CoingeckoApi(dio);
    final repository = HttpChartRepository(api: api, now: () => current);

    final first = await AppLogger.silenceAsync(
      () => repository.fetchTrendingCounts(),
    );
    current = current.add(const Duration(minutes: 5));
    final second = await AppLogger.silenceAsync(
      () => repository.fetchTrendingCounts(),
    );

    expect(second, same(first));
    expect(requestCount, 2);
  });

  test(
    'fetchTrendingCounts falls back to defaults when request fails without cache',
    () async {
      final dio = createMockDio(() => 'server error', 500);
      final api = CoingeckoApi(dio);
      final repository = HttpChartRepository(
        api: api,
        now: () => DateTime(2024, 1, 1, 12),
      );

      final result = await AppLogger.silenceAsync(
        () => repository.fetchTrendingCounts(),
      );

      expect(result, isNotEmpty);
      expect(result.length, 7);
    },
  );

  test(
    'fetchTrendingCounts falls back to defaults when payload is invalid',
    () async {
      final dio = createMockDio(() => '{"prices": "not-a-list"}', 200);
      final api = CoingeckoApi(dio);
      final repository = HttpChartRepository(
        api: api,
        now: () => DateTime(2024, 1, 1, 12),
      );

      final result = await AppLogger.silenceAsync(
        () => repository.fetchTrendingCounts(),
      );

      expect(result, isNotEmpty);
      expect(result.length, 7);
    },
  );

  group('ChartPoint.fromApi', () {
    test('creates ChartPoint from valid entry', () {
      final entry = [1700000000000, 123.45];
      final point = ChartPoint.fromApi(entry);
      expect(point.value, closeTo(123.45, 0.0001));
      expect(point.date.isUtc, isTrue);
    });

    test('throws FormatException when entry is too short', () {
      expect(() => ChartPoint.fromApi([1700000000000]), throwsFormatException);
    });

    test('throws FormatException when entry has invalid types', () {
      expect(
        () => ChartPoint.fromApi(['time', 'value']),
        throwsFormatException,
      );
    });
  });
}
