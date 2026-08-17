import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_coordinate.freezed.dart';

/// Immutable value object representing a geographic coordinate.
@freezed
abstract class MapCoordinate with _$MapCoordinate {
  const factory MapCoordinate({
    required double latitude,
    required double longitude,
  }) = _MapCoordinate;
}
