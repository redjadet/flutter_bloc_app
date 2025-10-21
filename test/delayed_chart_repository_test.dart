import 'dart:convert';

import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_bloc_app/features/chart/data/delayed_chart_repository.dart';
import 'package:flutter_bloc_app/features/chart/data/http_chart_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  setUp(() {
    HttpChartRepository.clearCache();
  });

  tearDown(() {
    FlavorManager.current = Flavor.dev;
  });

  test(
    'DelayedChartRepository fetches chart points without delay in prod',
    () async {
      FlavorManager.current = Flavor.prod;
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
