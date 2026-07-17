import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/market_connection_status.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/market_feed_snapshot.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/market_stats.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/order_book_level.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/realtime_market_repository.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/recent_trade.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/cubit/realtime_market_cubit.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/cubit/realtime_market_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/memory/leak_safe_test_widgets.dart';

/// Realtime watch → emit → provider/cubit teardown without full-page chart noise.
///
/// Full RealtimeMarketPage + fl_chart hangs under leak_tracker finalization.
/// [BlocProvider.create] owns cubit close (which also disposes the repository).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  leakSafeTestWidgets(
    'realtime market mount emit teardown is leak-safe',
    (final tester) async {
      final _FakeRepo repo = _FakeRepo(cached: _snap());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<RealtimeMarketCubit>(
            create: (_) => RealtimeMarketCubit(repository: repo, pairId: 'btc_usdt'),
            child: BlocBuilder<RealtimeMarketCubit, RealtimeMarketState>(
              builder: (final BuildContext context, final RealtimeMarketState state) {
                final double? price = state.snapshot?.lastPrice;
                return Text(price == null ? 'waiting' : 'live:${price.toInt()}');
              },
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('live:100'), findsOneWidget);

      repo.emit(_snap(lastPrice: 123));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('live:123'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    },
    ignoredNotDisposedClasses: <String>[...memoryLeakHarnessLayerClasses, 'TextPainter'],
  );
}

MarketFeedSnapshot _snap({final double lastPrice = 100}) => MarketFeedSnapshot(
  pairId: 'btc_usdt',
  lastPrice: lastPrice,
  changePct24h: 1.2,
  connection: MarketConnectionStatus.live,
  bids: const <OrderBookLevel>[OrderBookLevel(price: 99, quantity: 0.1, side: OrderBookSide.bid)],
  asks: const <OrderBookLevel>[OrderBookLevel(price: 101, quantity: 0.2, side: OrderBookSide.ask)],
  recentTrades: <RecentTrade>[
    RecentTrade(id: '1', price: 100, quantity: 0.01, isBuy: true, at: DateTime.utc(2024)),
  ],
  stats: const MarketStats(high24h: 110, low24h: 90, volume24h: 1_000_000),
  chartCloses: const <double>[100, 101, 102],
  updatedAt: DateTime.utc(2024),
);

final class _FakeRepo implements RealtimeMarketRepository {
  _FakeRepo({this.cached});

  final MarketFeedSnapshot? cached;
  // sync: so emit reaches the cubit before the next pump assertion.
  final StreamController<MarketFeedSnapshot> _out = StreamController<MarketFeedSnapshot>.broadcast(
    sync: true,
  );

  void emit(final MarketFeedSnapshot snapshot) {
    if (!_out.isClosed) {
      _out.add(snapshot);
    }
  }

  @override
  Future<MarketFeedSnapshot?> loadCached(final String pairId) async => cached;

  @override
  Stream<MarketFeedSnapshot> watch(final String pairId) => _out.stream;

  @override
  Future<void> reconnect(final String pairId) async {}

  @override
  Future<void> dispose() async {
    if (!_out.isClosed) {
      await _out.close();
    }
  }
}
