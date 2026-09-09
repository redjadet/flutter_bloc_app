import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/features/weather_demo/data/weather_api_client.dart';
import 'package:flutter_bloc_app/features/weather_demo/data/weather_dto.dart';
import 'package:flutter_bloc_app/features/weather_demo/data/weather_repository_impl.dart';
import 'package:flutter_bloc_app/features/weather_demo/domain/weather_failure.dart';
import 'package:flutter_bloc_app/features/weather_demo/domain/weather_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

Dio _mockDio(Response<dynamic> Function(RequestOptions options) respond) {
  final Dio dio = Dio(BaseOptions(validateStatus: (_) => true));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        handler.resolve(respond(options));
      },
    ),
  );
  return dio;
}

void main() {
  test('repository maps geocode+forecast into snapshot', () async {
    final Dio dio = _mockDio((RequestOptions options) {
      final bool isGeocode = options.uri.host.contains('geocoding');
      if (isGeocode) {
        return Response<dynamic>(
          requestOptions: options,
          statusCode: 200,
          data: <String, dynamic>{
            'results': <Map<String, dynamic>>[
              <String, dynamic>{
                'name': 'Berlin',
                'latitude': 52.52,
                'longitude': 13.405,
              },
            ],
          },
        );
      }
      return Response<dynamic>(
        requestOptions: options,
        statusCode: 200,
        data: <String, dynamic>{
          'current': <String, dynamic>{
            'temperature_2m': 11.0,
            'weather_code': 1,
            'wind_speed_10m': 3.0,
            'time': '2026-01-01T12:00',
          },
          'hourly': <String, dynamic>{
            'time': <String>['2026-01-01T12:00'],
            'temperature_2m': <double>[11.0],
          },
        },
      );
    });

    final WeatherSnapshot snapshot = await WeatherRepositoryImpl(
      api: WeatherApiClient(dio: dio),
    ).fetchForCity('Berlin');
    expect(snapshot.placeName, 'Berlin');
    expect(snapshot.temperatureC, 11.0);
  });

  test('repository maps empty geocode to notFound', () async {
    final Dio dio = _mockDio(
      (RequestOptions options) => Response<dynamic>(
        requestOptions: options,
        statusCode: 200,
        data: <String, dynamic>{'results': <Object>[]},
      ),
    );

    await expectLater(
      WeatherRepositoryImpl(api: WeatherApiClient(dio: dio))
          .fetchForCity('Nowhere'),
      throwsA(isA<WeatherNotFoundFailure>()),
    );
  });

  test('api client parses geocode result', () async {
    final Dio dio = _mockDio(
      (RequestOptions options) => Response<dynamic>(
        requestOptions: options,
        statusCode: 200,
        data: <String, dynamic>{
          'results': <Map<String, dynamic>>[
            <String, dynamic>{
              'name': 'Paris',
              'latitude': 48.85,
              'longitude': 2.35,
            },
          ],
        },
      ),
    );
    final WeatherGeocodeResult? place = await WeatherApiClient(dio: dio)
        .searchCity('Paris');
    expect(place?.name, 'Paris');
  });

  test('api client maps non-2xx to WeatherNetworkFailure', () async {
    final Dio dio = _mockDio(
      (RequestOptions options) => Response<dynamic>(
        requestOptions: options,
        statusCode: 500,
        data: <String, dynamic>{},
      ),
    );
    await expectLater(
      WeatherApiClient(dio: dio).searchCity('Berlin'),
      throwsA(isA<WeatherNetworkFailure>()),
    );
  });

  test('repository maps DioException to WeatherNetworkFailure', () async {
    final Dio dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
              message: 'offline',
            ),
          );
        },
      ),
    );
    await expectLater(
      WeatherRepositoryImpl(api: WeatherApiClient(dio: dio))
          .fetchForCity('Berlin'),
      throwsA(isA<WeatherNetworkFailure>()),
    );
  });
}
