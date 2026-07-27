/// Stable pending-sync entity ID for counter mutations.
///
/// Shared between data adapters and queue cleanup logic so they agree on the
/// queue identity for counter operations.
const String counterSyncEntityType = 'counter';
