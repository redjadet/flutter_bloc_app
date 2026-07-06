import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/market_connection_status.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/realtime_market_repository.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/use_cases/load_cached_market_snapshot.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/use_cases/reconnect_realtime_market.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/use_cases/watch_realtime_market.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/cubit/realtime_market_state.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_subscription_mixin.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

class RealtimeMarketCubit extends Cubit<RealtimeMarketState>
    with CubitSubscriptionMixin<RealtimeMarketState> {
  RealtimeMarketCubit({
    required final RealtimeMarketRepository repository,
    required final String pairId,
  }) : _repository = repository,
       _loadCached = LoadCachedMarketSnapshot(repository),
       _watch = WatchRealtimeMarket(repository),
       _reconnect = ReconnectRealtimeMarket(repository),
       super(RealtimeMarketState(pairId: pairId)) {
    unawaited(_bootstrap());
  }

  final RealtimeMarketRepository _repository;
  final LoadCachedMarketSnapshot _loadCached;
  final WatchRealtimeMarket _watch;
  final ReconnectRealtimeMarket _reconnect;

  Future<void> _bootstrap() async {
    final String pairId = state.pairId;
    try {
      final cached = await _loadCached(pairId);
      if (isClosed) {
        return;
      }
      if (cached != null) {
        emit(
          state.copyWith(
            snapshot: cached.copyWith(
              connection: MarketConnectionStatus.reconnecting,
            ),
            bootstrapComplete: true,
          ),
        );
      }
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'RealtimeMarketCubit._bootstrap loadCached',
        error,
        stackTrace,
      );
      if (!isClosed) {
        emit(
          state.copyWith(
            loadErrorMessage: error.toString(),
            bootstrapComplete: true,
          ),
        );
      }
    }

    if (isClosed) {
      return;
    }

    _registerMarketWatch(pairId);
  }

  void _registerMarketWatch(final String pairId) {
    try {
      registerSubscription(
        _watch(pairId).listen(
          (final snapshot) {
            if (isClosed) {
              return;
            }
            emit(
              state.copyWith(
                snapshot: snapshot,
                loadErrorMessage: null,
                bootstrapComplete: true,
              ),
            );
          },
          onError: (final Object error, final StackTrace stackTrace) {
            AppLogger.error(
              'RealtimeMarketCubit market stream',
              error,
              stackTrace,
            );
            if (!isClosed) {
              emit(
                state.copyWith(
                  snapshot: state.snapshot?.copyWith(
                    connection: MarketConnectionStatus.offline,
                  ),
                  loadErrorMessage: error.toString(),
                  bootstrapComplete: true,
                ),
              );
            }
          },
        ),
      );
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'RealtimeMarketCubit._registerMarketWatch',
        error,
        stackTrace,
      );
      if (!isClosed) {
        emit(
          state.copyWith(
            loadErrorMessage: error.toString(),
            bootstrapComplete: true,
          ),
        );
      }
    }
  }

  void setSideTab(final RealtimeMarketSideTab tab) {
    if (isClosed || state.sideTab == tab) {
      return;
    }
    emit(state.copyWith(sideTab: tab));
  }

  Future<void> reconnect() async {
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        snapshot: state.snapshot?.copyWith(
          connection: MarketConnectionStatus.reconnecting,
        ),
        loadErrorMessage: null,
      ),
    );
    try {
      await _reconnect(state.pairId);
    } on Object catch (error, stackTrace) {
      AppLogger.error('RealtimeMarketCubit.reconnect', error, stackTrace);
      if (!isClosed) {
        emit(state.copyWith(loadErrorMessage: error.toString()));
      }
    }
  }

  @override
  Future<void> close() async {
    await super.close();
    await _repository.dispose();
  }
}
