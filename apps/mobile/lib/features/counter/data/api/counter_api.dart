import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'counter_api.g.dart';

/// Type-safe REST client for the example counter API.
///
/// Parsing and error handling remain in the counter repository.
@RestApi()
abstract class CounterApi {
  factory CounterApi(Dio dio, {String? baseUrl}) = _CounterApi;

  @GET('counter')
  Future<HttpResponse<String>> getCounter(
    @DioOptions() Options? options,
  );

  @POST('counter')
  Future<HttpResponse<void>> saveCounter(
    @Body() Map<String, dynamic> body,
    @DioOptions() Options? options,
  );
}
