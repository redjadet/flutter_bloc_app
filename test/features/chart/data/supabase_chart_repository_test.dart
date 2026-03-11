import 'package:flutter_bloc_app/features/chart/data/supabase_chart_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_exception.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_source.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../helpers/supabase_test_setup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await initializeSupabaseForTest();
  });

  tearDown(resetSupabaseTestState);

  group('SupabaseChartRepository', () {
    test(
      'throws repository exception when Supabase is not configured',
      () async {
        resetSupabaseTestState();
        final SupabaseChartRepository repository = SupabaseChartRepository();

        await expectLater(
          repository.fetchTrendingCounts(),
          throwsA(isA<StateError>()),
        );
      },
    );

    test('returns edge data and marks source as edge', () async {
      final SupabaseChartRepository repository = SupabaseChartRepository(
        readAccessToken: () => 'access-token',
        invokeEdgeFunction:
            ({
              required final String functionName,
              required final String accessToken,
              required final Map<String, dynamic> body,
            }) async {
              expect(functionName, 'sync-chart-trending');
              expect(accessToken, 'access-token');
              expect(body, isEmpty);
              return FunctionResponse(
                status: 200,
                data: <String, dynamic>{
                  'points': <Map<String, Object?>>[
                    <String, Object?>{
                      'date_utc': '2025-03-10T00:00:00Z',
                      'value': 12,
                    },
                    <String, Object?>{'date_utc': 'not-a-date', 'value': 42},
                  ],
                },
              );
            },
        fetchTableRows: () async => throw StateError('tables should not run'),
      );

      final List<ChartPoint> points = await repository.fetchTrendingCounts();

      expect(points, <ChartPoint>[
        ChartPoint(date: DateTime.utc(2025, 3, 10), value: 12),
      ]);
      expect(repository.lastSource, ChartDataSource.supabaseEdge);
    });

    test('falls back to tables when edge returns no usable payload', () async {
      final SupabaseChartRepository repository = SupabaseChartRepository(
        readAccessToken: () => 'access-token',
        invokeEdgeFunction:
            ({
              required final String functionName,
              required final String accessToken,
              required final Map<String, dynamic> body,
            }) async => FunctionResponse(
              status: 200,
              data: const <String, dynamic>{'points': null},
            ),
        fetchTableRows: () async => <Map<String, Object?>>[
          <String, Object?>{
            'date_utc': '2025-03-11T00:00:00Z',
            'value': '24.5',
          },
          <String, Object?>{'date_utc': '', 'value': 7},
        ],
      );

      final List<ChartPoint> points = await repository.fetchTrendingCounts();

      expect(points, <ChartPoint>[
        ChartPoint(date: DateTime.utc(2025, 3, 11), value: 24.5),
      ]);
      expect(repository.lastSource, ChartDataSource.supabaseTables);
    });

    test(
      'maps table failures to ChartDataException with repo message',
      () async {
        final StateError failure = StateError('table boom');
        final SupabaseChartRepository repository = SupabaseChartRepository(
          readAccessToken: () => null,
          fetchTableRows: () async => throw failure,
        );

        await expectLater(
          repository.fetchTrendingCounts(),
          throwsA(
            isA<ChartDataException>()
                .having(
                  (final ChartDataException error) => error.message,
                  'message',
                  'Failed to load chart data from Supabase',
                )
                .having(
                  (final ChartDataException error) => error.cause,
                  'cause',
                  same(failure),
                ),
          ),
        );
      },
    );

    test('rethrows PostgrestException as ChartDataException', () async {
      const PostgrestException failure = PostgrestException(
        message: 'permission denied',
        code: '403',
      );
      final SupabaseChartRepository repository = SupabaseChartRepository(
        readAccessToken: () => null,
        fetchTableRows: () async => throw failure,
      );

      await expectLater(
        repository.fetchTrendingCounts(),
        throwsA(
          isA<ChartDataException>()
              .having(
                (final ChartDataException error) => error.message,
                'message',
                'permission denied',
              )
              .having(
                (final ChartDataException error) => error.cause,
                'cause',
                same(failure),
              ),
        ),
      );
    });
  });
}
