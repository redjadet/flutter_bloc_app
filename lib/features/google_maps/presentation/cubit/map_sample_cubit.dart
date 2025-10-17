import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location_repository.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

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
        markers: const <gmaps.Marker>{},
        locations: const <MapLocation>[],
        clearSelectedMarker: true,
      ),
    );
    try {
      final List<MapLocation> locations = await _repository
          .fetchSampleLocations();
      final gmaps.MarkerId? firstMarkerId = locations.isEmpty
          ? null
          : gmaps.MarkerId(locations.first.id);
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
          markers: const <gmaps.Marker>{},
          locations: const <MapLocation>[],
          clearSelectedMarker: true,
        ),
      );
    }
  }

  void toggleMapType() {
    final gmaps.MapType nextType = state.mapType == gmaps.MapType.normal
        ? gmaps.MapType.hybrid
        : gmaps.MapType.normal;
    emit(state.copyWith(mapType: nextType));
  }

  void toggleTraffic() {
    emit(state.copyWith(trafficEnabled: !state.trafficEnabled));
  }

  void updateCameraPosition(gmaps.CameraPosition position) {
    emit(state.copyWith(cameraPosition: position));
  }

  void selectLocation(String locationId) {
    final MapLocation? location = state.locations.firstWhereOrNull(
      (MapLocation candidate) => candidate.id == locationId,
    );
    if (location == null) {
      return;
    }
    final gmaps.MarkerId markerId = gmaps.MarkerId(location.id);
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

  gmaps.CameraUpdate cameraUpdateForLocation(MapLocation location) {
    return gmaps.CameraUpdate.newCameraPosition(
      gmaps.CameraPosition(
        target: gmaps.LatLng(
          location.coordinate.latitude,
          location.coordinate.longitude,
        ),
        zoom: 14,
        tilt: 22,
      ),
    );
  }

  gmaps.CameraPosition? _resolveInitialCamera(List<MapLocation> locations) {
    if (locations.isEmpty) {
      return null;
    }
    final MapLocation first = locations.first;
    return gmaps.CameraPosition(
      target: gmaps.LatLng(
        first.coordinate.latitude,
        first.coordinate.longitude,
      ),
      zoom: 13.5,
    );
  }

  Set<gmaps.Marker> _buildMarkers({
    required List<MapLocation> locations,
    required gmaps.MarkerId? selectedMarkerId,
  }) {
    return locations
        .map(
          (MapLocation location) => gmaps.Marker(
            markerId: gmaps.MarkerId(location.id),
            position: gmaps.LatLng(
              location.coordinate.latitude,
              location.coordinate.longitude,
            ),
            infoWindow: gmaps.InfoWindow(
              title: location.title,
              snippet: location.description,
            ),
            onTap: () => selectLocation(location.id),
          ),
        )
        .toSet();
  }
}
