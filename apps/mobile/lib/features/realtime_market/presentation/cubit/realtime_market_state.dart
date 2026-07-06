import 'package:flutter_bloc_app/features/realtime_market/domain/market_feed_snapshot.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'realtime_market_state.freezed.dart';

/// Which side of the book the segmented control highlights (demo UX).
enum RealtimeMarketSideTab { bids, asks }

@freezed
abstract class RealtimeMarketState with _$RealtimeMarketState {
  const factory RealtimeMarketState({
    required final String pairId,
    final MarketFeedSnapshot? snapshot,
    @Default(false) final bool bootstrapComplete,
    final String? loadErrorMessage,
    @Default(RealtimeMarketSideTab.bids) final RealtimeMarketSideTab sideTab,
  }) = _RealtimeMarketState;
}
