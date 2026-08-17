import 'package:flutter_bloc_app/features/realtime_market/domain/market_feed_snapshot.dart';

/// Default trading pair for the demo feed.
const String kDefaultRealtimeMarketPairId = 'btc_usdt';

/// Read + watch simulated market snapshots with Hive persistence.
abstract class RealtimeMarketRepository {
  Future<MarketFeedSnapshot?> loadCached(String pairId);

  Stream<MarketFeedSnapshot> watch(String pairId);

  Future<void> reconnect(String pairId);

  Future<void> dispose();
}
