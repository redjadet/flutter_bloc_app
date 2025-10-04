import 'dart:convert';

import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_bloc_app/features/chart/chart.dart';
import 'package:flutter_bloc_app/features/chart/data/delayed_chart_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  setUp(() {
    ChartRepository.clearCache();
  });

  tearDown(() {
    FlavorManager.set(Flavor.dev);
  });

  test(
    'DelayedChartRepository fetches chart points without delay in prod',
    () async {
      FlavorManager.set(Flavor.prod);
      final http.Client client = MockClient((request) async {
        final Map<String, Object?> payload = <String, Object?>{
          'prices': <List<Object>>[
            <Object>[1704067200000, 42.0],
            <Object>[1704153600000, 43.5],
          ],
        };
        return http.Response(json.encode(payload), 200);
      });

      final DelayedChartRepository repository = DelayedChartRepository(
        client: client,
        now: () => DateTime.utc(2024, 1, 8),
      );

      final List<ChartPoint> points = await repository.fetchTrendingCounts();
      expect(points, hasLength(2));
      expect(points.first.value, 42.0);
    },
  );
}
