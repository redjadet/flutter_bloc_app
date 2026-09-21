import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/weather_demo/domain/weather_failure.dart';
import 'package:flutter_bloc_app/features/weather_demo/domain/weather_repository.dart';
import 'package:flutter_bloc_app/features/weather_demo/domain/weather_snapshot.dart';
import 'package:flutter_bloc_app/features/weather_demo/presentation/cubit/weather_state.dart';
import 'package:ilkersevim_async_utils/ilkersevim_async_utils.dart';

class WeatherCubit({required final WeatherRepository repository})
    extends Cubit<WeatherState> {
  this : super(const WeatherIdle());

  String? _lastQuery;
  final RequestIdGuard _searchGuard = RequestIdGuard();

  Future<void> search(String query) async {
    final String trimmed = query.trim();
    _lastQuery = trimmed;
    final int requestId = _searchGuard.next();
    if (trimmed.isEmpty) {
      if (isClosed || !_searchGuard.isCurrent(requestId)) {
        return;
      }
      emit(const WeatherFailureState(WeatherInvalidQueryFailure()));
      return;
    }
    emit(WeatherLoading(query: trimmed));
    try {
      final WeatherSnapshot snapshot = await repository.fetchForCity(trimmed);
      if (isClosed || !_searchGuard.isCurrent(requestId)) {
        return;
      }
      emit(WeatherSuccess(snapshot, query: trimmed));
    } on WeatherFailure catch (failure) {
      if (isClosed || !_searchGuard.isCurrent(requestId)) {
        return;
      }
      emit(WeatherFailureState(failure, query: trimmed));
    } on Object catch (error) {
      if (isClosed || !_searchGuard.isCurrent(requestId)) {
        return;
      }
      emit(
        WeatherFailureState(
          WeatherUnknownFailure(cause: error),
          query: trimmed,
        ),
      );
    }
  }

  Future<void> retry() async {
    final String? query = _lastQuery;
    if (query == null || query.isEmpty) {
      return;
    }
    await search(query);
  }
}
