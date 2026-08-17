import 'package:flutter_bloc_app/features/realtime_market/domain/market_connection_status.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/market_stats.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/order_book_level.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/recent_trade.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'market_feed_snapshot.freezed.dart';

@freezed
abstract class MarketFeedSnapshot with _$MarketFeedSnapshot {
  const factory MarketFeedSnapshot({
    required String pairId,
    required double lastPrice,
    required double changePct24h,
    required MarketConnectionStatus connection,
    required List<OrderBookLevel> bids,
    required List<OrderBookLevel> asks,
    required List<RecentTrade> recentTrades,
    required MarketStats stats,
    required List<double> chartCloses,
    required DateTime updatedAt,
  }) = _MarketFeedSnapshot;
}
