# Social Feed offline ownership

Current offline policy remains owned by [ADR 0002](../../adr/0002-offline-first-data.md)
and the [Social Feed guide](../../features/social_feed_demo.md). This case study
focuses on the decision story.

## Context

A stale remote snapshot or replaying queue head can overwrite newer user
intent. One completed mutation can also clear a same-post pending indicator
while later queued work remains. Wrong reconciliation silently loses intent and
makes UI state untrustworthy.

## Ownership

Own reconciliation in the data layer, queue concurrency, viewer generation,
and the exact pending projection exposed to presentation. In an interview,
separate personally authored merge/queue/test work from the shared offline
stack and demo behavior.

## Options

1. Always replace local state with remote state.
2. Let local state win forever.
3. Overlay pending local intent until acknowledgement or rejection, then merge
   from current queue and remote state.

## Decision

Choose option 3. Serialize online and replayed like applies per viewer, re-read
queue state at the decision boundary, and return exact remaining
`pendingPostIds` after dispatch.

## Rejected approach

Reject remote-wins replacement and clearing a post's pending state after the
first dispatched mutation. Reject unconditional local-wins behavior because
acknowledged canonical remote state must eventually converge.

## Trade-off

Queue, locking, replay, and viewer-generation tests add complexity. Scope is the
credential-free simulated Social Feed; it does not prove a production backend,
auth model, or multi-account retention policy.

## Proof and outcome

| Evidence status | Boundary |
| --- | --- |
| Implemented behavior | Demo likes/comments survive offline replay without discarding the newest local intent. Scope remains simulated Social Feed behavior. |
| Repository proof | [`OfflineFirstSocialFeedRepository`](../../../apps/mobile/lib/features/social_feed_demo/data/offline_first_social_feed_repository.dart), [repository regressions](../../../apps/mobile/test/features/social_feed_demo/data/offline_first_social_feed_repository_test.dart), and [`check_offline_first_remote_merge.sh`](../../../tool/check_offline_first_remote_merge.sh) |
| Historical evidence | [Queue reconciliation](../../changes/2026-08-24_social_feed_offline_queue_reconciliation.md), [offline correctness](../../changes/2026-08-31_social_feed_offline_correctness.md), and [dispatch race](../../changes/2026-09-01_social_feed_like_dispatch_race.md) |
| Planned / deferred | Real backend/auth, push, production retention, and user-visible conflict resolution remain out of scope. |
| Contribution | Individual: personally owned merge, queue, or regression slice. Team/system: shared offline infrastructure, feature integration, validation, and review. |

## Reflection

Timestamp comparison alone was insufficient once online writes and replay could
overlap. Correctness required serializing the decision and re-reading mutable
queue state rather than trusting a stale snapshot.

## New default

Every remote merge or online-write/replay overlap must prove that newer local
intent and the current queue head win. Wire the regression into the shared
offline merge guard.

## Revisit trigger

Revisit for a real backend conflict contract, shared accounts, queue-schema
changes, or user-visible merge resolution.
