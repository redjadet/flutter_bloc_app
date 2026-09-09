import 'package:flutter_bloc_app/features/weather_demo/domain/weather_failure.dart';
import 'package:flutter_bloc_app/features/weather_demo/domain/weather_snapshot.dart';

sealed class const WeatherState({final String? query});

final class const WeatherIdle() extends WeatherState;

final class const WeatherLoading({super.query}) extends WeatherState;

final class const WeatherSuccess(final WeatherSnapshot snapshot, {super.query})
    extends WeatherState;

final class const WeatherFailureState(
  final WeatherFailure failure, {
  super.query,
}) extends WeatherState;
