# ADR 0002: Offline-First Data Access

Status: Accepted

## Context

The app needs to remain usable without connectivity and avoid blocking UI flows on network latency.

## Decision

- Use offline-first repositories with a write-first or cache-first strategy depending on the feature.
- Queue failed operations in `PendingSyncRepository` and replay them via `BackgroundSyncCoordinator`.
- Store local data in encrypted Hive repositories with migration helpers.

## Consequences

- Additional sync metadata on entities (synchronized state, change IDs).
- Higher implementation complexity but consistent behavior when offline.
- Predictable UI state with local-first writes.
