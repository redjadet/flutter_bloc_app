import 'package:flutter_bloc_app/features/chart/data/auth_aware_chart_remote_repository.dart';
import 'package:flutter_bloc_app/features/chart/data/chart_live_direct_fallback.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_source.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_remote_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockChartRemote extends Mock implements ChartRemoteRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue('');
  });

  group('tryLiveDirectChartPoints', () {
    test('returns null when fallback is null', () async {
      expect(
        await tryLiveDirectChartPoints(fallback: null, loggerTag: 'test'),
        isNull,
      );
    });

    test('returns points when fallback succeeds', () async {
      final List<ChartPoint> expected = <ChartPoint>[
        ChartPoint(date: DateTime.utc(2025, 1, 1), value: 1),
      ];
      final List<ChartPoint>? out = await tryLiveDirectChartPoints(
        fallback: _StubChartRemote(expected),
        loggerTag: 'test',
      );
      expect(out, expected);
    });

    test('returns null when fallback returns empty list', () async {
      expect(
        await tryLiveDirectChartPoints(
          fallback: _StubChartRemote(const <ChartPoint>[]),
          loggerTag: 'test',
        ),
        isNull,
      );
    });

    test('returns null when fallback throws', () async {
      expect(
        await tryLiveDirectChartPoints(
          fallback: _ThrowingChartRemote(),
          loggerTag: 'test',
        ),
        isNull,
      );
    });

    test(
      'returns null when fallback is identical to guard (misconfiguration)',
      () async {
        final _SelfFallback repo = _SelfFallback();
        expect(
          await tryLiveDirectChartPoints(
            fallback: repo,
            guardAgainstIdenticalTo: repo,
            loggerTag: 'test',
          ),
          isNull,
        );
      },
    );

    test('uses default logger tag when loggerTag is blank', () async {
      final List<ChartPoint> expected = <ChartPoint>[
        ChartPoint(date: DateTime.utc(2025, 1, 2), value: 2),
      ];
      final List<ChartPoint>? out = await tryLiveDirectChartPoints(
        fallback: _StubChartRemote(expected),
        loggerTag: '   ',
      );
      expect(out, expected);
    });

    test(
      'returns null when fallback is AuthAwareChartRemoteRepository',
      () async {
        final _MockChartRemote a = _MockChartRemote();
        final _MockChartRemote b = _MockChartRemote();
        final _MockChartRemote c = _MockChartRemote();
        when(() => a.fetchTrendingCounts()).thenAnswer((_) async => const []);
        final AuthAwareChartRemoteRepository authAware =
            AuthAwareChartRemoteRepository(
              supabaseRemote: a,
              firebaseRemote: b,
              directRemote: c,
              isSupabaseSignedIn: () => false,
              isFirebaseSignedIn: () => false,
            );
        expect(
          await tryLiveDirectChartPoints(
            fallback: authAware,
            loggerTag: 'test',
          ),
          isNull,
        );
        verifyNever(() => a.fetchTrendingCounts());
      },
    );
  });
}

final class _SelfFallback implements ChartRemoteRepository {
  @override
  ChartDataSource get lastSource => ChartDataSource.remote;

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() async {
    throw StateError('should not run');
  }
}

final class _StubChartRemote implements ChartRemoteRepository {
  _StubChartRemote(this._points);

  final List<ChartPoint> _points;

  @override
  ChartDataSource get lastSource => ChartDataSource.remote;

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() async => _points;
}

final class _ThrowingChartRemote implements ChartRemoteRepository {
  @override
  ChartDataSource get lastSource => ChartDataSource.remote;

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() async {
    throw StateError('network');
  }
}
