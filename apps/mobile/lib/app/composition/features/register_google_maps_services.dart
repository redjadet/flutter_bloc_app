import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/features/google_maps/data/sample_map_location_repository.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location_repository.dart';

/// Registers sample map location repository.
void registerGoogleMapsServices() {
  registerLazySingletonIfAbsent<MapLocationRepository>(
    () => const SampleMapLocationRepository(),
  );
}
