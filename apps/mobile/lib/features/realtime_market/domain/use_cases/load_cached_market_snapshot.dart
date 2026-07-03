import 'package:flutter_bloc_app/features/realtime_market/domain/entities/market_feed_snapshot.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/realtime_market_repository.dart';

class LoadCachedMarketSnapshot {
  LoadCachedMarketSnapshot(this._repository);

  final RealtimeMarketRepository _repository;

  Future<MarketFeedSnapshot?> call(final String pairId) =>
      _repository.loadCached(pairId);
}
