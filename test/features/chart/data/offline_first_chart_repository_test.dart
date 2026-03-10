import 'package:flutter_bloc_app/features/chart/data/offline_first_chart_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_cache_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_source.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_remote_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemoteRepository extends Mock implements ChartRemoteRepository {}

class _MockCacheRepository extends Mock implements ChartCacheRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      ChartPoint(date: DateTime.utc(2025, 3, 10), value: 50000.0),
    );
  });

  group('OfflineFirstChartRepository', () {
    late _MockRemoteRepository remote;
    late _MockCacheRepository cache;
    late OfflineFirstChartRepository repository;

    setUp(() {
      remote = _MockRemoteRepository();
      cache = _MockCacheRepository();
      repository = OfflineFirstChartRepository(
        remoteRepository: remote,
        cacheRepository: cache,
      );
    });

    test('writes cache and returns remote data on success', () async {
      final List<ChartPoint> remotePoints = <ChartPoint>[
        ChartPoint(date: DateTime.utc(2025, 3, 10), value: 50000.0),
      ];
      when(
        () => cache.readTrendingCounts(maxAge: any(named: 'maxAge')),
      ).thenAnswer((_) async => <ChartPoint>[]);
      when(
        () => remote.fetchTrendingCounts(),
      ).thenAnswer((_) async => remotePoints);
      when(() => remote.lastSource).thenReturn(ChartDataSource.remote);
      when(() => cache.writeTrendingCounts(any())).thenAnswer((_) async {});

      final List<ChartPoint> result = await repository.fetchTrendingCounts();

      expect(result, remotePoints);
      expect(repository.lastSource, ChartDataSource.remote);
      verify(() => cache.writeTrendingCounts(remotePoints)).called(1);
    });

    test('returns fresh cache without hitting remote', () async {
      final List<ChartPoint> cachedPoints = <ChartPoint>[
        ChartPoint(date: DateTime.utc(2025, 3, 9), value: 49000.0),
      ];
      when(
        () => cache.readTrendingCounts(maxAge: any(named: 'maxAge')),
      ).thenAnswer((_) async => cachedPoints);

      final List<ChartPoint> result = await repository.fetchTrendingCounts();

      expect(result, cachedPoints);
      expect(repository.lastSource, ChartDataSource.cache);
      verifyNever(() => remote.fetchTrendingCounts());
      verifyNever(() => cache.writeTrendingCounts(any()));
    });

    test(
      'returns cached data when remote fails and cache is non-empty',
      () async {
        final List<ChartPoint> cachedPoints = <ChartPoint>[
          ChartPoint(date: DateTime.utc(2025, 3, 9), value: 49000.0),
        ];
        when(
          () => cache.readTrendingCounts(maxAge: any(named: 'maxAge')),
        ).thenAnswer((_) async => cachedPoints);
        when(
          () => remote.fetchTrendingCounts(),
        ).thenThrow(Exception('network'));
        when(() => remote.lastSource).thenReturn(ChartDataSource.remote);

        final List<ChartPoint> result = await repository
            .refreshTrendingCounts();

        expect(result, cachedPoints);
        expect(repository.lastSource, ChartDataSource.cache);
        verifyNever(() => cache.writeTrendingCounts(any()));
      },
    );

    test('rethrows when remote fails and cache is empty', () async {
      when(
        () => cache.readTrendingCounts(maxAge: any(named: 'maxAge')),
      ).thenAnswer((_) async => <ChartPoint>[]);
      when(() => remote.fetchTrendingCounts()).thenThrow(Exception('network'));
      when(() => remote.lastSource).thenReturn(ChartDataSource.remote);

      expect(
        () => repository.fetchTrendingCounts(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('network'),
          ),
        ),
      );
      expect(repository.lastSource, ChartDataSource.unknown);
    });

    test('returns remote data when cache write fails', () async {
      final List<ChartPoint> remotePoints = <ChartPoint>[
        ChartPoint(date: DateTime.utc(2025, 3, 10), value: 50000.0),
      ];
      when(
        () => cache.readTrendingCounts(maxAge: any(named: 'maxAge')),
      ).thenAnswer((_) async => <ChartPoint>[]);
      when(
        () => remote.fetchTrendingCounts(),
      ).thenAnswer((_) async => remotePoints);
      when(() => remote.lastSource).thenReturn(ChartDataSource.remote);
      when(
        () => cache.writeTrendingCounts(any()),
      ).thenThrow(Exception('storage'));

      final List<ChartPoint> result = await repository.fetchTrendingCounts();

      expect(result, remotePoints);
      expect(repository.lastSource, ChartDataSource.remote);
    });

    test('refresh bypasses fresh cache and updates it from remote', () async {
      final List<ChartPoint> cachedPoints = <ChartPoint>[
        ChartPoint(date: DateTime.utc(2025, 3, 9), value: 49000.0),
      ];
      final List<ChartPoint> remotePoints = <ChartPoint>[
        ChartPoint(date: DateTime.utc(2025, 3, 10), value: 50000.0),
      ];
      when(
        () => cache.readTrendingCounts(maxAge: any(named: 'maxAge')),
      ).thenAnswer((_) async => cachedPoints);
      when(
        () => remote.fetchTrendingCounts(),
      ).thenAnswer((_) async => remotePoints);
      when(() => remote.lastSource).thenReturn(ChartDataSource.remote);
      when(() => cache.writeTrendingCounts(any())).thenAnswer((_) async {});

      final List<ChartPoint> result = await repository.refreshTrendingCounts();

      expect(result, remotePoints);
      expect(repository.lastSource, ChartDataSource.remote);
      verify(() => remote.fetchTrendingCounts()).called(1);
      verify(() => cache.writeTrendingCounts(remotePoints)).called(1);
    });
  });
}
