import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';

class SyncStatusState extends Equatable {
  const SyncStatusState({
    required this.networkStatus,
    required this.syncStatus,
    this.lastSummary,
    this.history = const <SyncCycleSummary>[],
  });

  final NetworkStatus networkStatus;
  final SyncStatus syncStatus;
  final SyncCycleSummary? lastSummary;
  final List<SyncCycleSummary> history;

  SyncStatusState copyWith({
    final NetworkStatus? networkStatus,
    final SyncStatus? syncStatus,
    final SyncCycleSummary? lastSummary,
    final List<SyncCycleSummary>? history,
  }) => SyncStatusState(
    networkStatus: networkStatus ?? this.networkStatus,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSummary: lastSummary ?? this.lastSummary,
    history: history ?? this.history,
  );

  bool get isOnline => networkStatus == NetworkStatus.online;
  bool get isSyncing => syncStatus == SyncStatus.syncing;

  @override
  List<Object?> get props => <Object?>[
    networkStatus,
    syncStatus,
    lastSummary,
    history,
  ];
}

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
      (final NetworkStatus status) {
        if (isClosed) {
          return;
        }
        emit(state.copyWith(networkStatus: status));
      },
    );
    _syncSubscription = _coordinator.statusStream.listen(
      (final SyncStatus status) {
        if (isClosed) {
          return;
        }
        emit(state.copyWith(syncStatus: status));
      },
    );
    _summarySubscription = _coordinator.summaryStream.listen(
      (final SyncCycleSummary summary) {
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
