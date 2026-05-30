import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/realtime_market/data/realtime_market_local_data_source.dart';
import 'package:flutter_bloc_app/features/realtime_market/data/realtime_market_repository_impl.dart';
import 'package:flutter_bloc_app/features/realtime_market/data/simulated_market_feed.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/market_connection_status.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/market_feed_snapshot.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/market_stats.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/order_book_level.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/recent_trade.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_helpers.dart' as test_helpers;

void main() {
  group('RealtimeMarketRepositoryImpl', () {
    late HiveService hiveService;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await test_helpers.setupHiveForTesting();
    });

    setUp(() async {
      hiveService = await test_helpers.createHiveService();
    });

    tearDown(() async {
      await test_helpers.cleanupHiveBoxes(<String>['realtime_market_v1']);
    });

    test('capSnapshot enforces book, trades, and chart caps', () {
      final List<OrderBookLevel> bids = <OrderBookLevel>[
        for (var i = 0; i < 20; i++)
          OrderBookLevel(
            price: 100 - i.toDouble(),
            quantity: 1,
            side: OrderBookSide.bid,
          ),
      ];
      final List<RecentTrade> trades = <RecentTrade>[
        for (var i = 0; i < 60; i++)
          RecentTrade(
            id: '$i',
            price: 1,
            quantity: 1,
            isBuy: true,
            at: DateTime.utc(2024),
          ),
      ];
      final List<double> chart = List<double>.generate(
        80,
        (final i) => i.toDouble(),
      );
      final MarketFeedSnapshot raw = MarketFeedSnapshot(
        pairId: 'btc_usdt',
        lastPrice: 1,
        changePct24h: 0,
        connection: MarketConnectionStatus.live,
        bids: bids,
        asks: bids,
        recentTrades: trades,
        stats: const MarketStats(high24h: 1, low24h: 1, volume24h: 1),
        chartCloses: chart,
        updatedAt: DateTime.utc(2024),
      );
      final MarketFeedSnapshot capped =
          RealtimeMarketRepositoryImpl.capSnapshot(raw);
      expect(capped.bids.length, 12);
      expect(capped.asks.length, 12);
      expect(capped.recentTrades.length, 50);
      expect(capped.chartCloses.length, 64);
    });

    test('saveSnapshot does not overwrite newer cached row with older updatedAt',
        () async {
      final RealtimeMarketLocalDataSource local = RealtimeMarketLocalDataSource(
        hiveService: hiveService,
      );
      final MarketFeedSnapshot newer = _sampleSnapshot(
        lastPrice: 200,
        updatedAt: DateTime.utc(2024, 6, 2),
      );
      final MarketFeedSnapshot older = _sampleSnapshot(
        lastPrice: 100,
        updatedAt: DateTime.utc(2024, 6, 1),
      );
      await local.saveSnapshot('btc_usdt', newer);
      await local.saveSnapshot('btc_usdt', older);
      final MarketFeedSnapshot? cached = await local.loadCached('btc_usdt');
      expect(cached?.lastPrice, 200);
    });

    test('loadCached returns null for malformed Hive payload', () async {
      final RealtimeMarketLocalDataSource local = RealtimeMarketLocalDataSource(
        hiveService: hiveService,
      );
      final box = await local.getBox();
      await box.put(
        RealtimeMarketLocalDataSource.snapshotKey('btc_usdt'),
        <String, Object?>{'invalid': true},
      );
      expect(await local.loadCached('btc_usdt'), isNull);
    });

    test('watch persists capped snapshot to Hive', () async {
      final RealtimeMarketLocalDataSource local = RealtimeMarketLocalDataSource(
        hiveService: hiveService,
      );
      final SimulatedMarketFeed feed = SimulatedMarketFeed(
        random: Random(42),
        timerService: DefaultTimerService(),
        clock: () => DateTime.utc(2024, 6, 1, 12),
      );
      final RealtimeMarketRepositoryImpl repo = RealtimeMarketRepositoryImpl(
        localDataSource: local,
        feed: feed,
      );
      final MarketFeedSnapshot s = await repo
          .watch('btc_usdt')
          .first
          .timeout(const Duration(seconds: 2));
      expect(s.bids.length, 12);
      expect(s.asks.length, 12);
      final MarketFeedSnapshot? cached = await repo.loadCached('btc_usdt');
      expect(cached, isNotNull);
      expect(cached!.bids.length, 12);
      await repo.dispose();
    });

    test('reconnect does not replace richer cached snapshot with feed bootstrap',
        () async {
      final RealtimeMarketLocalDataSource local = RealtimeMarketLocalDataSource(
        hiveService: hiveService,
      );
      final MarketFeedSnapshot rich = _sampleSnapshot(
        lastPrice: 44000,
        updatedAt: DateTime.utc(2024, 6, 1, 10),
      ).copyWith(
        recentTrades: <RecentTrade>[
          RecentTrade(
            id: 't1',
            price: 44000,
            quantity: 1,
            isBuy: true,
            at: DateTime.utc(2024, 6, 1, 9),
          ),
        ],
        chartCloses: <double>[43000, 43500, 44000],
      );
      await local.saveSnapshot('btc_usdt', rich);

      final SimulatedMarketFeed feed = SimulatedMarketFeed(
        random: Random(3),
        timerService: DefaultTimerService(),
        clock: () => DateTime.utc(2024, 6, 1, 12),
      );
      final RealtimeMarketRepositoryImpl repo = RealtimeMarketRepositoryImpl(
        localDataSource: local,
        feed: feed,
      );
      final List<MarketFeedSnapshot> out = <MarketFeedSnapshot>[];
      final StreamSubscription<MarketFeedSnapshot> sub = repo
          .watch('btc_usdt')
          .listen(out.add);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await repo.reconnect('btc_usdt');
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await sub.cancel();
      await repo.dispose();

      final MarketFeedSnapshot? cached = await local.loadCached('btc_usdt');
      expect(cached, isNotNull);
      expect(cached!.recentTrades.length, greaterThanOrEqualTo(1));
      expect(cached.chartCloses.length, greaterThanOrEqualTo(3));
      expect(cached.lastPrice, rich.lastPrice);
    });

    test('reconnect restarts feed without throwing', () async {
      final RealtimeMarketLocalDataSource local = RealtimeMarketLocalDataSource(
        hiveService: hiveService,
      );
      final SimulatedMarketFeed feed = SimulatedMarketFeed(
        random: Random(1),
        timerService: DefaultTimerService(),
        clock: () => DateTime.utc(2024),
      );
      final RealtimeMarketRepositoryImpl repo = RealtimeMarketRepositoryImpl(
        localDataSource: local,
        feed: feed,
      );
      final List<MarketFeedSnapshot> out = <MarketFeedSnapshot>[];
      final StreamSubscription<MarketFeedSnapshot> sub = repo
          .watch('btc_usdt')
          .listen(out.add);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await repo.reconnect('btc_usdt');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(out, isNotEmpty);
      await sub.cancel();
      await repo.dispose();
    });

    test('dispose stops outbound stream', () async {
      final RealtimeMarketLocalDataSource local = RealtimeMarketLocalDataSource(
        hiveService: hiveService,
      );
      final SimulatedMarketFeed feed = SimulatedMarketFeed(
        random: Random(2),
        timerService: DefaultTimerService(),
      );
      final RealtimeMarketRepositoryImpl repo = RealtimeMarketRepositoryImpl(
        localDataSource: local,
        feed: feed,
      );
      final StreamSubscription<MarketFeedSnapshot> sub = repo
          .watch('btc_usdt')
          .listen((_) {});
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await repo.dispose();
      await sub.cancel();
      await expectLater(repo.watch('btc_usdt'), emitsDone);
    });
  });
}

MarketFeedSnapshot _sampleSnapshot({
  required final double lastPrice,
  required final DateTime updatedAt,
}) {
  return MarketFeedSnapshot(
    pairId: 'btc_usdt',
    lastPrice: lastPrice,
    changePct24h: 0,
    connection: MarketConnectionStatus.live,
    bids: const <OrderBookLevel>[],
    asks: const <OrderBookLevel>[],
    recentTrades: const <RecentTrade>[],
    stats: const MarketStats(high24h: 1, low24h: 1, volume24h: 1),
    chartCloses: const <double>[1],
    updatedAt: updatedAt,
  );
}
