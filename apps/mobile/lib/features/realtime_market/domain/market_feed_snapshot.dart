import 'package:flutter_bloc_app/features/realtime_market/domain/market_connection_status.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/market_stats.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/order_book_level.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/recent_trade.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'market_feed_snapshot.freezed.dart';

@freezed
abstract class MarketFeedSnapshot with _$MarketFeedSnapshot {
  const factory MarketFeedSnapshot({
    required final String pairId,
    required final double lastPrice,
    required final double changePct24h,
    required final MarketConnectionStatus connection,
    required final List<OrderBookLevel> bids,
    required final List<OrderBookLevel> asks,
    required final List<RecentTrade> recentTrades,
    required final MarketStats stats,
    required final List<double> chartCloses,
    required final DateTime updatedAt,
  }) = _MarketFeedSnapshot;
}
