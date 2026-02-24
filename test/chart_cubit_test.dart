import 'dart:async';
import 'dart:collection';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_repository.dart';
import 'package:flutter_bloc_app/features/chart/presentation/cubit/chart_cubit.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final List<ChartPoint> defaultPoints = <ChartPoint>[
    ChartPoint(date: DateTime.utc(2024, 1, 1), value: 42),
    ChartPoint(date: DateTime.utc(2024, 1, 2), value: 43),
  ];
  late _RaceChartRepository raceRepository;

  blocTest<ChartCubit, ChartState>(
    'emits loading then success when load succeeds',
    build: () =>
        ChartCubit(repository: _StubChartRepository(() async => defaultPoints)),
    act: (final cubit) => cubit.load(),
    expect: () => <Matcher>[
      isA<ChartState>()
          .having((final state) => state.status, 'status', ViewStatus.loading)
          .having(
            (final state) => state.points,
            'points',
            equals(const <ChartPoint>[]),
          ),
      isA<ChartState>()
          .having((final state) => state.status, 'status', ViewStatus.success)
          .having(
            (final state) =>
                state.points.map((final point) => point.value).toList(),
            'values',
            equals(defaultPoints.map((final point) => point.value).toList()),
          ),
    ],
  );

  blocTest<ChartCubit, ChartState>(
    'emits empty when repository returns no points',
    build: () => ChartCubit(
      repository: _StubChartRepository(() async => const <ChartPoint>[]),
    ),
    act: (final cubit) => cubit.load(),
    expect: () => <Matcher>[
      isA<ChartState>().having(
        (final state) => state.status,
        'status',
        ViewStatus.loading,
      ),
      isA<ChartState>()
          .having((final state) => state.status, 'status', ViewStatus.success)
          .having(
            (final state) => state.points,
            'points',
            equals(const <ChartPoint>[]),
          ),
    ],
  );

  blocTest<ChartCubit, ChartState>(
    'emits failure when repository throws',
    build: () => ChartCubit(
      repository: _StubChartRepository(() async => throw StateError('boom')),
    ),
    act: (final cubit) => cubit.load(),
    expect: () => <Matcher>[
      isA<ChartState>().having(
        (final state) => state.status,
        'status',
        ViewStatus.loading,
      ),
      isA<ChartState>()
          .having((final state) => state.status, 'status', ViewStatus.error)
          .having((final state) => state.points, 'points', equals(const [])),
    ],
  );

  blocTest<ChartCubit, ChartState>(
    'refresh preserves previous points while reloading',
    build: () {
      final Queue<Future<List<ChartPoint>>> responses =
          Queue<Future<List<ChartPoint>>>.of(<Future<List<ChartPoint>>>[
            Future<List<ChartPoint>>.value(defaultPoints),
            Future<List<ChartPoint>>.value(<ChartPoint>[
              ChartPoint(date: DateTime.utc(2024, 1, 3), value: 44),
            ]),
          ]);
      return ChartCubit(repository: _QueueChartRepository(responses));
    },
    act: (final cubit) async {
      await cubit.load();
      await cubit.refresh();
    },
    expect: () => <Matcher>[
      isA<ChartState>().having(
        (final state) => state.status,
        'status',
        ViewStatus.loading,
      ),
      isA<ChartState>().having(
        (final state) => state.status,
        'status',
        ViewStatus.success,
      ),
      isA<ChartState>()
          .having((final state) => state.status, 'status', ViewStatus.loading)
          .having(
            (final state) =>
                state.points.map((final point) => point.value).toList(),
            'values',
            equals(defaultPoints.map((final point) => point.value).toList()),
          ),
      isA<ChartState>()
          .having((final state) => state.status, 'status', ViewStatus.success)
          .having(
            (final state) =>
                state.points.map((final point) => point.value).toList(),
            'values',
            equals(<double>[44]),
          ),
    ],
  );

  blocTest<ChartCubit, ChartState>(
    'updateZoom toggles zoomEnabled flag',
    build: () =>
        ChartCubit(repository: _StubChartRepository(() async => defaultPoints)),
    act: (final cubit) async {
      await cubit.load();
      cubit.setZoomEnabled(isEnabled: true);
    },
    expect: () => <Matcher>[
      isA<ChartState>().having(
        (final state) => state.status,
        'status',
        ViewStatus.loading,
      ),
      isA<ChartState>().having(
        (final state) => state.status,
        'status',
        ViewStatus.success,
      ),
      isA<ChartState>().having(
        (final state) => state.zoomEnabled,
        'zoomEnabled',
        isTrue,
      ),
    ],
  );

  blocTest<ChartCubit, ChartState>(
    'ignores stale completion when a newer fetch finishes first',
    build: () {
      raceRepository = _RaceChartRepository();
      return ChartCubit(repository: raceRepository);
    },
    act: (final cubit) async {
      unawaited(cubit.load());
      await Future<void>.delayed(Duration.zero);

      unawaited(cubit.refresh());
      await Future<void>.delayed(Duration.zero);

      raceRepository.completeSecond(<ChartPoint>[
        ChartPoint(date: DateTime.utc(2024, 1, 2), value: 200),
      ]);
      await Future<void>.delayed(Duration.zero);

      raceRepository.completeFirst(<ChartPoint>[
        ChartPoint(date: DateTime.utc(2024, 1, 1), value: 100),
      ]);
      await Future<void>.delayed(Duration.zero);
    },
    expect: () => <Matcher>[
      isA<ChartState>().having(
        (final state) => state.status,
        'status',
        ViewStatus.loading,
      ),
      isA<ChartState>()
          .having((final state) => state.status, 'status', ViewStatus.success)
          .having(
            (final state) =>
                state.points.map((final point) => point.value).toList(),
            'values',
            equals(<double>[200]),
          ),
    ],
    verify: (_) {
      expect(raceRepository.callCount, 2);
    },
  );
}

class _StubChartRepository extends ChartRepository {
  _StubChartRepository(this._handler);

  final Future<List<ChartPoint>> Function() _handler;

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() => _handler();
}

class _QueueChartRepository extends ChartRepository {
  _QueueChartRepository(this._responses);

  final Queue<Future<List<ChartPoint>>> _responses;

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() {
    if (_responses.isEmpty) {
      throw StateError('no more responses');
    }
    return _responses.removeFirst();
  }
}

class _RaceChartRepository extends ChartRepository {
  final Completer<List<ChartPoint>> _first = Completer<List<ChartPoint>>();
  final Completer<List<ChartPoint>> _second = Completer<List<ChartPoint>>();
  int _callCount = 0;
  int get callCount => _callCount;

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() {
    _callCount++;
    if (_callCount == 1) {
      return _first.future;
    }
    return _second.future;
  }

  void completeFirst(final List<ChartPoint> points) {
    if (!_first.isCompleted) {
      _first.complete(points);
    }
  }

  void completeSecond(final List<ChartPoint> points) {
    if (!_second.isCompleted) {
      _second.complete(points);
    }
  }
}
