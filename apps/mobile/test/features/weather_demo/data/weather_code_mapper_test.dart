import 'package:flutter_bloc_app/features/weather_demo/data/weather_code_mapper.dart';
import 'package:flutter_bloc_app/features/weather_demo/domain/weather_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('weatherDescriptionForCode covers known and unknown codes', () {
    expect(weatherDescriptionForCode(0), 'Clear sky');
    expect(weatherDescriptionForCode(45), 'Fog');
    expect(weatherDescriptionForCode(61), 'Rain');
    expect(weatherDescriptionForCode(95), 'Thunderstorm');
    expect(weatherDescriptionForCode(1234), 'Unknown conditions');
  });

  test('WeatherFailure display messages use defaults and overrides', () {
    expect(const WeatherUnknownFailure().displayMessage, isNotEmpty);
    expect(
      const WeatherInvalidQueryFailure().displayMessage,
      'Enter a city name.',
    );
    expect(
      const WeatherNotFoundFailure(message: 'gone').displayMessage,
      'gone',
    );
    expect(
      const WeatherNetworkFailure().displayMessage,
      'Network error. Try again.',
    );
  });
}
