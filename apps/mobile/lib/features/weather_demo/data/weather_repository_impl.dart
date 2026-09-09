import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/features/weather_demo/data/weather_api_client.dart';
import 'package:flutter_bloc_app/features/weather_demo/data/weather_dto.dart';
import 'package:flutter_bloc_app/features/weather_demo/domain/weather_failure.dart';
import 'package:flutter_bloc_app/features/weather_demo/domain/weather_repository.dart';
import 'package:flutter_bloc_app/features/weather_demo/domain/weather_snapshot.dart';

class WeatherRepositoryImpl({required final WeatherApiClient api})
    implements WeatherRepository {
  @override
  Future<WeatherSnapshot> fetchForCity(String cityQuery) async {
    final String query = cityQuery.trim();
    if (query.isEmpty) {
      throw const WeatherInvalidQueryFailure();
    }
    try {
      final WeatherGeocodeResult? place = await api.searchCity(query);
      if (place == null) {
        throw WeatherNotFoundFailure(message: 'No results for "$query".');
      }
      final WeatherForecastDto forecast = await api.fetchForecast(
        latitude: place.latitude,
        longitude: place.longitude,
      );
      return forecast.toDomain(place);
    } on WeatherFailure {
      rethrow;
    } on DioException catch (error) {
      throw WeatherNetworkFailure(message: error.message, cause: error);
    } on Object catch (error) {
      throw WeatherUnknownFailure(cause: error);
    }
  }
}
