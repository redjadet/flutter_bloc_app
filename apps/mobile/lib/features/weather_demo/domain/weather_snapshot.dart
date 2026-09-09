class const WeatherHourlyPoint({
  required final DateTime time,
  required final double temperatureC,
});

class const WeatherSnapshot({
  required final String placeName,
  required final double latitude,
  required final double longitude,
  required final double temperatureC,
  required final int weatherCode,
  required final String weatherDescription,
  required final double windSpeedKmh,
  required final DateTime observedAt,
  final List<WeatherHourlyPoint> hourly = const <WeatherHourlyPoint>[],
});
