import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'counter_api.g.dart';

/// Type-safe REST client for the example counter API.
///
/// Parsing and error handling remain in the counter repository.
@RestApi()
abstract class CounterApi {
  factory CounterApi(final Dio dio, {final String? baseUrl}) = _CounterApi;

  @GET('counter')
  Future<HttpResponse<String>> getCounter(
    @DioOptions() final Options? options,
  );

  @POST('counter')
  Future<HttpResponse<void>> saveCounter(
    @Body() final Map<String, dynamic> body,
    @DioOptions() final Options? options,
  );
}
