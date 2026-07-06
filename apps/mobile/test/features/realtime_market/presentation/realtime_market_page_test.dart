import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/market_connection_status.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/market_feed_snapshot.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/market_stats.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/order_book_level.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/recent_trade.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/realtime_market_repository.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/cubit/realtime_market_cubit.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/pages/realtime_market_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('RealtimeMarketPage shows pair label after first snapshot', (
    final tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;

    final _FakeRepo repo = _FakeRepo(cached: _pageSnap());

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider(
          create: (_) =>
              RealtimeMarketCubit(repository: repo, pairId: 'btc_usdt'),
          child: const RealtimeMarketPage(),
        ),
      ),
    );
    await tester.pump();
    repo.emit(_pageSnap(lastPrice: 123));
    await tester.pump();

    expect(find.text('BTC/USDT'), findsOneWidget);
    expect(find.text('123.00'), findsOneWidget);
  });
}

MarketFeedSnapshot _pageSnap({final double lastPrice = 100}) =>
    MarketFeedSnapshot(
      pairId: 'btc_usdt',
      lastPrice: lastPrice,
      changePct24h: 1.2,
      connection: MarketConnectionStatus.live,
      bids: const <OrderBookLevel>[
        OrderBookLevel(price: 99, quantity: 0.1, side: OrderBookSide.bid),
      ],
      asks: const <OrderBookLevel>[
        OrderBookLevel(price: 101, quantity: 0.2, side: OrderBookSide.ask),
      ],
      recentTrades: <RecentTrade>[
        RecentTrade(
          id: '1',
          price: 100,
          quantity: 0.01,
          isBuy: true,
          at: DateTime.utc(2024),
        ),
      ],
      stats: const MarketStats(high24h: 110, low24h: 90, volume24h: 1_000_000),
      chartCloses: const <double>[100, 101, 102],
      updatedAt: DateTime.utc(2024),
    );

final class _FakeRepo implements RealtimeMarketRepository {
  _FakeRepo({this.cached});

  final MarketFeedSnapshot? cached;
  final StreamController<MarketFeedSnapshot> _out =
      StreamController<MarketFeedSnapshot>.broadcast();

  void emit(final MarketFeedSnapshot s) {
    if (!_out.isClosed) {
      _out.add(s);
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
    await _out.close();
  }
}
