# Offline-first authority invariants (W3)

**Date:** 2026-09-24  
**Status:** Documented for Phase 1; enforcement via existing gates (no new sync engine).

Canonical how-to: [`dont_overwrite_guide.md`](dont_overwrite_guide.md),
[`adoption_guide.md`](adoption_guide.md).  
Gate: `bash tool/check_offline_first_remote_merge.sh` (also wired through
checklist / validation catalog).

## Named invariants

1. **Stale remote never overwrites newer local** (timestamp / sync-state gate).  
2. **Stale queued mutation never overwrites newer remote** (replay compares remote before push).  
3. **Local row re-read before save/delete (TOCTOU)** after the initial merge snapshot.  
4. **Failed remote reads ≠ empty state** — do not treat fetch failure as “remote has no rows.”  
5. **Persistence failure retains queue entries** — durable mutations survive Hive write failure.  
6. **Logout / session cleanup must not race in-flight merge** — session teardown coordination.  
7. **Non-retryable `auth_required` dead-letters once; retryable failures keep idempotency.**

## Proof mapping

| Invariant | Primary evidence |
| --- | --- |
| 1–5 | Counter / todo / IoT / social-feed offline-first repository tests + `check_offline_first_remote_merge.sh` |
| 4 | `tool/check_remote_fetch_failure_fallback.sh` + pullRemote retention tests |
| 7 | Chat terminal sync / dead-letter paths (`auth_required`) |

Do not invent empty TOCTOU tests for repos that only cache; see
[`../changes/2026-09-13_offline_first_chat_profile_merge_guard.md`](../changes/2026-09-13_offline_first_chat_profile_merge_guard.md).
