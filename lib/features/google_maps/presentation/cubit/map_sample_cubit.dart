import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location_repository.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSampleCubit extends Cubit<MapSampleState> {
  MapSampleCubit({required MapLocationRepository repository})
    : _repository = repository,
      super(MapSampleState.initial());

  final MapLocationRepository _repository;

  Future<void> loadLocations() async {
    emit(
      state.copyWith(
        isLoading: true,
        clearError: true,
        markers: const <Marker>{},
        locations: const <MapLocation>[],
        clearSelectedMarker: true,
      ),
    );
    try {
      final List<MapLocation> locations = await _repository
          .fetchSampleLocations();
      final MarkerId? firstMarkerId = locations.isEmpty
          ? null
          : MarkerId(locations.first.id);
      emit(
        state.copyWith(
          isLoading: false,
          locations: locations,
          selectedMarkerId: firstMarkerId,
          cameraPosition:
              _resolveInitialCamera(locations) ??
              state.cameraPosition, // Keep default when list empty.
          markers: _buildMarkers(
            locations: locations,
            selectedMarkerId: firstMarkerId,
          ),
        ),
      );
    } on Exception catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
          markers: const <Marker>{},
          locations: const <MapLocation>[],
          clearSelectedMarker: true,
        ),
      );
    }
  }

  void toggleMapType() {
    final MapType nextType = state.mapType == MapType.normal
        ? MapType.hybrid
        : MapType.normal;
    emit(state.copyWith(mapType: nextType));
  }

  void toggleTraffic() {
    emit(state.copyWith(trafficEnabled: !state.trafficEnabled));
  }

  void updateCameraPosition(CameraPosition position) {
    emit(state.copyWith(cameraPosition: position));
  }

  void selectLocation(String locationId) {
    final MapLocation? location = state.locations.firstWhereOrNull(
      (MapLocation candidate) => candidate.id == locationId,
    );
    if (location == null) {
      return;
    }
    final MarkerId markerId = MarkerId(location.id);
    emit(
      state.copyWith(
        selectedMarkerId: markerId,
        markers: _buildMarkers(
          locations: state.locations,
          selectedMarkerId: markerId,
        ),
      ),
    );
  }

  CameraUpdate cameraUpdateForLocation(MapLocation location) {
    return CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(
          location.coordinate.latitude,
          location.coordinate.longitude,
        ),
        zoom: 14,
        tilt: 22,
      ),
    );
  }

  CameraPosition? _resolveInitialCamera(List<MapLocation> locations) {
    if (locations.isEmpty) {
      return null;
    }
    final MapLocation first = locations.first;
    return CameraPosition(
      target: LatLng(first.coordinate.latitude, first.coordinate.longitude),
      zoom: 13.5,
    );
  }

  Set<Marker> _buildMarkers({
    required List<MapLocation> locations,
    required MarkerId? selectedMarkerId,
  }) {
    return locations
        .map(
          (MapLocation location) => Marker(
            markerId: MarkerId(location.id),
            position: LatLng(
              location.coordinate.latitude,
              location.coordinate.longitude,
            ),
            infoWindow: InfoWindow(
              title: location.title,
              snippet: location.description,
            ),
            onTap: () => selectLocation(location.id),
          ),
        )
        .toSet();
  }
}
