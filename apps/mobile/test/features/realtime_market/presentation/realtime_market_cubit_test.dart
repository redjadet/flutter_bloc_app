import 'dart:async';

import 'package:flutter_bloc_app/features/realtime_market/domain/market_connection_status.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/market_feed_snapshot.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/market_stats.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/order_book_level.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/recent_trade.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/realtime_market_repository.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/cubit/realtime_market_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RealtimeMarketCubit', () {
    test('loads cache then applies stream snapshots', () async {
      final MarketFeedSnapshot cached = _snap(last: 50);
      final _FakeRepo repo = _FakeRepo(cached: cached);
      final RealtimeMarketCubit cubit = RealtimeMarketCubit(
        repository: repo,
        pairId: 'btc_usdt',
      );
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.snapshot?.lastPrice, 50);
      expect(
        cubit.state.snapshot?.connection,
        MarketConnectionStatus.reconnecting,
      );
      expect(cubit.state.bootstrapComplete, isTrue);

      repo.emit(_snap(last: 51));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.snapshot?.lastPrice, 51);
      expect(cubit.state.bootstrapComplete, isTrue);

      await cubit.close();
      expect(repo.disposed, isTrue);
    });

    test(
      'without cache, bootstrapComplete stays false until first snapshot',
      () async {
        final _FakeRepo repo = _FakeRepo(cached: null);
        final RealtimeMarketCubit cubit = RealtimeMarketCubit(
          repository: repo,
          pairId: 'btc_usdt',
        );
        await Future<void>.delayed(Duration.zero);
        expect(cubit.state.bootstrapComplete, isFalse);

        repo.emit(_snap(last: 7));
        await Future<void>.delayed(Duration.zero);
        expect(cubit.state.snapshot?.lastPrice, 7);
        expect(cubit.state.bootstrapComplete, isTrue);

        await cubit.close();
      },
    );

    test('still watches feed when loadCached throws', () async {
      final _FakeRepo repo = _FakeRepo(
        cached: null,
        loadCachedError: StateError('hive unavailable'),
      );
      final RealtimeMarketCubit cubit = RealtimeMarketCubit(
        repository: repo,
        pairId: 'btc_usdt',
      );
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.loadErrorMessage, contains('hive unavailable'));
      expect(cubit.state.bootstrapComplete, isTrue);

      repo.emit(_snap(last: 42));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.snapshot?.lastPrice, 42);
      expect(cubit.state.loadErrorMessage, isNull);

      await cubit.close();
    });

    test('reconnect delegates to repository', () async {
      final _FakeRepo repo = _FakeRepo(cached: _snap(last: 1));
      final RealtimeMarketCubit cubit = RealtimeMarketCubit(
        repository: repo,
        pairId: 'btc_usdt',
      );
      await Future<void>.delayed(Duration.zero);
      await cubit.reconnect();
      expect(repo.reconnectCount, 1);
      expect(
        cubit.state.snapshot?.connection,
        MarketConnectionStatus.reconnecting,
      );
      await cubit.close();
    });

    test(
      'stream errors mark cached snapshot offline until reconnect',
      () async {
        final _FakeRepo repo = _FakeRepo(cached: _snap(last: 1));
        final RealtimeMarketCubit cubit = RealtimeMarketCubit(
          repository: repo,
          pairId: 'btc_usdt',
        );
        await Future<void>.delayed(Duration.zero);

        repo.emitError(StateError('feed down'));
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state.loadErrorMessage, contains('feed down'));
        expect(
          cubit.state.snapshot?.connection,
          MarketConnectionStatus.offline,
        );

        await cubit.reconnect();

        expect(cubit.state.loadErrorMessage, isNull);
        expect(
          cubit.state.snapshot?.connection,
          MarketConnectionStatus.reconnecting,
        );
        await cubit.close();
      },
    );
  });
}

MarketFeedSnapshot _snap({required final double last}) => MarketFeedSnapshot(
  pairId: 'btc_usdt',
  lastPrice: last,
  changePct24h: 0,
  connection: MarketConnectionStatus.live,
  bids: const <OrderBookLevel>[
    OrderBookLevel(price: 1, quantity: 1, side: OrderBookSide.bid),
  ],
  asks: const <OrderBookLevel>[
    OrderBookLevel(price: 2, quantity: 1, side: OrderBookSide.ask),
  ],
  recentTrades: const <RecentTrade>[],
  stats: const MarketStats(high24h: 1, low24h: 1, volume24h: 1),
  chartCloses: const <double>[1, 2],
  updatedAt: DateTime.utc(2024),
);

final class _FakeRepo implements RealtimeMarketRepository {
  _FakeRepo({this.cached, this.loadCachedError});

  final MarketFeedSnapshot? cached;
  final Object? loadCachedError;
  final StreamController<MarketFeedSnapshot> _out =
      StreamController<MarketFeedSnapshot>.broadcast();
  var disposed = false;
  var reconnectCount = 0;

  void emit(final MarketFeedSnapshot s) {
    if (!_out.isClosed) {
      _out.add(s);
    }
  }

  void emitError(final Object error) {
    if (!_out.isClosed) {
      _out.addError(error);
    }
  }

  @override
  Future<MarketFeedSnapshot?> loadCached(final String pairId) async {
    if (loadCachedError != null) {
      Error.throwWithStackTrace(loadCachedError!, StackTrace.current);
    }
    return cached;
  }

  @override
  Stream<MarketFeedSnapshot> watch(final String pairId) => _out.stream;

  @override
  Future<void> reconnect(final String pairId) async {
    reconnectCount++;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    await _out.close();
  }
}
