part of 'simulated_market_feed.dart';

class _SimState {
  _SimState({
    required this.pairId,
    required this.lastPrice,
    required this.open24,
    required this.bids,
    required this.asks,
    required this.recentTrades,
    required this.stats,
    required this.chartCloses,
  });

  factory _SimState.initial({required final String pairId}) {
    const double price = 43250;
    const double open = 43000;
    final List<OrderBookLevel> bids = <OrderBookLevel>[
      for (var i = 0; i < 16; i++)
        OrderBookLevel(
          price: price - 1 - i * 2.5,
          quantity: 0.5 + i * 0.12,
          side: OrderBookSide.bid,
        ),
    ];
    final List<OrderBookLevel> asks = <OrderBookLevel>[
      for (var i = 0; i < 16; i++)
        OrderBookLevel(
          price: price + 1 + i * 2.5,
          quantity: 0.48 + i * 0.11,
          side: OrderBookSide.ask,
        ),
    ];
    final List<double> chart = <double>[
      for (var i = 0; i < 30; i++) open + (price - open) * (i / 29),
    ];
    return _SimState(
      pairId: pairId,
      lastPrice: price,
      open24: open,
      bids: bids,
      asks: asks,
      recentTrades: <RecentTrade>[],
      stats: const MarketStats(
        high24h: 43370,
        low24h: 42920,
        volume24h: 128000,
      ),
      chartCloses: chart,
    );
  }

  final String pairId;
  final double lastPrice;
  final double open24;
  final List<OrderBookLevel> bids;
  final List<OrderBookLevel> asks;
  final List<RecentTrade> recentTrades;
  final MarketStats stats;
  final List<double> chartCloses;

  _SimState nudgePrices(final Random random) {
    final double delta = (random.nextDouble() - 0.5) * 8;
    final double next = (lastPrice + delta).clamp(open24 * 0.95, open24 * 1.08);
    final List<OrderBookLevel> nb = bids
        .map(
          (b) => OrderBookLevel(
            price: (b.price + delta * 0.15).clamp(1, double.infinity),
            quantity: (b.quantity + (random.nextDouble() - 0.5) * 0.05).clamp(
              0.01,
              999,
            ),
            side: OrderBookSide.bid,
          ),
        )
        .toList();
    final List<OrderBookLevel> na = asks
        .map(
          (a) => OrderBookLevel(
            price: (a.price + delta * 0.15).clamp(1, double.infinity),
            quantity: (a.quantity + (random.nextDouble() - 0.5) * 0.05).clamp(
              0.01,
              999,
            ),
            side: OrderBookSide.ask,
          ),
        )
        .toList();
    return _SimState(
      pairId: pairId,
      lastPrice: next,
      open24: open24,
      bids: nb..sort((final a, final b) => b.price.compareTo(a.price)),
      asks: na..sort((final a, final b) => a.price.compareTo(b.price)),
      recentTrades: recentTrades,
      stats: stats,
      chartCloses: chartCloses,
    );
  }

  _SimState withNewTrade({
    required final int seq,
    required final Random random,
    required final DateTime Function() clock,
  }) {
    final bool isBuy = random.nextBool();
    final double qty = 0.01 + random.nextDouble() * 0.5;
    final trade = RecentTrade(
      id: 't$seq',
      price: lastPrice,
      quantity: qty,
      isBuy: isBuy,
      at: clock(),
    );
    final List<RecentTrade> nextTrades = <RecentTrade>[trade, ...recentTrades];
    final List<double> nextChart = <double>[...chartCloses, lastPrice];
    return _SimState(
      pairId: pairId,
      lastPrice: lastPrice,
      open24: open24,
      bids: bids,
      asks: asks,
      recentTrades: nextTrades,
      stats: MarketStats(
        high24h: lastPrice > stats.high24h ? lastPrice : stats.high24h,
        low24h: lastPrice < stats.low24h ? lastPrice : stats.low24h,
        volume24h: stats.volume24h + qty * 1000,
      ),
      chartCloses: nextChart,
    );
  }

  MarketFeedSnapshot toSnapshot(final DateTime now) {
    final double changePct = ((lastPrice - open24) / open24) * 100;
    return MarketFeedSnapshot(
      pairId: pairId,
      lastPrice: lastPrice,
      changePct24h: changePct,
      connection: MarketConnectionStatus.live,
      bids: bids,
      asks: asks,
      recentTrades: recentTrades,
      stats: stats,
      chartCloses: chartCloses,
      updatedAt: now,
    );
  }
}
