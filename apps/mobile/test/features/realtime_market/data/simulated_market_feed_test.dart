import 'dart:async';
import 'dart:math';
import 'package:core/core.dart';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_bloc_app/features/realtime_market/data/simulated_market_feed.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/market_connection_status.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/market_feed_snapshot.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/market_stats.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/order_book_level.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/recent_trade.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SimulatedMarketFeed', () {
    test('first snapshot is stable for fixed clock and seed', () {
      fakeAsync((final FakeAsync async) {
        final SimulatedMarketFeed feed = SimulatedMarketFeed(
          random: Random(42),
          timerService: DefaultTimerService(),
          clock: () => DateTime.utc(2024, 1, 1),
        );
        MarketFeedSnapshot? first;
        final StreamSubscription<MarketFeedSnapshot> sub = feed
            .watch('btc_usdt')
            .listen((final MarketFeedSnapshot s) => first = s);
        async.elapse(Duration.zero);
        expect(first, isNotNull);
        final MarketFeedSnapshot s = first!;
        expect(s.pairId, 'btc_usdt');
        expect(s.lastPrice, 43250);
        expect(s.connection, MarketConnectionStatus.live);
        expect(s.bids.length, 16);
        expect(s.asks.length, 16);
        expect(s.recentTrades.length, 1);
        sub.cancel();
        async.flushMicrotasks();
      });
    });

    test('resume continues trade ids after cached recent trades', () {
      fakeAsync((final FakeAsync async) {
        final SimulatedMarketFeed feed = SimulatedMarketFeed(
          random: Random(1),
          timerService: DefaultTimerService(),
          clock: () => DateTime.utc(2024, 1, 1),
        );
        MarketFeedSnapshot? first;
        final StreamSubscription<MarketFeedSnapshot> sub = feed
            .watch(
              'btc_usdt',
              resumeFrom: MarketFeedSnapshot(
                pairId: 'btc_usdt',
                lastPrice: 44000,
                changePct24h: 0,
                connection: MarketConnectionStatus.live,
                bids: <OrderBookLevel>[],
                asks: <OrderBookLevel>[],
                recentTrades: <RecentTrade>[
                  RecentTrade(
                    id: 't5',
                    price: 44000,
                    quantity: 1,
                    isBuy: true,
                    at: DateTime.utc(2024, 1, 1, 9),
                  ),
                  RecentTrade(
                    id: 't3',
                    price: 43900,
                    quantity: 0.5,
                    isBuy: false,
                    at: DateTime.utc(2024, 1, 1, 8),
                  ),
                ],
                stats: MarketStats(high24h: 44000, low24h: 43900, volume24h: 1),
                chartCloses: <double>[43900, 44000],
                updatedAt: DateTime.utc(2024, 1, 1, 10),
              ),
            )
            .listen((final MarketFeedSnapshot s) => first = s);
        async.elapse(Duration.zero);

        expect(first, isNotNull);
        expect(first!.recentTrades.first.id, 't6');
        expect(
          first!.recentTrades.map((final RecentTrade t) => t.id).toSet().length,
          first!.recentTrades.length,
        );
        sub.cancel();
        async.flushMicrotasks();
      });
    });

    test('resume snapshot with full loss keeps finite prices', () {
      fakeAsync((final FakeAsync async) {
        final SimulatedMarketFeed feed = SimulatedMarketFeed(
          random: Random(1),
          timerService: DefaultTimerService(),
          clock: () => DateTime.utc(2024, 1, 1),
        );
        MarketFeedSnapshot? first;
        final StreamSubscription<MarketFeedSnapshot> sub = feed
            .watch(
              'btc_usdt',
              resumeFrom: MarketFeedSnapshot(
                pairId: 'btc_usdt',
                lastPrice: 1,
                changePct24h: -100,
                connection: MarketConnectionStatus.live,
                bids: <OrderBookLevel>[],
                asks: <OrderBookLevel>[],
                recentTrades: <RecentTrade>[],
                stats: MarketStats(high24h: 1, low24h: 1, volume24h: 1),
                chartCloses: <double>[1],
                updatedAt: DateTime(2024),
              ),
            )
            .listen((final MarketFeedSnapshot s) => first = s);
        async.elapse(Duration.zero);

        expect(first, isNotNull);
        expect(first!.lastPrice.isFinite, isTrue);
        expect(first!.changePct24h.isFinite, isTrue);
        sub.cancel();
        async.flushMicrotasks();
      });
    });
  });
}
