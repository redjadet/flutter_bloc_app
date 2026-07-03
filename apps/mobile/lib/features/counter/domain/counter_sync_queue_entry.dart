/// Summary of a pending sync operation for counter inspector UI.
class CounterSyncQueueEntry {
  const CounterSyncQueueEntry({
    required this.id,
    required this.entityType,
    required this.retryCount,
  });

  final String id;
  final String entityType;
  final int retryCount;
}
