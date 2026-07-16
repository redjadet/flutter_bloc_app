// Fixture: shared app Dio factory shape (allowlisted pattern in production).
import 'package:dio/dio.dart';

Dio createAppDioFixture({required String userAgent}) {
  return Dio(
    BaseOptions(
      headers: <String, dynamic>{'User-Agent': userAgent},
    ),
  );
}
