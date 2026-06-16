import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/order_book_level.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/widgets/order_book_panel.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<AppLocalizations> loadL10n(final WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SizedBox.shrink(),
      ),
    );
    await tester.pumpAndSettle();
    return AppLocalizations.of(tester.element(find.byType(SizedBox)));
  }

  testWidgets('OrderBookPanel keeps row keys when levels are new instances', (
    final WidgetTester tester,
  ) async {
    final AppLocalizations l10n = await loadL10n(tester);
    const List<OrderBookLevel> initialBids = <OrderBookLevel>[
      OrderBookLevel(price: 100, quantity: 1, side: OrderBookSide.bid),
      OrderBookLevel(price: 99, quantity: 2, side: OrderBookSide.bid),
    ];
    const List<OrderBookLevel> initialAsks = <OrderBookLevel>[
      OrderBookLevel(price: 101, quantity: 1.5, side: OrderBookSide.ask),
    ];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            height: 400,
            width: 400,
            child: OrderBookPanel(
              bids: initialBids,
              asks: initialAsks,
              l10n: l10n,
              bidFlex: 1,
              askFlex: 1,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Finder bidKey0 = find.byKey(
      const ValueKey<String>('order_book_0_bid_100.0'),
    );
    final Finder askKey0 = find.byKey(
      const ValueKey<String>('order_book_0_ask_101.0'),
    );
    expect(bidKey0, findsOneWidget);
    expect(askKey0, findsOneWidget);

    final List<OrderBookLevel> updatedBids = <OrderBookLevel>[
      const OrderBookLevel(price: 100, quantity: 9, side: OrderBookSide.bid),
      const OrderBookLevel(price: 99, quantity: 2, side: OrderBookSide.bid),
    ];
    const List<OrderBookLevel> updatedAsks = <OrderBookLevel>[
      OrderBookLevel(price: 101, quantity: 3, side: OrderBookSide.ask),
    ];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            height: 400,
            width: 400,
            child: OrderBookPanel(
              bids: updatedBids,
              asks: updatedAsks,
              l10n: l10n,
              bidFlex: 1,
              askFlex: 1,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(bidKey0, findsOneWidget);
    expect(askKey0, findsOneWidget);
  });
}
