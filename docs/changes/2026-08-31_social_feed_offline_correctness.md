# 2026-08-31 — social-feed offline correctness

## Why

Queued social-feed mutations could diverge from the final user intent during
offline replay, a cached first-page miss could discard an optimistic like, and
the first replay summary could be emitted before the Cubit subscribed.

## Scope

- Clear all undispatched likes for a post after the latest apply succeeds;
  rotate the coalesced-like idempotency key and reject mismatched ack-cache
  projections.
- Use a viewer-projected remote post plus pending overlay for cached-page misses.
- Deliver the initial replay result as `SocialFeedSyncLease.seedSummary`, then
  apply it after the Cubit subscribes.
- Ignore mutation completions after the active viewer/generation changes.

## Out of scope

- Production backend or queue-schema changes.
- Changes outside the social-feed demo's simulated remote.

## Proof

- `cd apps/mobile && flutter test test/features/social_feed_demo/`
- `./tool/analyze.sh`
- `./bin/checklist`
