import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'coingecko_api.g.dart';

/// Type-safe REST client for CoinGecko market chart API.
///
/// Parsing and cache remain in the chart repository.
@RestApi(baseUrl: 'https://api.coingecko.com/api/v3/')
abstract class CoingeckoApi {
  factory CoingeckoApi(final Dio dio, {final String? baseUrl}) = _CoingeckoApi;

  @GET('coins/bitcoin/market_chart')
  Future<String> getBitcoinMarketChart(
    @Queries() final Map<String, String> query,
    @Header('Accept') final String accept,
  );
}
