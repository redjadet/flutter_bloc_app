sealed class const WeatherFailure({final String? message, final Object? cause})
    implements Exception {
  String get displayMessage => message ?? 'Something went wrong.';
}

final class const WeatherInvalidQueryFailure({super.message})
    extends WeatherFailure {
  @override
  String get displayMessage => message ?? 'Enter a city name.';
}

final class const WeatherNotFoundFailure({super.message})
    extends WeatherFailure {
  @override
  String get displayMessage => message ?? 'City not found.';
}

final class const WeatherNetworkFailure({super.message, super.cause})
    extends WeatherFailure {
  @override
  String get displayMessage => message ?? 'Network error. Try again.';
}

final class const WeatherUnknownFailure({super.message, super.cause})
    extends WeatherFailure;
