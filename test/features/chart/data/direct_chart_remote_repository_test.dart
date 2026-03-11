import 'package:flutter_bloc_app/features/chart/data/api/coingecko_api.dart';
import 'package:flutter_bloc_app/features/chart/data/direct_chart_remote_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCoingeckoApi implements CoingeckoApi {
  _FakeCoingeckoApi(this._body);

  final String Function() _body;

  @override
  Future<String> getBitcoinMarketChart(
    final Map<String, String> query,
    final String accept,
  ) async {
    expect(query, const <String, String>{
      'vs_currency': 'usd',
      'days': '7',
      'interval': 'daily',
    });
    expect(accept, 'application/json');
    return _body();
  }
}

void main() {
  group('DirectChartRemoteRepository', () {
    test('throws FormatException for empty response body', () async {
      final DirectChartRemoteRepository repository =
          DirectChartRemoteRepository(api: _FakeCoingeckoApi(() => ''));

      await expectLater(
        repository.fetchTrendingCounts(),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException for invalid payload content', () async {
      final DirectChartRemoteRepository repository =
          DirectChartRemoteRepository(
            api: _FakeCoingeckoApi(() => '{"prices":"nope"}'),
          );

      await expectLater(
        repository.fetchTrendingCounts(),
        throwsA(isA<FormatException>()),
      );
    });

    test('skips malformed price entries and sorts valid points', () async {
      final DirectChartRemoteRepository repository =
          DirectChartRemoteRepository(
            api: _FakeCoingeckoApi(
              () => '''
{
  "prices": [
    [1741651200000, 42500.0],
    ["bad-ts", 42000.0],
    [1741478400000, 41000.5],
    [1741564800000]
  ]
}
''',
            ),
          );

      final List<ChartPoint> points = await repository.fetchTrendingCounts();

      expect(points, <ChartPoint>[
        ChartPoint(
          date: DateTime.fromMillisecondsSinceEpoch(1741478400000, isUtc: true),
          value: 41000.5,
        ),
        ChartPoint(
          date: DateTime.fromMillisecondsSinceEpoch(1741651200000, isUtc: true),
          value: 42500,
        ),
      ]);
      expect(repository.lastSource.name, 'remote');
    });

    test(
      'throws when no valid points remain after resilient parsing',
      () async {
        final DirectChartRemoteRepository repository =
            DirectChartRemoteRepository(
              api: _FakeCoingeckoApi(
                () => '{"prices":[["bad",1],[2],"invalid"]}',
              ),
            );

        await expectLater(
          repository.fetchTrendingCounts(),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });
}
