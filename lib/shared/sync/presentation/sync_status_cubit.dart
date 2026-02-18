import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_state.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';

export 'sync_status_state.dart';

class SyncStatusCubit extends Cubit<SyncStatusState> {
  SyncStatusCubit({
    required final NetworkStatusService networkStatusService,
    required final BackgroundSyncCoordinator coordinator,
  }) : _networkStatusService = networkStatusService,
       _coordinator = coordinator,
       super(
         SyncStatusState(
           networkStatus: NetworkStatus.unknown,
           syncStatus: coordinator.currentStatus,
           lastSummary: coordinator.latestSummary,
           history: coordinator.history,
         ),
       ) {
    _networkSubscription = _networkStatusService.statusStream.listen(
      (final status) {
        if (isClosed) {
          return;
        }
        emit(state.copyWith(networkStatus: status));
      },
    );
    _syncSubscription = _coordinator.statusStream.listen(
      (final status) {
        if (isClosed) {
          return;
        }
        emit(state.copyWith(syncStatus: status));
      },
    );
    _summarySubscription = _coordinator.summaryStream.listen(
      (final summary) {
        if (isClosed) {
          return;
        }
        emit(
          state.copyWith(
            lastSummary: summary,
            history: _coordinator.history,
          ),
        );
      },
    );
    unawaited(_seedInitialStatus());
  }

  final NetworkStatusService _networkStatusService;
  final BackgroundSyncCoordinator _coordinator;
  // ignore: cancel_subscriptions - Subscriptions are properly cancelled in close() method
  StreamSubscription<NetworkStatus>? _networkSubscription;
  // ignore: cancel_subscriptions - Subscriptions are properly cancelled in close() method
  StreamSubscription<SyncStatus>? _syncSubscription;
  // ignore: cancel_subscriptions - Subscriptions are properly cancelled in close() method
  StreamSubscription<SyncCycleSummary>? _summarySubscription;

  Future<void> _seedInitialStatus() async {
    final NetworkStatus currentStatus = await _networkStatusService
        .getCurrentStatus();
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        networkStatus: currentStatus,
        syncStatus: _coordinator.currentStatus,
      ),
    );
  }

  Future<void> flush() => _coordinator.flush();

  void ensureStarted() {
    unawaited(_coordinator.ensureStarted());
  }

  @override
  Future<void> close() async {
    // Nullify references before canceling to prevent race conditions
    final StreamSubscription<NetworkStatus>? networkSub = _networkSubscription;
    _networkSubscription = null;
    final StreamSubscription<SyncStatus>? syncSub = _syncSubscription;
    _syncSubscription = null;
    final StreamSubscription<SyncCycleSummary>? summarySub =
        _summarySubscription;
    _summarySubscription = null;

    await networkSub?.cancel();
    await syncSub?.cancel();
    await summarySub?.cancel();
    return super.close();
  }
}
