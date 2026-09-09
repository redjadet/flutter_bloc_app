import 'package:flutter_bloc_app/features/weather_demo/domain/weather_failure.dart';
import 'package:flutter_bloc_app/features/weather_demo/domain/weather_repository.dart';
import 'package:flutter_bloc_app/features/weather_demo/domain/weather_snapshot.dart';
import 'package:flutter_bloc_app/features/weather_demo/presentation/cubit/weather_cubit.dart';
import 'package:flutter_bloc_app/features/weather_demo/presentation/cubit/weather_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeWeatherRepository implements WeatherRepository {
  WeatherSnapshot? snapshot;
  WeatherFailure? failure;
  Object? unexpected;

  @override
  Future<WeatherSnapshot> fetchForCity(String cityQuery) async {
    if (unexpected != null) {
      throw unexpected!;
    }
    if (failure != null) {
      throw failure!;
    }
    return snapshot!;
  }
}

void main() {
  WeatherSnapshot sample() => WeatherSnapshot(
    placeName: 'Berlin',
    latitude: 1,
    longitude: 2,
    temperatureC: 12,
    weatherCode: 0,
    weatherDescription: 'Clear sky',
    windSpeedKmh: 5,
    observedAt: DateTime.utc(2026, 1, 1),
  );

  test('search emits success', () async {
    final _FakeWeatherRepository repository = _FakeWeatherRepository()
      ..snapshot = sample();
    final WeatherCubit cubit = WeatherCubit(repository: repository);
    await cubit.search('Berlin');
    expect(cubit.state, isA<WeatherSuccess>());
    await cubit.close();
  });

  test('empty query emits invalidQuery failure', () async {
    final WeatherCubit cubit = WeatherCubit(
      repository: _FakeWeatherRepository(),
    );
    await cubit.search('  ');
    final WeatherState state = cubit.state;
    expect(state, isA<WeatherFailureState>());
    expect(
      (state as WeatherFailureState).failure,
      isA<WeatherInvalidQueryFailure>(),
    );
    await cubit.close();
  });

  test('notFound failure surfaces', () async {
    final WeatherCubit cubit = WeatherCubit(
      repository: _FakeWeatherRepository()
        ..failure = const WeatherNotFoundFailure(),
    );
    await cubit.search('Nowhere');
    expect(cubit.state, isA<WeatherFailureState>());
    await cubit.close();
  });

  test('unknown errors map to WeatherUnknownFailure', () async {
    final WeatherCubit cubit = WeatherCubit(
      repository: _FakeWeatherRepository()..unexpected = StateError('x'),
    );
    await cubit.search('Berlin');
    final WeatherState state = cubit.state;
    expect(state, isA<WeatherFailureState>());
    expect(
      (state as WeatherFailureState).failure,
      isA<WeatherUnknownFailure>(),
    );
    await cubit.close();
  });

  test('retry reuses last query', () async {
    final _FakeWeatherRepository repository = _FakeWeatherRepository()
      ..failure = const WeatherNetworkFailure();
    final WeatherCubit cubit = WeatherCubit(repository: repository);
    await cubit.search('Berlin');
    expect(cubit.state, isA<WeatherFailureState>());
    repository
      ..failure = null
      ..snapshot = sample();
    await cubit.retry();
    expect(cubit.state, isA<WeatherSuccess>());
    await cubit.close();
  });
}
