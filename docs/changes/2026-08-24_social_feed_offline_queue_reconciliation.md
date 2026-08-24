# Social Feed Offline Queue Reconciliation

## Problem

Queued comments remained absent after a cold start and could stay pending after
background replay. Concurrent queue writes could also lose a newly enqueued
mutation when a retry backoff wrote an older snapshot.

## Change

- Hydrate queued comment bodies into Cubit state during load.
- Promote dispatched queued comments into stored threads from the sync lease.
- Serialize viewer-scoped queue mutations and update retry backoff atomically.
- Remove a closing replay from the viewer registry before closing its stream.
- Carry exact remaining queued post IDs in each sync summary so one successful
  dispatch cannot clear the pending state for a later mutation on that post.

## Verification

- `cd apps/mobile && flutter test test/features/social_feed_demo`
- `./tool/analyze.sh`
- `./bin/checklist`

## Rollback

Revert this change. The demo returns to its prior queue and replay behavior;
no Hive schema or persisted-record shape changes are introduced.
