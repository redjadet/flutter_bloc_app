import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:utilities/utilities.dart';

part 'map_sample_state.freezed.dart';

@freezed
abstract class MapSampleState with _$MapSampleState {
  const factory MapSampleState({
    required gmaps.CameraPosition cameraPosition,
    @Default(true) bool isLoading,
    String? errorMessage,
    AppError? lastError,
    @Default(<gmaps.Marker>{}) Set<gmaps.Marker> markers,
    @Default(gmaps.MapType.normal) gmaps.MapType mapType,
    @Default(false) bool trafficEnabled,
    @Default(<MapLocation>[]) List<MapLocation> locations,
    gmaps.MarkerId? selectedMarkerId,
  }) = _MapSampleState;

  const MapSampleState._();

  factory MapSampleState.initial() => const MapSampleState(
    cameraPosition: gmaps.CameraPosition(
      target: gmaps.LatLng(37.7955, -122.3937),
      zoom: 13,
    ),
    isLoading: false,
  );

  bool get hasError => errorMessage != null || lastError != null;
}
