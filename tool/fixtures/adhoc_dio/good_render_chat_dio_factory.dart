// Fixture: dedicated Render chat Dio factory shape (allowlisted pattern).
import 'package:dio/dio.dart';

Dio createRenderChatDioFixture({required String baseUrl}) {
  return Dio(
    BaseOptions(
      baseUrl: baseUrl,
      followRedirects: false,
    ),
  );
}
