import 'package:flutter_bloc_app/features/google_maps/domain/map_coordinate.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'mapbox_sample_state.freezed.dart';

@freezed
abstract class MapboxSampleState with _$MapboxSampleState {
  const factory MapboxSampleState({
    required final MapCoordinate cameraCenter,
    required final double cameraZoom,
    @Default(false) final bool isLoading,
    final String? errorMessage,
    @Default(<MapLocation>[]) final List<MapLocation> locations,
    final String? selectedLocationId,
  }) = _MapboxSampleState;

  const MapboxSampleState._();

  factory MapboxSampleState.initial() => const MapboxSampleState(
    cameraCenter: MapCoordinate(
      latitude: 37.7955,
      longitude: -122.3937,
    ),
    cameraZoom: 13.5,
  );

  bool get hasError => errorMessage != null;
}
