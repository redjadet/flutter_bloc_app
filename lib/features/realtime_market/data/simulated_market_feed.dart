import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/market_connection_status.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/market_feed_snapshot.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/market_stats.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/order_book_level.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/recent_trade.dart';

/// High-frequency simulated crypto book (demo only; no exchange).
class SimulatedMarketFeed {
  SimulatedMarketFeed({
    required this._random,
    required this._timerService,
    this.fastTick = const Duration(milliseconds: 20),
    this.emitInterval = const Duration(milliseconds: 80),
    final DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final Random _random;
  final TimerService _timerService;
  final Duration fastTick;
  final Duration emitInterval;
  final DateTime Function() _clock;

  /// Single-subscription stream; cancel subscription to stop timers.
  Stream<MarketFeedSnapshot> watch(final String pairId) {
    _SimState state = _SimState.initial(pairId: pairId);
    var tradeSeq = 0;
    TimerDisposable? zeroShot;
    TimerDisposable? fastHandle;
    TimerDisposable? emitHandle;

    void disposeTimers() {
      zeroShot?.dispose();
      fastHandle?.dispose();
      emitHandle?.dispose();
      zeroShot = null;
      fastHandle = null;
      emitHandle = null;
    }

    void micro() {
      state = state.nudgePrices(_random);
    }

    late final StreamController<MarketFeedSnapshot> controller;

    void emitInner() {
      tradeSeq += 1;
      state = state.withNewTrade(
        seq: tradeSeq,
        random: _random,
        clock: _clock,
      );
      if (!controller.isClosed) {
        controller.add(state.toSnapshot(_clock()));
      }
    }

    controller = StreamController<MarketFeedSnapshot>(
      onCancel: () {
        disposeTimers();
        if (!controller.isClosed) {
          unawaited(controller.close());
        }
      },
    );

    zeroShot = _timerService.runOnce(Duration.zero, () {
      if (controller.isClosed) {
        return;
      }
      emitInner();
      fastHandle = _timerService.periodic(fastTick, micro);
      emitHandle = _timerService.periodic(emitInterval, emitInner);
    });

    return controller.stream;
  }
}

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
