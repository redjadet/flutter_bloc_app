# ADR 0002: Offline-First Data Access

| Field | Value |
| --- | --- |
| Status | Accepted |
| Scope | Data access and sync |
| Source docs | [Offline-First Adoption Guide](../offline_first/adoption_guide.md), [Hive Schema Migrations](../offline_first/hive_schema_migrations.md) |

## Context

Many app flows must remain usable when the network is slow, unavailable, or
temporarily inconsistent. The UI should not block common user actions on remote
latency, and user-generated data must not be lost when sync fails.

Local persistence, sync queues, retry behavior, and remote merge policy need one
shared model so features do not invent incompatible offline behavior.

## Decision Drivers

- Preserve user data before remote writes.
- Keep feature UI responsive while sync runs in the background.
- Make retry, queue inspection, and telemetry consistent across features.
- Keep offline-first implementation inside the data layer.
- Support Hive schema migrations explicitly when stored shapes change.
- Keep remote merge behavior conservative so stale remote data cannot overwrite
  newer local changes.

## Decision

Use offline-first repositories for features that need local continuity:

- Write to local Hive-backed storage first for write-heavy flows.
- Read from local cache first when remote freshness is not required for the
  initial UI.
- Queue failed or deferred mutations in `PendingSyncRepository`.
- Replay queued operations through `BackgroundSyncCoordinator`.
- Register sync-capable repositories in `SyncableRepositoryRegistry`.
- Store local data through encrypted Hive repositories managed by
  `HiveService`.
- Use manifest-backed Hive schema migrations when persisted shapes change.

The accepted dependency placement is:

```text
Presentation -> Domain <- Data
                         Data -> local store + remote adapter + sync queue
```

Presentation can show pending or sync status, but queueing, replay,
deduplication, and merge policy stay in repositories and shared sync
infrastructure.

Offline-first is the default for user-generated or business-critical local
state. Read-only demos and low-value caches can stay cache-first or online-first
when the owning feature doc makes that trade-off explicit.

## Alternatives Considered

| Alternative | Why not |
| --- | --- |
| Online-only repositories | Simpler, but breaks core flows during network loss and increases perceived latency. |
| UI-owned retry queues | Makes widgets responsible for persistence and retry policy, violating layer boundaries. |
| Remote-first reads for every feature | Keeps data fresh, but blocks common screens and fails poorly offline. |
| Per-feature sync implementations | Gives local freedom, but creates inconsistent retry behavior, telemetry, and data-loss risk. |

## Consequences

### Benefits

- User actions can complete locally even when remote sync is delayed.
- Sync behavior is consistent and inspectable through shared infrastructure.
- Feature repositories can choose write-first or cache-first strategy based on
  product needs.
- Hive migration contracts make stored-shape changes explicit and testable.

### Costs

- Entities often need sync metadata such as change IDs, idempotency keys,
  synchronized flags, and timestamps.
- Repositories must handle merge policy, retry idempotency, malformed stored
  operations, and per-user queue scope.
- Tests need local store, queue, and replay coverage instead of only happy-path
  remote mocks.
- Local cache retention policy becomes part of feature ownership.

## Implementation Notes

- New Hive-backed repositories should extend `HiveRepositoryBase` or
  `HiveSettingsRepository<T>`.
- Do not call `Hive.openBox` directly outside shared storage infrastructure.
- Preserve idempotency and user-scope fields when enqueueing operations.
- Use `BackgroundSyncCoordinator.flush()` for explicit flushes; do not start
  overlapping sync work from feature code.
- Remote snapshots must not overwrite newer unsynced local data.

## Review Triggers

Revisit this ADR when:

- the app changes primary local storage technology;
- sync moves from foreground/background app flows to a platform background job;
- conflict resolution needs user-visible merge decisions;
- a feature proposes remote-first writes for user-generated data.

## Verification

- Adoption workflow: [Offline-First Adoption Guide](../offline_first/adoption_guide.md)
- Migration contract: [Hive Schema Migrations](../offline_first/hive_schema_migrations.md)
- Merge safety: [Don't Overwrite Guide](../offline_first/dont_overwrite_guide.md)
- Targeted commands:
  - `bash tool/check_hive_schema_fingerprints.sh`
  - `./tool/check_no_hive_openbox.sh`
