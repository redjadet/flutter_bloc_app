/// Indicates the current status of the background sync coordinator.
enum SyncStatus { idle, syncing, degraded }

extension SyncStatusX on SyncStatus {
  bool get isIdle => this == SyncStatus.idle;
  bool get isSyncing => this == SyncStatus.syncing;
  bool get isDegraded => this == SyncStatus.degraded;
}
