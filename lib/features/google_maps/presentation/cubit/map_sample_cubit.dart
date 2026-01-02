import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location_repository.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_state.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class MapSampleCubit extends Cubit<MapSampleState> {
  MapSampleCubit({required final MapLocationRepository repository})
    : _repository = repository,
      super(MapSampleState.initial());

  final MapLocationRepository _repository;

  Future<void> loadLocations() async {
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: null,
        markers: const <gmaps.Marker>{},
        locations: const <MapLocation>[],
        selectedMarkerId: null,
      ),
    );
    await CubitExceptionHandler.executeAsync(
      operation: _repository.fetchSampleLocations,
      onSuccess: (final List<MapLocation> locations) {
        if (isClosed) return;
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
      },
      onError: (final String errorMessage) {
        if (isClosed) return;
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: errorMessage,
            markers: const <gmaps.Marker>{},
            locations: const <MapLocation>[],
            selectedMarkerId: null,
          ),
        );
      },
      logContext: 'MapSampleCubit.loadLocations',
    );
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

  void updateCameraPosition(final gmaps.CameraPosition position) {
    emit(state.copyWith(cameraPosition: position));
  }

  void selectLocation(final String locationId) {
    final MapLocation? location = state.locations.firstWhereOrNull(
      (final MapLocation candidate) => candidate.id == locationId,
    );
    if (location == null) {
      return;
    }
    _emitSelection(location, updateCameraPosition: null);
  }

  void focusLocation(final MapLocation location) {
    _emitSelection(
      location,
      updateCameraPosition: cameraPositionForLocation(location),
    );
  }

  void _emitSelection(
    final MapLocation location, {
    required final gmaps.CameraPosition? updateCameraPosition,
  }) {
    final gmaps.MarkerId markerId = gmaps.MarkerId(location.id);
    emit(
      state.copyWith(
        selectedMarkerId: markerId,
        cameraPosition: updateCameraPosition ?? state.cameraPosition,
        markers: _buildMarkers(
          locations: state.locations,
          selectedMarkerId: markerId,
        ),
      ),
    );
  }

  gmaps.CameraUpdate cameraUpdateForLocation(final MapLocation location) =>
      gmaps.CameraUpdate.newCameraPosition(
        cameraPositionForLocation(location),
      );

  gmaps.CameraPosition cameraPositionForLocation(
    final MapLocation location,
  ) => gmaps.CameraPosition(
    target: gmaps.LatLng(
      location.coordinate.latitude,
      location.coordinate.longitude,
    ),
    zoom: 16,
    tilt: 45,
  );

  gmaps.CameraPosition? _resolveInitialCamera(
    final List<MapLocation> locations,
  ) {
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
    required final List<MapLocation> locations,
    required final gmaps.MarkerId? selectedMarkerId,
  }) => locations
      .map(
        (final MapLocation location) => gmaps.Marker(
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
