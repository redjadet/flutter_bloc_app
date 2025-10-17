import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class MapSampleState extends Equatable {
  const MapSampleState({
    required this.isLoading,
    required this.errorMessage,
    required this.cameraPosition,
    required this.markers,
    required this.mapType,
    required this.trafficEnabled,
    required this.locations,
    required this.selectedMarkerId,
  });

  factory MapSampleState.initial() => const MapSampleState(
    isLoading: true,
    errorMessage: null,
    cameraPosition: gmaps.CameraPosition(
      target: gmaps.LatLng(37.7955, -122.3937),
      zoom: 13,
    ),
    markers: <gmaps.Marker>{},
    mapType: gmaps.MapType.normal,
    trafficEnabled: false,
    locations: <MapLocation>[],
    selectedMarkerId: null,
  );

  final bool isLoading;
  final String? errorMessage;
  final gmaps.CameraPosition cameraPosition;
  final Set<gmaps.Marker> markers;
  final gmaps.MapType mapType;
  final bool trafficEnabled;
  final List<MapLocation> locations;
  final gmaps.MarkerId? selectedMarkerId;

  MapSampleState copyWith({
    bool? isLoading,
    String? errorMessage,
    gmaps.CameraPosition? cameraPosition,
    Set<gmaps.Marker>? markers,
    gmaps.MapType? mapType,
    bool? trafficEnabled,
    List<MapLocation>? locations,
    gmaps.MarkerId? selectedMarkerId,
    bool clearError = false,
    bool clearSelectedMarker = false,
  }) {
    return MapSampleState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      cameraPosition: cameraPosition ?? this.cameraPosition,
      markers: markers ?? this.markers,
      mapType: mapType ?? this.mapType,
      trafficEnabled: trafficEnabled ?? this.trafficEnabled,
      locations: locations ?? this.locations,
      selectedMarkerId: clearSelectedMarker
          ? null
          : selectedMarkerId ?? this.selectedMarkerId,
    );
  }

  bool get hasError => errorMessage != null;

  @override
  List<Object?> get props => <Object?>[
    isLoading,
    errorMessage,
    cameraPosition,
    markers,
    mapType,
    trafficEnabled,
    locations,
    selectedMarkerId,
  ];
}
