import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'countries_graphql_api.g.dart';

/// Type-safe GraphQL client for the countries API.
///
/// Operation-specific methods; parsing and error handling remain in the
/// repository.
@RestApi(baseUrl: 'https://countries.trevorblades.com')
abstract class CountriesGraphqlApi {
  factory CountriesGraphqlApi(final Dio dio, {final String? baseUrl}) =
      _CountriesGraphqlApi;

  @POST('/')
  Future<HttpResponse<String>> postQuery(
    @Body() final Map<String, dynamic> body,
    @DioOptions() final Options? options,
  );
}
