/// Stable pending-sync entity ID for todo mutations.
///
/// Shared between data adapters and queue cleanup logic so they agree on
/// the queue identity for todo operations.
const String todoSyncEntityType = 'todo';
