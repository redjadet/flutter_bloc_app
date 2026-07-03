import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_state.dart';

class MapSampleMapController {
  Future<void> Function(MapSampleState state)? syncStateHandler;
  Future<void> Function(MapLocation location)? focusHandler;

  Future<void> syncWithState(final MapSampleState state) async {
    final handler = syncStateHandler;
    if (handler == null) {
      return;
    }
    await handler(state);
  }

  Future<void> focusOnLocation(final MapLocation location) async {
    final handler = focusHandler;
    if (handler == null) {
      return;
    }
    await handler(location);
  }
}
