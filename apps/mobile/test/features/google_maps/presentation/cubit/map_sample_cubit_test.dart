import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_coordinate.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location_repository.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_cubit.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_state.dart';
import 'package:flutter_bloc_app/shared/utils/app_error.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class _StubMapLocationRepository implements MapLocationRepository {
  _StubMapLocationRepository({
    this.locations = const <MapLocation>[],
    this.error,
  });

  final List<MapLocation> locations;
  final Exception? error;
  int loadCount = 0;

  @override
  Future<List<MapLocation>> fetchSampleLocations() async {
    loadCount += 1;
    final Exception? failure = error;
    if (failure != null) {
      throw failure;
    }
    return locations;
  }
}

final List<MapLocation> _sampleLocations = <MapLocation>[
  const MapLocation(
    id: '1',
    title: 'Location 1',
    description: 'Description 1',
    coordinate: MapCoordinate(latitude: 10, longitude: 20),
  ),
  const MapLocation(
    id: '2',
    title: 'Location 2',
    description: 'Description 2',
    coordinate: MapCoordinate(latitude: 30, longitude: 40),
  ),
];

void main() {
  late _RaceMapLocationRepository raceRepository;

  group('MapSampleCubit', () {
    blocTest<MapSampleCubit, MapSampleState>(
      'emits loading then populated state when loadLocations succeeds',
      build: () => MapSampleCubit(
        repository: _StubMapLocationRepository(locations: _sampleLocations),
      ),
      act: (cubit) => cubit.loadLocations(),
      expect: () => <dynamic>[
        isA<MapSampleState>()
            .having((state) => state.isLoading, 'isLoading', true)
            .having((state) => state.markers.isEmpty, 'markers', true),
        isA<MapSampleState>()
            .having((state) => state.isLoading, 'isLoading', false)
            .having((state) => state.locations.length, 'locations', 2)
            .having(
              (state) => state.selectedMarkerId?.value,
              'selectedMarkerId',
              '1',
            ),
      ],
    );

    blocTest<MapSampleCubit, MapSampleState>(
      'emits loading then error when loadLocations fails',
      build: () => MapSampleCubit(
        repository: _StubMapLocationRepository(error: Exception('error')),
      ),
      act: (cubit) => cubit.loadLocations(),
      expect: () => <dynamic>[
        isA<MapSampleState>()
            .having((state) => state.isLoading, 'isLoading', true)
            .having((state) => state.markers.isEmpty, 'markers', true),
        isA<MapSampleState>()
            .having((state) => state.isLoading, 'isLoading', false)
            .having(
              (state) => state.errorMessage,
              'errorMessage',
              'Exception: error',
            )
            .having((state) => state.lastError, 'lastError', isA<AppError>())
            .having((state) => state.locations.isEmpty, 'locations', true),
      ],
    );

    test('toggleTraffic toggles traffic flag after load', () async {
      final repository = _StubMapLocationRepository(
        locations: _sampleLocations,
      );
      final cubit = MapSampleCubit(repository: repository);

      await cubit.loadLocations();
      expect(cubit.state.trafficEnabled, isFalse);

      cubit.toggleTraffic();
      expect(cubit.state.trafficEnabled, isTrue);

      cubit.toggleTraffic();
      expect(cubit.state.trafficEnabled, isFalse);
    });

    test(
      'toggleMapType switches between normal and hybrid after load',
      () async {
        final repository = _StubMapLocationRepository(
          locations: _sampleLocations,
        );
        final cubit = MapSampleCubit(repository: repository);

        await cubit.loadLocations();
        final gmaps.MapType initial = cubit.state.mapType;

        cubit.toggleMapType();
        expect(
          cubit.state.mapType,
          initial == gmaps.MapType.normal
              ? gmaps.MapType.hybrid
              : gmaps.MapType.normal,
        );

        cubit.toggleMapType();
        expect(cubit.state.mapType, initial);
      },
    );

    test('selectLocation updates selected marker when present', () async {
      final repository = _StubMapLocationRepository(
        locations: _sampleLocations,
      );
      final cubit = MapSampleCubit(repository: repository);

      await cubit.loadLocations();
      cubit.selectLocation('2');

      expect(cubit.state.selectedMarkerId, const gmaps.MarkerId('2'));
    });

    test('selectLocation with empty id is a no-op', () async {
      final repository = _StubMapLocationRepository(
        locations: _sampleLocations,
      );
      final cubit = MapSampleCubit(repository: repository);

      await cubit.loadLocations();
      final gmaps.MarkerId? before = cubit.state.selectedMarkerId;

      cubit.selectLocation('');
      cubit.selectLocation('   ');

      expect(cubit.state.selectedMarkerId, before);
    });

    blocTest<MapSampleCubit, MapSampleState>(
      'does not start a second fetch while already loading',
      build: () {
        raceRepository = _RaceMapLocationRepository();
        return MapSampleCubit(repository: raceRepository);
      },
      act: (final cubit) async {
        unawaited(cubit.loadLocations());
        await Future<void>.delayed(Duration.zero);
        unawaited(cubit.loadLocations());
        await Future<void>.delayed(Duration.zero);
        raceRepository.completeFirst(_sampleLocations);
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => <dynamic>[
        isA<MapSampleState>().having(
          (final state) => state.isLoading,
          'isLoading',
          true,
        ),
        isA<MapSampleState>()
            .having((final state) => state.isLoading, 'isLoading', false)
            .having((final state) => state.locations.length, 'locations', 2),
      ],
      verify: (_) {
        expect(raceRepository.callCount, 1);
      },
    );

    blocTest<MapSampleCubit, MapSampleState>(
      'ignores stale completion when a newer load finishes first',
      build: () {
        raceRepository = _RaceMapLocationRepository();
        return MapSampleCubit(repository: raceRepository);
      },
      act: (final cubit) async {
        unawaited(cubit.loadLocations());
        await Future<void>.delayed(Duration.zero);

        unawaited(cubit.reloadLocations());
        await Future<void>.delayed(Duration.zero);

        raceRepository.completeSecond(_sampleLocations);
        await Future<void>.delayed(Duration.zero);

        raceRepository.completeFirst(<MapLocation>[
          const MapLocation(
            id: 'stale',
            title: 'Stale',
            description: 'Stale',
            coordinate: MapCoordinate(latitude: 0, longitude: 0),
          ),
        ]);
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => <dynamic>[
        // load + reload: second loading emit matches first, Cubit suppresses it.
        isA<MapSampleState>().having(
          (final state) => state.isLoading,
          'isLoading',
          true,
        ),
        isA<MapSampleState>()
            .having((final state) => state.isLoading, 'isLoading', false)
            .having((final state) => state.locations.length, 'locations', 2)
            .having(
              (final state) => state.selectedMarkerId?.value,
              'selectedMarkerId',
              '1',
            ),
      ],
      verify: (_) {
        expect(raceRepository.callCount, 2);
      },
    );

    blocTest<MapSampleCubit, MapSampleState>(
      'ignores stale error when a newer load succeeds first',
      build: () {
        raceRepository = _RaceMapLocationRepository();
        return MapSampleCubit(repository: raceRepository);
      },
      act: (final cubit) async {
        unawaited(cubit.loadLocations());
        await Future<void>.delayed(Duration.zero);

        unawaited(cubit.reloadLocations());
        await Future<void>.delayed(Duration.zero);

        raceRepository.completeSecond(_sampleLocations);
        await Future<void>.delayed(Duration.zero);

        raceRepository.completeFirstError(Exception('stale'));
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => <dynamic>[
        // Same as stale-success race: second loading emit deduped by Cubit.
        isA<MapSampleState>().having(
          (final state) => state.isLoading,
          'isLoading',
          true,
        ),
        isA<MapSampleState>()
            .having((final state) => state.isLoading, 'isLoading', false)
            .having((final state) => state.locations.length, 'locations', 2)
            .having(
              (final state) => state.errorMessage,
              'errorMessage',
              isNull,
            ),
      ],
      verify: (_) {
        expect(raceRepository.callCount, 2);
      },
    );
  });
}

class _RaceMapLocationRepository implements MapLocationRepository {
  final Completer<List<MapLocation>> _first = Completer<List<MapLocation>>();
  final Completer<List<MapLocation>> _second = Completer<List<MapLocation>>();
  int _callCount = 0;
  int get callCount => _callCount;

  @override
  Future<List<MapLocation>> fetchSampleLocations() {
    _callCount++;
    if (_callCount == 1) {
      return _first.future;
    }
    return _second.future;
  }

  void completeFirst(final List<MapLocation> locations) {
    if (!_first.isCompleted) {
      _first.complete(locations);
    }
  }

  void completeFirstError(final Object error) {
    if (!_first.isCompleted) {
      _first.completeError(error);
    }
  }

  void completeSecond(final List<MapLocation> locations) {
    if (!_second.isCompleted) {
      _second.complete(locations);
    }
  }
}
