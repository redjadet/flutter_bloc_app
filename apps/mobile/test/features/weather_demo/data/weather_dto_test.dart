import 'package:flutter_bloc_app/features/weather_demo/data/weather_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('WeatherGeocodeResult.fromJson maps required fields', () {
    final WeatherGeocodeResult place = WeatherGeocodeResult.fromJson(
      <String, dynamic>{
        'name': 'Berlin',
        'latitude': 52.52,
        'longitude': 13.405,
      },
    );
    expect(place.name, 'Berlin');
    expect(place.latitude, 52.52);
    expect(place.longitude, 13.405);
  });

  test('WeatherForecastDto.fromJson maps current and caps hourly at 6', () {
    final WeatherForecastDto dto = WeatherForecastDto.fromJson(
      <String, dynamic>{
        'current': <String, dynamic>{
          'temperature_2m': 12.5,
          'weather_code': 0,
          'wind_speed_10m': 4.2,
          'time': '2026-01-01T12:00',
        },
        'hourly': <String, dynamic>{
          'time': <String>[
            for (int hour = 0; hour < 8; hour++)
              '2026-01-01T${hour.toString().padLeft(2, '0')}:00',
          ],
          'temperature_2m': <double>[
            for (int hour = 0; hour < 8; hour++) 10.0 + hour,
          ],
        },
      },
    );
    expect(dto.temperatureC, 12.5);
    expect(dto.weatherCode, 0);
    expect(dto.windSpeedKmh, 4.2);
    expect(dto.hourly, hasLength(6));
    expect(dto.hourly.first.temperatureC, 10.0);
  });
}
