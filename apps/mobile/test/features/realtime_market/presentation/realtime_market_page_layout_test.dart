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

/// Matches [SimulatedMarketFeed] initial depth (16×16) inside the fixed-height
/// order book — catches [RenderFlex] overflow regressions on phone layouts.
MarketFeedSnapshot _denseSimStyleSnapshot() {
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
  return MarketFeedSnapshot(
    pairId: 'btc_usdt',
    lastPrice: price,
    changePct24h: 0.5,
    connection: MarketConnectionStatus.live,
    bids: bids,
    asks: asks,
    recentTrades: <RecentTrade>[
      RecentTrade(
        id: '1',
        price: price,
        quantity: 0.01,
        isBuy: true,
        at: DateTime.utc(2024),
      ),
    ],
    stats: const MarketStats(
      high24h: 44000,
      low24h: 42000,
      volume24h: 1_000_000,
    ),
    chartCloses: chart,
    updatedAt: DateTime.utc(2024),
  );
}

void main() {
  Future<void> pumpMarketPage(
    final WidgetTester tester, {
    required final Size size,
    final double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;

    final _FakeRepo repo = _FakeRepo(cached: _denseSimStyleSnapshot());

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScale),
          ),
          child: BlocProvider(
            create: (_) =>
                RealtimeMarketCubit(repository: repo, pairId: 'btc_usdt'),
            child: const RealtimeMarketPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  testWidgets(
    'RealtimeMarketPage has no flex overflow on phone with full sim book',
    (final tester) async {
      final originalOnError = FlutterError.onError;
      final errors = <FlutterErrorDetails>[];
      FlutterError.onError = (final FlutterErrorDetails details) {
        errors.add(details);
        originalOnError?.call(details);
      };
      addTearDown(() {
        FlutterError.onError = originalOnError;
      });

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await pumpMarketPage(tester, size: const Size(390, 844));

      final Iterable<FlutterErrorDetails> overflows = errors.where(
        (final FlutterErrorDetails e) =>
            e.exceptionAsString().contains('overflow'),
      );
      expect(
        overflows,
        isEmpty,
        reason: overflows.map((e) => e.exceptionAsString()).join('\n---\n'),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('RealtimeMarketPage adapts on compact and desktop viewports', (
    final tester,
  ) async {
    final originalOnError = FlutterError.onError;
    final errors = <FlutterErrorDetails>[];
    FlutterError.onError = (final FlutterErrorDetails details) {
      errors.add(details);
      originalOnError?.call(details);
    };
    addTearDown(() {
      FlutterError.onError = originalOnError;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    for (final (:size, :textScale) in <({Size size, double textScale})>[
      (size: Size(360, 740), textScale: 1.4),
      (size: Size(1280, 900), textScale: 1),
    ]) {
      errors.clear();
      await pumpMarketPage(tester, size: size, textScale: textScale);
      final Iterable<FlutterErrorDetails> overflows = errors.where(
        (final FlutterErrorDetails e) =>
            e.exceptionAsString().contains('overflow'),
      );
      expect(
        overflows,
        isEmpty,
        reason:
            'viewport=$size textScale=$textScale\n'
            '${overflows.map((e) => e.exceptionAsString()).join('\n---\n')}',
      );
      expect(tester.takeException(), isNull);
    }
  });
}

final class _FakeRepo implements RealtimeMarketRepository {
  _FakeRepo({this.cached});

  final MarketFeedSnapshot? cached;
  final StreamController<MarketFeedSnapshot> _out =
      StreamController<MarketFeedSnapshot>.broadcast();

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
