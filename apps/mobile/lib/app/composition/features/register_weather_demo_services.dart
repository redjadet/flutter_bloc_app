import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/features/weather_demo/data/weather_api_client.dart';
import 'package:flutter_bloc_app/features/weather_demo/data/weather_repository_impl.dart';
import 'package:flutter_bloc_app/features/weather_demo/domain/weather_repository.dart';

void registerWeatherDemoServices() {
  registerLazySingletonIfAbsent<WeatherApiClient>(
    () => WeatherApiClient(dio: getIt<Dio>()),
  );
  registerLazySingletonIfAbsent<WeatherRepository>(
    () => WeatherRepositoryImpl(api: getIt<WeatherApiClient>()),
  );
}
