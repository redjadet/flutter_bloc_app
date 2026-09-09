import 'package:flutter_bloc_app/features/weather_demo/data/weather_code_mapper.dart';
import 'package:flutter_bloc_app/features/weather_demo/domain/weather_snapshot.dart';
import 'package:ilkersevim_safe_parse/ilkersevim_safe_parse.dart';

class const WeatherGeocodeResult({
  required final String name,
  required final double latitude,
  required final double longitude,
}) {
  factory fromJson(Map<String, dynamic> json) {
    final String? parsedName = stringFromDynamic(json['name']);
    final double? parsedLatitude = _doubleOrNull(json['latitude']);
    final double? parsedLongitude = _doubleOrNull(json['longitude']);
    if (parsedName == null ||
        parsedName.isEmpty ||
        parsedLatitude == null ||
        parsedLongitude == null) {
      throw const FormatException('Invalid geocode result');
    }
    return WeatherGeocodeResult(
      name: parsedName,
      latitude: parsedLatitude,
      longitude: parsedLongitude,
    );
  }
}

class const WeatherForecastDto({
  required final double temperatureC,
  required final int weatherCode,
  required final double windSpeedKmh,
  required final DateTime observedAt,
  required final List<WeatherHourlyPoint> hourly,
}) {
  factory fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? current = _asStringKeyedMap(json['current']);
    if (current == null) {
      throw const FormatException('Missing current weather');
    }
    final double? parsedTemperatureC = _doubleOrNull(current['temperature_2m']);
    final int? parsedWeatherCode = intFromDynamic(current['weather_code']);
    final double? parsedWindSpeedKmh = _doubleOrNull(current['wind_speed_10m']);
    final DateTime? parsedObservedAt = _parseTime(current['time']);
    if (parsedTemperatureC == null ||
        parsedWeatherCode == null ||
        parsedWindSpeedKmh == null ||
        parsedObservedAt == null) {
      throw const FormatException('Invalid current weather payload');
    }
    return WeatherForecastDto(
      temperatureC: parsedTemperatureC,
      weatherCode: parsedWeatherCode,
      windSpeedKmh: parsedWindSpeedKmh,
      observedAt: parsedObservedAt,
      hourly: _parseHourly(json['hourly']),
    );
  }

  WeatherSnapshot toDomain(WeatherGeocodeResult place) => WeatherSnapshot(
    placeName: place.name,
    latitude: place.latitude,
    longitude: place.longitude,
    temperatureC: temperatureC,
    weatherCode: weatherCode,
    weatherDescription: weatherDescriptionForCode(weatherCode),
    windSpeedKmh: windSpeedKmh,
    observedAt: observedAt,
    hourly: hourly,
  );

  static List<WeatherHourlyPoint> _parseHourly(Object? raw) {
    final Map<String, dynamic>? hourly = _asStringKeyedMap(raw);
    if (hourly == null) {
      return const <WeatherHourlyPoint>[];
    }
    final Object? timesRaw = hourly['time'];
    final Object? tempsRaw = hourly['temperature_2m'];
    final List<dynamic> times = timesRaw is List<dynamic>
        ? timesRaw
        : const <dynamic>[];
    final List<dynamic> temps = tempsRaw is List<dynamic>
        ? tempsRaw
        : const <dynamic>[];
    final int count = times.length < temps.length ? times.length : temps.length;
    final List<WeatherHourlyPoint> points = <WeatherHourlyPoint>[];
    for (int i = 0; i < count && points.length < 6; i++) {
      final DateTime? parsedTime = _parseTime(times[i]);
      final double? parsedTemp = _doubleOrNull(temps[i]);
      if (parsedTime == null || parsedTemp == null) {
        continue;
      }
      points.add(
        WeatherHourlyPoint(time: parsedTime, temperatureC: parsedTemp),
      );
    }
    return List<WeatherHourlyPoint>.unmodifiable(points);
  }

  static Map<String, dynamic>? _asStringKeyedMap(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    return raw.map(
      (dynamic key, dynamic value) => MapEntry(key.toString(), value),
    );
  }

  static DateTime? _parseTime(Object? raw) {
    final String? value = stringFromDynamic(raw);
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}

double? _doubleOrNull(Object? value) => switch (value) {
  null => null,
  final num v => v.toDouble(),
  final String v => double.tryParse(v.trim()),
  _ => null,
};
