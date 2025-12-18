import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_coordinate.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_cubit.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_state.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/widgets/map_state_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:mocktail/mocktail.dart';

class _MockMapSampleCubit extends Mock implements MapSampleCubit {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const gmaps.CameraPosition(target: gmaps.LatLng(0, 0), zoom: 0),
    );
  });

  late _MockMapSampleCubit cubit;
  late MapStateManager stateManager;
  late MapSampleState initialState;

  setUp(() {
    cubit = _MockMapSampleCubit();
    const MapLocation location = MapLocation(
      id: 'a',
      title: 'Test',
      description: 'Desc',
      coordinate: MapCoordinate(latitude: 1, longitude: 1),
    );
    final gmaps.Marker marker = gmaps.Marker(
      markerId: const gmaps.MarkerId('a'),
      position: const gmaps.LatLng(1, 1),
    );
    initialState = MapSampleState(
      isLoading: false,
      errorMessage: null,
      cameraPosition: const gmaps.CameraPosition(
        target: gmaps.LatLng(1, 1),
        zoom: 10,
      ),
      markers: <gmaps.Marker>{marker},
      mapType: gmaps.MapType.normal,
      trafficEnabled: false,
      locations: <MapLocation>[location],
      selectedMarkerId: const gmaps.MarkerId('a'),
    );
    stateManager = MapStateManager(cubit: cubit, useAppleMaps: false)
      ..initialize(initialState);
  });

  test('initialize copies initial state values', () {
    expect(stateManager.mapType, initialState.mapType);
    expect(stateManager.trafficEnabled, initialState.trafficEnabled);
    expect(stateManager.markers, initialState.markers);
    expect(stateManager.locations, initialState.locations);
    expect(stateManager.selectedMarkerId, initialState.selectedMarkerId);
    expect(stateManager.cameraPosition, initialState.cameraPosition);
  });

  test('applyStateUpdate returns changes and updates internal state', () {
    const MapLocation newLocation = MapLocation(
      id: 'b',
      title: 'Second',
      description: 'Next',
      coordinate: MapCoordinate(latitude: 2, longitude: 2),
    );
    final gmaps.Marker newMarker = gmaps.Marker(
      markerId: const gmaps.MarkerId('b'),
      position: const gmaps.LatLng(2, 2),
    );
    final MapSampleState nextState = initialState.copyWith(
      mapType: gmaps.MapType.hybrid,
      trafficEnabled: true,
      markers: <gmaps.Marker>{newMarker},
      locations: <MapLocation>[newLocation],
      selectedMarkerId: const gmaps.MarkerId('b'),
      cameraPosition: const gmaps.CameraPosition(
        target: gmaps.LatLng(3, 3),
        zoom: 12,
      ),
    );

    final MapStateChanges changes = stateManager.applyStateUpdate(nextState);

    expect(changes.mapTypeChanged, isTrue);
    expect(changes.trafficChanged, isTrue);
    expect(changes.markersChanged, isTrue);
    expect(changes.locationsChanged, isTrue);
    expect(changes.selectionChanged, isTrue);
    expect(changes.cameraChanged, isTrue);

    expect(stateManager.mapType, nextState.mapType);
    expect(stateManager.trafficEnabled, nextState.trafficEnabled);
    expect(stateManager.markers, nextState.markers);
    expect(stateManager.locations, nextState.locations);
    expect(stateManager.selectedMarkerId, nextState.selectedMarkerId);
    expect(stateManager.cameraPosition, nextState.cameraPosition);
  });

  test('updateCameraPosition notifies cubit by default', () {
    const gmaps.CameraPosition position = gmaps.CameraPosition(
      target: gmaps.LatLng(5, 5),
      zoom: 15,
    );

    stateManager.updateCameraPosition(position);

    verify(() => cubit.updateCameraPosition(position)).called(1);
    expect(stateManager.cameraPosition, position);
  });

  test('updateCameraPosition can skip cubit notification', () {
    const gmaps.CameraPosition position = gmaps.CameraPosition(
      target: gmaps.LatLng(6, 6),
      zoom: 8,
    );

    stateManager.updateCameraPosition(position, notifyCubit: false);

    verifyNever(() => cubit.updateCameraPosition(any()));
    expect(stateManager.cameraPosition, position);
  });
}
