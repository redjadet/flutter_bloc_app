import 'dart:async';

import 'package:flutter_bloc_app/features/chart/data/supabase_chart_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_exception.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_source.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_remote_repository.dart';
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
      'throws when edge and tables yield no points (no silent empty success)',
      () async {
        final SupabaseChartRepository repository = SupabaseChartRepository(
          readAccessToken: () => 'access-token',
          invokeEdgeFunction:
              ({
                required final String functionName,
                required final String accessToken,
                required final Map<String, dynamic> body,
              }) async => FunctionResponse(
                status: 200,
                data: const <String, dynamic>{'points': <dynamic>[]},
              ),
          fetchTableRows: () async => <Map<String, Object?>>[],
        );

        await expectLater(
          repository.fetchTrendingCounts(),
          throwsA(
            isA<ChartDataException>().having(
              (final ChartDataException e) => e.message,
              'message',
              SupabaseChartRepository.noChartPointsMessage,
            ),
          ),
        );
        expect(repository.lastSource, ChartDataSource.unknown);
      },
    );

    test(
      'coalesces concurrent fetchTrendingCounts into one edge call',
      () async {
        final Completer<FunctionResponse> completer =
            Completer<FunctionResponse>();
        var edgeCalls = 0;
        final SupabaseChartRepository repository = SupabaseChartRepository(
          readAccessToken: () => 'access-token',
          invokeEdgeFunction:
              ({
                required final String functionName,
                required final String accessToken,
                required final Map<String, dynamic> body,
              }) async {
                edgeCalls += 1;
                return completer.future;
              },
          fetchTableRows: () async => throw StateError('tables should not run'),
        );

        final Future<List<ChartPoint>> a = repository.fetchTrendingCounts();
        final Future<List<ChartPoint>> b = repository.fetchTrendingCounts();
        expect(edgeCalls, 1);

        completer.complete(
          FunctionResponse(
            status: 200,
            data: <String, dynamic>{
              'points': <Map<String, Object?>>[
                <String, Object?>{
                  'date_utc': '2025-03-10T00:00:00Z',
                  'value': 1,
                },
              ],
            },
          ),
        );

        final List<ChartPoint> pointsA = await a;
        final List<ChartPoint> pointsB = await b;
        expect(pointsA, pointsB);
        expect(pointsA, <ChartPoint>[
          ChartPoint(date: DateTime.utc(2025, 3, 10), value: 1),
        ]);
        expect(repository.lastSource, ChartDataSource.supabaseEdge);
      },
    );

    test(
      'uses live direct remote when edge is empty and fallback returns points',
      () async {
        var tablesCalled = false;
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
          fetchTableRows: () async {
            tablesCalled = true;
            return <Map<String, Object?>>[];
          },
          liveDirectFallback: _StubDirectChartRemote(<ChartPoint>[
            ChartPoint(date: DateTime.utc(2025, 3, 12), value: 99),
          ]),
        );

        final List<ChartPoint> points = await repository.fetchTrendingCounts();

        expect(points, <ChartPoint>[
          ChartPoint(date: DateTime.utc(2025, 3, 12), value: 99),
        ]);
        expect(repository.lastSource, ChartDataSource.remote);
        expect(tablesCalled, isFalse);
      },
    );

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
        expect(repository.lastSource, ChartDataSource.unknown);
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
      expect(repository.lastSource, ChartDataSource.unknown);
    });
  });
}

final class _StubDirectChartRemote implements ChartRemoteRepository {
  _StubDirectChartRemote(this._points);

  final List<ChartPoint> _points;

  @override
  ChartDataSource get lastSource => ChartDataSource.remote;

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() async => _points;
}
