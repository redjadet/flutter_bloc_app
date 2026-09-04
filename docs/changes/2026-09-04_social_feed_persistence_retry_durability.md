# 2026-09-04 — Social Feed persistence retry durability

## Problem

After a remote like or comment applied successfully, a failed Hive write could
discard the only durable record of that user intent. Direct online mutations
reported success without a queue entry, and queued replay retried a failed
local write immediately without recording backoff.

## Change

- Keep queue entries until viewer likes or comment threads persist to Hive.
- Queue direct online mutations with their original idempotency key when that
  persistence fails, and return the existing queued result.
- Record retry attempts and exponential backoff for failed persistence during
  dispatch; move the mutation to needs-attention after the existing limit.
- Treat malformed backoff timestamps as retryable instead of stalling replay.

## Tests

- `apps/mobile/test/features/social_feed_demo/data/offline_first_social_feed_repository_test.dart`
  proves queued and direct-online like/comment persistence failures retain
  replayable intent, then retry after the recorded backoff.

## Proof

- `cd apps/mobile && flutter test test/features/social_feed_demo/data/offline_first_social_feed_repository_test.dart -r expanded`
- `cd apps/mobile && ../../tool/analyze.sh`
- `./bin/checklist`

## Rollback

Revert this change to restore the prior replay behavior; no schema, route, DI,
or public API changes are included.
