import 'package:flutter_bloc_app/features/google_maps/domain/map_coordinate.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location_repository.dart';

/// Simple in-memory repository returning curated sample locations.
class SampleMapLocationRepository implements MapLocationRepository {
  const SampleMapLocationRepository();

  static const List<MapLocation> _locations = <MapLocation>[
    MapLocation(
      id: 'embarcadero',
      title: 'Ferry Building',
      description: 'Historic marketplace with waterfront views.',
      coordinate: MapCoordinate(latitude: 37.7955, longitude: -122.3937),
    ),
    MapLocation(
      id: 'ferry-park',
      title: 'Sue Bierman Park',
      description: 'Community greenspace next to the Ferry Building.',
      coordinate: MapCoordinate(latitude: 37.7971, longitude: -122.3953),
    ),
    MapLocation(
      id: 'transamerica',
      title: 'Transamerica Pyramid',
      description: 'Iconic San Francisco skyline landmark.',
      coordinate: MapCoordinate(latitude: 37.7952, longitude: -122.4028),
    ),
    MapLocation(
      id: 'moma',
      title: 'SFMOMA',
      description: 'Modern art museum with rotating exhibitions.',
      coordinate: MapCoordinate(latitude: 37.7857, longitude: -122.4011),
    ),
    MapLocation(
      id: 'oracle-park',
      title: 'Oracle Park',
      description: 'Bayfront ballpark, home of the San Francisco Giants.',
      coordinate: MapCoordinate(latitude: 37.7786, longitude: -122.3893),
    ),
  ];

  @override
  Future<List<MapLocation>> fetchSampleLocations() async => _locations;
}
