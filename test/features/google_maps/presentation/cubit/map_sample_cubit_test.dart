import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_coordinate.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location_repository.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_cubit.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_state.dart';
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
            .having((state) => state.locations.isEmpty, 'locations', true),
      ],
    );

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
  });
}
