import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/sync_cycle_summary.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_status_state.freezed.dart';

/// Immutable state for the sync status cubit: network status, sync status, and history.
@freezed
abstract class SyncStatusState with _$SyncStatusState {
  const factory SyncStatusState({
    required final NetworkStatus networkStatus,
    required final SyncStatus syncStatus,
    final SyncCycleSummary? lastSummary,
    @Default(<SyncCycleSummary>[]) final List<SyncCycleSummary> history,
  }) = _SyncStatusState;

  const SyncStatusState._();

  bool get isOnline => networkStatus == NetworkStatus.online;
  bool get isSyncing => syncStatus == SyncStatus.syncing;
}
