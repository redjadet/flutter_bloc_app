import 'package:flutter_bloc_app/features/google_maps/domain/map_coordinate.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_location.freezed.dart';

/// Describes a point of interest to showcase on the Google Map sample page.
@freezed
abstract class MapLocation with _$MapLocation {
  const factory MapLocation({
    required final String id,
    required final String title,
    required final String description,
    required final MapCoordinate coordinate,
  }) = _MapLocation;
}
