import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

part 'map_sample_state.freezed.dart';

@freezed
abstract class MapSampleState with _$MapSampleState {
  const factory MapSampleState({
    required final gmaps.CameraPosition cameraPosition,
    @Default(true) final bool isLoading,
    final String? errorMessage,
    @Default(<gmaps.Marker>{}) final Set<gmaps.Marker> markers,
    @Default(gmaps.MapType.normal) final gmaps.MapType mapType,
    @Default(false) final bool trafficEnabled,
    @Default(<MapLocation>[]) final List<MapLocation> locations,
    final gmaps.MarkerId? selectedMarkerId,
  }) = _MapSampleState;

  const MapSampleState._();

  factory MapSampleState.initial() => const MapSampleState(
    cameraPosition: gmaps.CameraPosition(
      target: gmaps.LatLng(37.7955, -122.3937),
      zoom: 13,
    ),
  );

  bool get hasError => errorMessage != null;
}
