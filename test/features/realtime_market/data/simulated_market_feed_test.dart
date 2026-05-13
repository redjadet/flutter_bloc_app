import 'dart:async';
import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/realtime_market/data/simulated_market_feed.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/market_connection_status.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/market_feed_snapshot.dart';
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
  });
}
