import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_coordinate.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location_repository.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_cubit.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  late MapSampleCubit cubit;
  late _FakeMapLocationRepository repository;

  setUp(() {
    repository = _FakeMapLocationRepository();
    cubit = MapSampleCubit(repository: repository);
  });

  tearDown(() {
    cubit.close();
  });

  blocTest<MapSampleCubit, MapSampleState>(
    'loadLocations emits populated state',
    build: () => MapSampleCubit(repository: _FakeMapLocationRepository()),
    act: (cubit) => cubit.loadLocations(),
    expect: () => [
      isA<MapSampleState>()
          .having((state) => state.isLoading, 'isLoading', true)
          .having((state) => state.locations.isEmpty, 'locations', true),
      isA<MapSampleState>()
          .having((state) => state.isLoading, 'isLoading', false)
          .having((state) => state.locations.length, 'locations length', 2)
          .having((state) => state.markers.length, 'markers length', 2)
          .having(
            (state) => state.selectedMarkerId?.value,
            'selected marker id',
            'one',
          ),
    ],
  );

  test('toggleMapType switches between normal and hybrid', () async {
    await cubit.loadLocations();

    final MapType initial = cubit.state.mapType;
    cubit.toggleMapType();
    expect(
      cubit.state.mapType,
      initial == MapType.normal ? MapType.hybrid : MapType.normal,
    );

    cubit.toggleMapType();
    expect(cubit.state.mapType, initial);
  });

  test('toggleTraffic toggles traffic flag', () async {
    await cubit.loadLocations();
    expect(cubit.state.trafficEnabled, isFalse);

    cubit.toggleTraffic();
    expect(cubit.state.trafficEnabled, isTrue);

    cubit.toggleTraffic();
    expect(cubit.state.trafficEnabled, isFalse);
  });

  test('selectLocation updates selected marker', () async {
    await cubit.loadLocations();
    final String secondId = repository.locations[1].id;

    cubit.selectLocation(secondId);

    expect(cubit.state.selectedMarkerId?.value, secondId);
  });
}

class _FakeMapLocationRepository implements MapLocationRepository {
  final List<MapLocation> locations = <MapLocation>[
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

  @override
  Future<List<MapLocation>> fetchSampleLocations() async => locations;
}
