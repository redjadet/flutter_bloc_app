import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/google_maps/data/sample_map_location_repository.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';

void main() {
  group('SampleMapLocationRepository', () {
    late SampleMapLocationRepository repository;

    setUp(() {
      repository = const SampleMapLocationRepository();
    });

    test(
      'fetchSampleLocations returns a list of MapLocation objects',
      () async {
        final locations = await repository.fetchSampleLocations();

        expect(locations, isA<List<MapLocation>>());
        expect(locations.length, greaterThan(0));
        expect(locations.first, isA<MapLocation>());
      },
    );
  });
}
