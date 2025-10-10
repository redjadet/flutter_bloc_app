import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';

/// Contract for retrieving map locations to present on the sample page.
abstract interface class MapLocationRepository {
  Future<List<MapLocation>> fetchSampleLocations();
}
