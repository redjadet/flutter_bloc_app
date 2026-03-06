import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

/// Adapts Retrofit [HttpResponse] values to plain Dio [Response] objects so
/// existing repository helpers can continue to use shared Dio-based guards.
Response<String> stringResponseFromHttpResponse(
  final HttpResponse<String> httpResponse,
) {
  final Response<dynamic> response = httpResponse.response;
  return Response<String>(
    data: response.data is String ? response.data as String : null,
    requestOptions: response.requestOptions,
    statusCode: response.statusCode,
    statusMessage: response.statusMessage,
    isRedirect: response.isRedirect,
    redirects: response.redirects,
    extra: response.extra,
    headers: response.headers,
  );
}
