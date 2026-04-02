import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_coordinate.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location_repository.dart';
import 'package:flutter_bloc_app/features/mapbox_demo/presentation/cubit/mapbox_sample_state.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';

class MapboxSampleCubit extends Cubit<MapboxSampleState> {
  MapboxSampleCubit({required final MapLocationRepository repository})
    : _repository = repository,
      super(MapboxSampleState.initial());

  final MapLocationRepository _repository;

  Future<void> loadLocations() async {
    emit(MapboxSampleState.initial().copyWith(isLoading: true));

    await CubitExceptionHandler.executeAsync(
      operation: _repository.fetchSampleLocations,
      isAlive: () => !isClosed,
      onSuccess: (final locations) {
        if (isClosed) return;
        final MapLocation? first = locations.isEmpty ? null : locations.first;
        final MapboxSampleState baseState = MapboxSampleState.initial();

        if (first == null) {
          emit(baseState.copyWith(locations: locations));
          return;
        }

        emit(
          baseState.copyWith(
            locations: locations,
            selectedLocationId: first.id,
            cameraCenter: first.coordinate,
          ),
        );
      },
      onError: (final errorMessage) {
        if (isClosed) return;
        emit(
          MapboxSampleState.initial().copyWith(
            errorMessage: errorMessage,
          ),
        );
      },
      logContext: 'MapboxSampleCubit.loadLocations',
    );
  }

  void selectLocation(final String locationId) {
    final MapLocation? location = state.locations.firstWhereOrNull(
      (final candidate) => candidate.id == locationId,
    );

    if (location == null) return;
    _emitSelection(location);
  }

  void focusLocation(final MapLocation location) => _emitSelection(location);

  void _emitSelection(final MapLocation location) {
    emit(
      state.copyWith(
        selectedLocationId: location.id,
        cameraCenter: _cameraCenterForLocation(location),
        cameraZoom: 16,
      ),
    );
  }

  MapCoordinate _cameraCenterForLocation(final MapLocation location) =>
      location.coordinate;
}
