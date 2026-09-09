import 'package:flutter_bloc_app/features/weather_demo/domain/weather_snapshot.dart';

abstract class WeatherRepository {
  Future<WeatherSnapshot> fetchForCity(String cityQuery);
}
