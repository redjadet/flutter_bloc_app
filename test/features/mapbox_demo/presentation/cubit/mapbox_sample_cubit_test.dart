import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_coordinate.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location_repository.dart';
import 'package:flutter_bloc_app/features/mapbox_demo/presentation/cubit/mapbox_sample_cubit.dart';
import 'package:flutter_bloc_app/features/mapbox_demo/presentation/cubit/mapbox_sample_state.dart';

class _StubMapLocationRepository implements MapLocationRepository {
  _StubMapLocationRepository({required this.locations, this.error});

  final List<MapLocation> locations;
  final Exception? error;

  @override
  Future<List<MapLocation>> fetchSampleLocations() async {
    if (error != null) throw error!;
    return locations;
  }
}

final List<MapLocation> _sampleLocations = <MapLocation>[
  const MapLocation(
    id: 'one',
    title: 'First',
    description: 'First marker',
    coordinate: MapCoordinate(latitude: 1, longitude: 1),
  ),
  const MapLocation(
    id: 'two',
    title: 'Second',
    description: 'Second marker',
    coordinate: MapCoordinate(latitude: 2, longitude: 2),
  ),
];

void main() {
  group('MapboxSampleCubit', () {
    blocTest<MapboxSampleCubit, MapboxSampleState>(
      'emits loading then populated state when loadLocations succeeds',
      build: () => MapboxSampleCubit(
        repository: _StubMapLocationRepository(locations: _sampleLocations),
      ),
      act: (cubit) => cubit.loadLocations(),
      expect: () => <dynamic>[
        isA<MapboxSampleState>().having(
          (state) => state.isLoading,
          'isLoading',
          true,
        ),
        isA<MapboxSampleState>()
            .having((state) => state.isLoading, 'isLoading', false)
            .having((state) => state.locations.length, 'locations length', 2)
            .having(
              (state) => state.selectedLocationId,
              'selectedLocationId',
              'one',
            )
            .having(
              (state) => state.cameraCenter,
              'cameraCenter',
              _sampleLocations.first.coordinate,
            )
            .having((state) => state.cameraZoom, 'cameraZoom', 13.5),
      ],
    );

    blocTest<MapboxSampleCubit, MapboxSampleState>(
      'emits error state when loadLocations fails',
      build: () => MapboxSampleCubit(
        repository: _StubMapLocationRepository(
          locations: const <MapLocation>[],
          error: Exception('error'),
        ),
      ),
      act: (cubit) => cubit.loadLocations(),
      expect: () => <dynamic>[
        isA<MapboxSampleState>().having(
          (state) => state.isLoading,
          'isLoading',
          true,
        ),
        isA<MapboxSampleState>()
            .having((state) => state.isLoading, 'isLoading', false)
            .having(
              (state) => state.errorMessage,
              'errorMessage',
              'Exception: error',
            )
            .having((state) => state.locations.isEmpty, 'locations empty', true)
            .having(
              (state) => state.selectedLocationId,
              'selectedLocationId',
              null,
            ),
      ],
    );

    test(
      'selectLocation updates selectedLocationId, cameraCenter, cameraZoom',
      () async {
        final repository = _StubMapLocationRepository(
          locations: _sampleLocations,
        );
        final cubit = MapboxSampleCubit(repository: repository);

        try {
          await cubit.loadLocations();
          cubit.selectLocation('two');

          expect(cubit.state.selectedLocationId, 'two');
          expect(cubit.state.cameraCenter, _sampleLocations[1].coordinate);
          expect(cubit.state.cameraZoom, 16);
        } finally {
          await cubit.close();
        }
      },
    );

    test('selectLocation with unknown id does not change selection', () async {
      final repository = _StubMapLocationRepository(
        locations: _sampleLocations,
      );
      final cubit = MapboxSampleCubit(repository: repository);

      try {
        await cubit.loadLocations();
        cubit.selectLocation('unknown');

        expect(cubit.state.selectedLocationId, 'one');
      } finally {
        await cubit.close();
      }
    });
  });
}
