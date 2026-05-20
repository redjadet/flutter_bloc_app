# Counter feature — outcome brief

PM-readable ownership narrative for the primary interview spine feature (`/`).

## Hypothesis

Users need a **reliable, offline-capable** counter that survives app restarts and syncs when connectivity returns — demonstrating the same patterns used across Todo and other offline-first modules.

## Success metrics (would track with product analytics)

Per [future_observability.md](../plans/future_observability.md) (not shipped today):

| Metric | Definition |
| --- | --- |
| D1 retention on counter screen | Users returning within 24h after first increment |
| Sync success rate | Pending ops flushed without terminal failure |
| Time-to-consistency | Median delay from local change to remote ack |

## Guardrails

- No data loss on kill/restart (persistence integration flow)
- No duplicate remote writes under rapid taps (request-id / coalescing in repo layer)
- User-visible sync state (banner + optional queue inspector)

## Ship / iterate / kill

| Stage | Signal |
| --- | --- |
| Ship | Persistence test green; sync diagnostics show healthy flush in demo |
| Iterate | Elevated `serviceUnavailable` or queue depth in diagnostics |
| Kill | N/A for portfolio demo — feature anchors architecture story |

## Proof in repo

- Code: [`lib/features/counter/`](../../lib/features/counter/)
- Integration: `registerCounterPersistenceIntegrationFlow()` in PR smoke
- Manual: Settings → Sync diagnostics after offline edits
- Architecture: [ADR 0002](../adr/0002-offline-first-data.md), [offline_first/adoption_guide.md](../offline_first/adoption_guide.md)

## Interview tie-in

Use with [interview_showcase.md](../interview_showcase.md) step 1, then step 4 for validation narrative.
