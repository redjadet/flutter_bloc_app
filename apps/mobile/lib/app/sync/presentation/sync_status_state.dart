import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:networking/networking.dart';

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
