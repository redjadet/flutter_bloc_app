import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/market_connection_status.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/market_feed_snapshot.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/market_stats.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/order_book_level.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/recent_trade.dart';

part 'simulated_market_feed_state.part.dart';

/// High-frequency simulated crypto book (demo only; no exchange).
class SimulatedMarketFeed {
  SimulatedMarketFeed({
    required this._random,
    required this._timerService,
    this.fastTick = const Duration(milliseconds: 20),
    this.emitInterval = const Duration(milliseconds: 80),
    final DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final Random _random;
  final TimerService _timerService;
  final Duration fastTick;
  final Duration emitInterval;
  final DateTime Function() _clock;

  /// Single-subscription stream; cancel subscription to stop timers.
  ///
  /// When [resumeFrom] is set (e.g. Hive cache on reconnect), the simulator
  /// continues from that snapshot instead of resetting to [_SimState.initial].
  Stream<MarketFeedSnapshot> watch(
    final String pairId, {
    final MarketFeedSnapshot? resumeFrom,
  }) {
    var state = resumeFrom != null
        ? _SimState.fromSnapshot(resumeFrom)
        : _SimState.initial(pairId: pairId);
    var tradeSeq = 0;
    TimerDisposable? zeroShot;
    TimerDisposable? fastHandle;
    TimerDisposable? emitHandle;

    void disposeTimers() {
      zeroShot?.dispose();
      fastHandle?.dispose();
      emitHandle?.dispose();
      zeroShot = null;
      fastHandle = null;
      emitHandle = null;
    }

    void micro() {
      state = state.nudgePrices(_random);
    }

    late final StreamController<MarketFeedSnapshot> controller;

    void emitInner() {
      tradeSeq += 1;
      state = state.withNewTrade(
        seq: tradeSeq,
        random: _random,
        clock: _clock,
      );
      if (!controller.isClosed) {
        controller.add(state.toSnapshot(_clock()));
      }
    }

    controller = StreamController<MarketFeedSnapshot>(
      onCancel: () {
        disposeTimers();
        if (!controller.isClosed) {
          unawaited(controller.close());
        }
      },
    );

    zeroShot = _timerService.runOnce(Duration.zero, () {
      if (controller.isClosed) {
        return;
      }
      emitInner();
      fastHandle = _timerService.periodic(fastTick, micro);
      emitHandle = _timerService.periodic(emitInterval, emitInner);
    });

    return controller.stream;
  }
}
