import 'dart:async';

import 'package:flutter_bloc_app/features/weather_demo/domain/weather_failure.dart';
import 'package:flutter_bloc_app/features/weather_demo/domain/weather_repository.dart';
import 'package:flutter_bloc_app/features/weather_demo/domain/weather_snapshot.dart';
import 'package:flutter_bloc_app/features/weather_demo/presentation/cubit/weather_cubit.dart';
import 'package:flutter_bloc_app/features/weather_demo/presentation/cubit/weather_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _ControllableWeatherRepository implements WeatherRepository {
  final Map<String, List<Completer<WeatherSnapshot>>> _pending =
      <String, List<Completer<WeatherSnapshot>>>{};

  /// Completer for the [index]-th in-flight fetch of [cityQuery] (0-based).
  Completer<WeatherSnapshot> pendingFor(String cityQuery, [int index = 0]) {
    final List<Completer<WeatherSnapshot>>? list = _pending[cityQuery];
    if (list == null || index < 0 || index >= list.length) {
      throw StateError('No pending fetch for $cityQuery[$index]');
    }
    return list[index];
  }

  @override
  Future<WeatherSnapshot> fetchForCity(String cityQuery) {
    final List<Completer<WeatherSnapshot>> list = _pending.putIfAbsent(
      cityQuery,
      () => <Completer<WeatherSnapshot>>[],
    );
    final Completer<WeatherSnapshot> completer = Completer<WeatherSnapshot>();
    list.add(completer);
    return completer.future;
  }
}

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
  WeatherSnapshot sample({String placeName = 'Berlin'}) => WeatherSnapshot(
    placeName: placeName,
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

  test(
    'overlapping search: slower older city cannot overwrite newer success',
    () async {
      final _ControllableWeatherRepository repository =
          _ControllableWeatherRepository();
      final WeatherCubit cubit = WeatherCubit(repository: repository);
      var sawBerlinSuccess = false;
      final StreamSubscription<WeatherState> sub = cubit.stream.listen((
        WeatherState state,
      ) {
        if (state is WeatherSuccess && state.snapshot.placeName == 'Berlin') {
          sawBerlinSuccess = true;
        }
      });

      final Future<void> first = cubit.search('Berlin');
      final Future<void> second = cubit.search('Paris');

      // Complete newer request first, then older — stale Berlin must not win.
      repository.pendingFor('Paris').complete(sample(placeName: 'Paris'));
      await second;
      repository.pendingFor('Berlin').complete(sample(placeName: 'Berlin'));
      await first;

      expect(cubit.state, isA<WeatherSuccess>());
      expect((cubit.state as WeatherSuccess).snapshot.placeName, 'Paris');
      expect(sawBerlinSuccess, isFalse);

      await sub.cancel();
      await cubit.close();
    },
  );

  test(
    'ABA Berlin→Paris→Berlin: first Berlin completion cannot overwrite third',
    () async {
      final _ControllableWeatherRepository repository =
          _ControllableWeatherRepository();
      final WeatherCubit cubit = WeatherCubit(repository: repository);

      final Future<void> first = cubit.search('Berlin');
      final Future<void> second = cubit.search('Paris');
      final Future<void> third = cubit.search('Berlin');

      repository.pendingFor('Paris').complete(sample(placeName: 'Paris'));
      await second;
      // Distinct per-invocation completers: finish third Berlin first.
      repository
          .pendingFor('Berlin', 1)
          .complete(sample(placeName: 'Berlin-late'));
      await third;
      expect(cubit.state, isA<WeatherSuccess>());
      expect((cubit.state as WeatherSuccess).snapshot.placeName, 'Berlin-late');

      repository
          .pendingFor('Berlin', 0)
          .complete(sample(placeName: 'Berlin-early'));
      await first;

      expect(cubit.state, isA<WeatherSuccess>());
      // Third search still owns the result; first Berlin is superseded.
      expect((cubit.state as WeatherSuccess).snapshot.placeName, 'Berlin-late');

      await cubit.close();
    },
  );

  test(
    'stale typed failure from older search does not overwrite newer success',
    () async {
      final _ControllableWeatherRepository repository =
          _ControllableWeatherRepository();
      final WeatherCubit cubit = WeatherCubit(repository: repository);

      final Future<void> first = cubit.search('Berlin');
      final Future<void> second = cubit.search('Paris');

      repository.pendingFor('Paris').complete(sample(placeName: 'Paris'));
      await second;
      repository
          .pendingFor('Berlin')
          .completeError(const WeatherNotFoundFailure());
      await first;

      expect(cubit.state, isA<WeatherSuccess>());
      expect((cubit.state as WeatherSuccess).snapshot.placeName, 'Paris');

      await cubit.close();
    },
  );

  test(
    'stale unexpected error from older search does not overwrite newer success',
    () async {
      final _ControllableWeatherRepository repository =
          _ControllableWeatherRepository();
      final WeatherCubit cubit = WeatherCubit(repository: repository);

      final Future<void> first = cubit.search('Berlin');
      final Future<void> second = cubit.search('Paris');

      repository.pendingFor('Paris').complete(sample(placeName: 'Paris'));
      await second;
      repository.pendingFor('Berlin').completeError(StateError('late'));
      await first;

      expect(cubit.state, isA<WeatherSuccess>());
      expect((cubit.state as WeatherSuccess).snapshot.placeName, 'Paris');

      await cubit.close();
    },
  );
}
