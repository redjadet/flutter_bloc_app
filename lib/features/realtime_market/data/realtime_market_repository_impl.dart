import 'dart:async';

import 'package:flutter_bloc_app/features/realtime_market/data/realtime_market_local_data_source.dart';
import 'package:flutter_bloc_app/features/realtime_market/data/simulated_market_feed.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/market_feed_snapshot.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/realtime_market_repository.dart';

/// Caps list sizes before persistence and downstream UI.
abstract final class RealtimeMarketSnapshotCaps {
  static const int orderBookPerSide = 12;
  static const int recentTradesMax = 50;
  static const int chartPointsMax = 64;
}

/// Simulated feed + Hive cache; emits throttled snapshots from [SimulatedMarketFeed].
class RealtimeMarketRepositoryImpl implements RealtimeMarketRepository {
  RealtimeMarketRepositoryImpl({
    required final RealtimeMarketLocalDataSource localDataSource,
    required this._feed,
  }) : _local = localDataSource;

  final RealtimeMarketLocalDataSource _local;
  final SimulatedMarketFeed _feed;

  final StreamController<MarketFeedSnapshot> _out =
      StreamController<MarketFeedSnapshot>.broadcast();

  StreamSubscription<MarketFeedSnapshot>? _feedSub;
  bool _disposed = false;
  final List<Future<void>> _inflightPersists = <Future<void>>[];

  /// Ensures only one [_restartWatchBody] runs at a time so overlapping
  /// `watch`/`reconnect`/`dispose` cannot orphan feed subscriptions.
  Future<void> _restartSerial = Future<void>.value();

  static MarketFeedSnapshot capSnapshot(final MarketFeedSnapshot raw) {
    final trades =
        raw.recentTrades.length > RealtimeMarketSnapshotCaps.recentTradesMax
        ? raw.recentTrades
              .take(RealtimeMarketSnapshotCaps.recentTradesMax)
              .toList()
        : raw.recentTrades;
    final chart =
        raw.chartCloses.length > RealtimeMarketSnapshotCaps.chartPointsMax
        ? raw.chartCloses.sublist(
            raw.chartCloses.length - RealtimeMarketSnapshotCaps.chartPointsMax,
          )
        : raw.chartCloses;
    return raw.copyWith(
      bids: raw.bids.take(RealtimeMarketSnapshotCaps.orderBookPerSide).toList(),
      asks: raw.asks.take(RealtimeMarketSnapshotCaps.orderBookPerSide).toList(),
      recentTrades: trades,
      chartCloses: chart,
    );
  }

  @override
  Future<MarketFeedSnapshot?> loadCached(final String pairId) =>
      _local.loadCached(pairId);

  @override
  Stream<MarketFeedSnapshot> watch(final String pairId) {
    if (_disposed) {
      return const Stream<MarketFeedSnapshot>.empty();
    }
    unawaited(_restartWatch(pairId));
    return _out.stream;
  }

  @override
  Future<void> reconnect(final String pairId) {
    if (_disposed) {
      return Future<void>.value();
    }
    return _restartWatch(pairId);
  }

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    try {
      await _restartSerial;
    } on Object {
      // Keep teardown moving if a prior restart failed mid-chain.
    }
    await _feedSub?.cancel();
    _feedSub = null;
    if (_inflightPersists.isNotEmpty) {
      await Future.wait(List<Future<void>>.from(_inflightPersists));
    }
    await _out.close();
  }

  Future<MarketFeedSnapshot> _persistSnapshotIfActive(
    final String pairId,
    final MarketFeedSnapshot capped,
  ) async {
    if (_disposed) {
      return capped;
    }
    final Future<void> persist = _local.saveSnapshot(pairId, capped);
    _inflightPersists.add(persist);
    try {
      await persist;
    } finally {
      _inflightPersists.remove(persist);
    }
    return capped;
  }

  Future<void> _restartWatch(final String pairId) {
    return _restartSerial = _restartSerial.then<void>(
      (_) => _restartWatchBody(pairId),
      onError: (_) {},
    );
  }

  Future<void> _restartWatchBody(final String pairId) async {
    if (_disposed) {
      return;
    }
    await _feedSub?.cancel();
    _feedSub = null;
    if (_inflightPersists.isNotEmpty) {
      await Future.wait(List<Future<void>>.from(_inflightPersists));
    }
    if (_disposed) {
      return;
    }
    // asyncExpand (not asyncMap) so each persist completes before the next tick
    // starts; overlapping asyncMap work could let an older snapshot overwrite a
    // newer Hive row after a stale read in [RealtimeMarketLocalDataSource].
    final StreamSubscription<MarketFeedSnapshot> next = _feed
        .watch(pairId)
        .asyncExpand(
          (final raw) => Stream<MarketFeedSnapshot>.fromFuture(
            _persistSnapshotIfActive(pairId, capSnapshot(raw)),
          ),
        )
        .listen(
          (e) {
            if (!_out.isClosed) {
              _out.add(e);
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!_out.isClosed) {
              _out.addError(error, stackTrace);
            }
          },
        );
    if (_disposed) {
      await next.cancel();
      return;
    }
    _feedSub = next;
  }
}
