---
name: offline-first
description: Apply when changing Hive storage, sync, conflict merge, pending queues, or remote refresh that could overwrite local state.
---

# Skill: offline-first

**Owner:** [`docs/offline_first/adoption_guide.md`](../../offline_first/adoption_guide.md),
[`invariants.md`](../../offline_first/invariants.md),
[`dont_overwrite_guide.md`](../../offline_first/dont_overwrite_guide.md).

## Must

1. Never let stale remote overwrite newer local or pending mutations.
2. Re-read local row before save/delete after merge (TOCTOU).
3. Treat failed remote reads as failure — not empty remote.
4. Keep queue entries durable across persistence failure.
5. Dead-letter non-retryable `auth_required` once; keep idempotency on retryable failures.

## Must not

- Invent a second sync engine or bypass existing repository merge helpers.
- Clear pending UI state without a proven sync path.
- Skip offline tests when touching merge/refresh.

## Proof

```bash
bash tool/check_offline_first_remote_merge.sh
cd apps/mobile && flutter test <offline-or-repo-test-paths>
```

Reviewer map: [`docs/offline_first/reviewer_guide.md`](../../offline_first/reviewer_guide.md).
