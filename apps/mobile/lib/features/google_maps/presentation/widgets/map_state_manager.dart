import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_cubit.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

/// Manages map state synchronization and updates for both Google and Apple Maps.
class MapStateManager {
  MapStateManager({
    required this.cubit,
    required this.useAppleMaps,
  });

  final MapSampleCubit cubit;
  final bool useAppleMaps;

  gmaps.MapType _mapType = gmaps.MapType.normal;
  bool _trafficEnabled = false;
  Set<gmaps.Marker> _markers = <gmaps.Marker>{};
  gmaps.MarkerId? _selectedMarkerId;
  List<MapLocation> _locations = <MapLocation>[];
  gmaps.CameraPosition _cameraPosition = const gmaps.CameraPosition(
    target: gmaps.LatLng(0, 0),
    zoom: 10,
  );

  // Getters for current state
  gmaps.MapType get mapType => _mapType;
  bool get trafficEnabled => _trafficEnabled;
  Set<gmaps.Marker> get markers => _markers;
  gmaps.MarkerId? get selectedMarkerId => _selectedMarkerId;
  List<MapLocation> get locations => _locations;
  gmaps.CameraPosition get cameraPosition => _cameraPosition;

  /// Initialize state from the provided initial state.
  void initialize(final MapSampleState initialState) {
    _mapType = initialState.mapType;
    _trafficEnabled = initialState.trafficEnabled;
    _markers = initialState.markers;
    _locations = initialState.locations;
    _selectedMarkerId = initialState.selectedMarkerId;
    _cameraPosition = initialState.cameraPosition;
  }

  /// Apply state update and return what changed.
  MapStateChanges applyStateUpdate(final MapSampleState state) {
    final MapStateChanges changes = MapStateChanges(
      mapTypeChanged: state.mapType != _mapType,
      trafficChanged: state.trafficEnabled != _trafficEnabled,
      markersChanged: state.markers != _markers,
      selectionChanged: state.selectedMarkerId != _selectedMarkerId,
      locationsChanged: state.locations != _locations,
      cameraChanged: state.cameraPosition != _cameraPosition,
    );

    // Update local state
    if (changes.mapTypeChanged) _mapType = state.mapType;
    if (changes.trafficChanged) _trafficEnabled = state.trafficEnabled;
    if (changes.markersChanged) _markers = state.markers;
    if (changes.selectionChanged) _selectedMarkerId = state.selectedMarkerId;
    if (changes.locationsChanged) _locations = state.locations;
    _cameraPosition = state.cameraPosition;

    return changes;
  }

  /// Update camera position from map events.
  void updateCameraPosition(
    final gmaps.CameraPosition position, {
    final bool notifyCubit = true,
  }) {
    _cameraPosition = position;
    if (notifyCubit) {
      cubit.updateCameraPosition(position);
    }
  }

  /// Sync local camera position without notifying listeners.
  void setCameraPosition(final gmaps.CameraPosition position) =>
      updateCameraPosition(position, notifyCubit: false);
}

/// Represents what state properties changed in an update.
class MapStateChanges {
  const MapStateChanges({
    required this.mapTypeChanged,
    required this.trafficChanged,
    required this.markersChanged,
    required this.selectionChanged,
    required this.locationsChanged,
    required this.cameraChanged,
  });

  final bool mapTypeChanged;
  final bool trafficChanged;
  final bool markersChanged;
  final bool selectionChanged;
  final bool locationsChanged;
  final bool cameraChanged;

  bool get hasAnyChange =>
      mapTypeChanged ||
      trafficChanged ||
      markersChanged ||
      selectionChanged ||
      locationsChanged ||
      cameraChanged;
}
