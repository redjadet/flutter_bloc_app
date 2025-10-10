import 'package:equatable/equatable.dart';

/// Immutable value object representing a geographic coordinate.
class MapCoordinate extends Equatable {
  const MapCoordinate({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  List<Object> get props => <Object>[latitude, longitude];
}
