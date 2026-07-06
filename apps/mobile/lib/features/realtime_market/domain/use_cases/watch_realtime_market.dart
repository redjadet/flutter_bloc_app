import 'package:flutter_bloc_app/features/realtime_market/domain/market_feed_snapshot.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/realtime_market_repository.dart';

class WatchRealtimeMarket {
  WatchRealtimeMarket(this._repository);

  final RealtimeMarketRepository _repository;

  Stream<MarketFeedSnapshot> call(final String pairId) =>
      _repository.watch(pairId);
}
