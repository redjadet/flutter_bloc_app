import 'package:flutter_bloc_app/features/realtime_market/domain/realtime_market_repository.dart';

class ReconnectRealtimeMarket {
  ReconnectRealtimeMarket(this._repository);

  final RealtimeMarketRepository _repository;

  Future<void> call(final String pairId) => _repository.reconnect(pairId);
}
