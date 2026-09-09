import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/features/weather_demo/data/weather_dto.dart';
import 'package:flutter_bloc_app/features/weather_demo/domain/weather_failure.dart';

class WeatherApiClient({required final Dio dio}) {
  static const String _geocodeBase =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const String _forecastBase = 'https://api.open-meteo.com/v1/forecast';

  Future<WeatherGeocodeResult?> searchCity(String query) async {
    final Response<dynamic> response = await dio.get<dynamic>(
      _geocodeBase,
      queryParameters: <String, dynamic>{
        'name': query,
        'count': 1,
        'language': 'en',
        'format': 'json',
      },
    );
    _throwIfFailure(response);
    final Object? data = response.data;
    if (data is! Map) {
      throw const WeatherUnknownFailure(
        message: 'Unexpected geocode response.',
      );
    }
    final Object? results = data['results'];
    if (results is! List || results.isEmpty) {
      return null;
    }
    final Object? first = results.first;
    if (first is! Map) {
      return null;
    }
    final Map<String, dynamic> mapped = first.map(
      (dynamic key, dynamic value) => MapEntry(key.toString(), value),
    );
    return WeatherGeocodeResult.fromJson(mapped);
  }

  Future<WeatherForecastDto> fetchForecast({
    required double latitude,
    required double longitude,
  }) async {
    final Response<dynamic> response = await dio.get<dynamic>(
      _forecastBase,
      queryParameters: <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
        'current': 'temperature_2m,weather_code,wind_speed_10m',
        'hourly': 'temperature_2m',
        'forecast_days': 1,
        'timezone': 'auto',
      },
    );
    _throwIfFailure(response);
    final Object? data = response.data;
    if (data is! Map) {
      throw const WeatherUnknownFailure(
        message: 'Unexpected forecast response.',
      );
    }
    final Map<String, dynamic> mapped = data.map(
      (dynamic key, dynamic value) => MapEntry(key.toString(), value),
    );
    return WeatherForecastDto.fromJson(mapped);
  }

  static void _throwIfFailure(Response<dynamic> response) {
    final int? statusCode = response.statusCode;
    if (statusCode == null || (statusCode >= 200 && statusCode < 300)) {
      return;
    }
    throw WeatherNetworkFailure(
      message: 'Weather request failed ($statusCode).',
    );
  }
}
