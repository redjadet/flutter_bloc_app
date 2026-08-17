import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/market_feed_snapshot.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/realtime_market_repository.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/cubit/realtime_market_cubit.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/widgets/realtime_market_page_body.dart';
import 'package:flutter_bloc_app/l10n/app_localization_delegates.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

final class _FakeRepo implements RealtimeMarketRepository {
  var reconnectCount = 0;

  @override
  Future<void> dispose() async {}

  @override
  Future<MarketFeedSnapshot?> loadCached(String pairId) async => null;

  @override
  Future<void> reconnect(String pairId) async {
    reconnectCount++;
  }

  @override
  Stream<MarketFeedSnapshot> watch(String pairId) =>
      const Stream<MarketFeedSnapshot>.empty();
}

void main() {
  group('RealtimeMarketLoadErrorBanner', () {
    testWidgets('shows error copy and reconnects on retry', (tester) async {
      final _FakeRepo repository = _FakeRepo();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider(
            create: (_) =>
                RealtimeMarketCubit(repository: repository, pairId: 'btc_usdt'),
            child: Builder(
              builder: (context) => Scaffold(
                body: RealtimeMarketLoadErrorBanner(
                  l10n: AppLocalizations.of(context),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not load market data.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(repository.reconnectCount, 1);
    });
  });
}
