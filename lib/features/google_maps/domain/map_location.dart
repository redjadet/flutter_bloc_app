import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_coordinate.dart';

/// Describes a point of interest to showcase on the Google Map sample page.
class MapLocation extends Equatable {
  const MapLocation({
    required this.id,
    required this.title,
    required this.description,
    required this.coordinate,
  });

  final String id;
  final String title;
  final String description;
  final MapCoordinate coordinate;

  @override
  List<Object> get props => <Object>[id, title, description, coordinate];
}
