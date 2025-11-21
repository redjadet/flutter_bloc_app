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
  });

  final NetworkStatus networkStatus;
  final SyncStatus syncStatus;

  SyncStatusState copyWith({
    NetworkStatus? networkStatus,
    SyncStatus? syncStatus,
  }) => SyncStatusState(
    networkStatus: networkStatus ?? this.networkStatus,
    syncStatus: syncStatus ?? this.syncStatus,
  );

  bool get isOnline => networkStatus == NetworkStatus.online;
  bool get isSyncing => syncStatus == SyncStatus.syncing;

  @override
  List<Object> get props => <Object>[networkStatus, syncStatus];
}

class SyncStatusCubit extends Cubit<SyncStatusState> {
  SyncStatusCubit({
    required NetworkStatusService networkStatusService,
    required BackgroundSyncCoordinator coordinator,
  }) : _networkStatusService = networkStatusService,
       _coordinator = coordinator,
       super(
         SyncStatusState(
           networkStatus: NetworkStatus.unknown,
           syncStatus: coordinator.currentStatus,
         ),
       ) {
    _networkSubscription = _networkStatusService.statusStream.listen(
      (final NetworkStatus status) {
        emit(state.copyWith(networkStatus: status));
      },
    );
    _syncSubscription = _coordinator.statusStream.listen(
      (final SyncStatus status) {
        emit(state.copyWith(syncStatus: status));
      },
    );
  }

  final NetworkStatusService _networkStatusService;
  final BackgroundSyncCoordinator _coordinator;
  StreamSubscription<NetworkStatus>? _networkSubscription;
  StreamSubscription<SyncStatus>? _syncSubscription;

  Future<void> flush() => _coordinator.flush();

  @override
  Future<void> close() async {
    await _networkSubscription?.cancel();
    await _syncSubscription?.cancel();
    return super.close();
  }
}
