import 'dart:convert';

import 'package:flutter_bloc_app/features/chart/data/chart_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const List<List<num>> prices = <List<num>>[
    <num>[1700000000000, 12345.67],
    <num>[1700086400000, 14321.89],
    <num>[1700172800000, 15678.01],
  ];
  const Map<String, Object> pricesPayload = <String, Object>{'prices': prices};

  setUp(() {
    ChartRepository.clearCache();
  });

  test('fetchTrendingCounts parses payload and caches results', () async {
    int requestCount = 0;
    final repository = ChartRepository(
      client: MockClient((request) async {
        requestCount++;
        return http.Response(jsonEncode(pricesPayload), 200);
      }),
    );

    final first = await repository.fetchTrendingCounts();
    final second = await repository.fetchTrendingCounts();

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
    final responses = <http.Response>[
      http.Response(jsonEncode(pricesPayload), 200),
      http.Response('server error', 500),
    ];

    DateTime current = DateTime(2024, 1, 1, 12);

    final repository = ChartRepository(
      client: MockClient((request) async {
        requestCount++;
        return responses[requestCount - 1];
      }),
      now: () => current,
    );

    final first = await repository.fetchTrendingCounts();
    current = current.add(const Duration(minutes: 5));
    final second = await repository.fetchTrendingCounts();

    expect(second, same(first));
    expect(requestCount, 2);
  });

  test(
    'fetchTrendingCounts falls back to defaults when request fails without cache',
    () async {
      DateTime current = DateTime(2024, 1, 1, 12);
      final repository = ChartRepository(
        client: MockClient((request) async {
          return http.Response('server error', 500);
        }),
        now: () => current,
      );

      final result = await repository.fetchTrendingCounts();

      expect(result, isNotEmpty);
      expect(result.length, 7);
    },
  );

  test(
    'fetchTrendingCounts falls back to defaults when payload is invalid',
    () async {
      DateTime current = DateTime(2024, 1, 1, 12);
      final repository = ChartRepository(
        client: MockClient((request) async {
          return http.Response('{"prices": "not-a-list"}', 200);
        }),
        now: () => current,
      );

      final result = await repository.fetchTrendingCounts();

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
