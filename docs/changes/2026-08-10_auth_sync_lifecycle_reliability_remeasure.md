# Auth / sync / Cubit lifecycle reliability remeasure — 2026-08-10

## Summary

Evidence-only Day-0/PR0 re-measure of auth session, offline/sync, and
auth/sync-adjacent Cubit lifecycle on clean `main` (`1c27b5ac`). All matrix
lanes green. Locked three eligible follow-up fixes (≥7/10, repro≥2). Absorbed
stale session-lifecycle test path in [`testing_overview.md`](../testing_overview.md).

## Artifacts

- Audit: [`docs/audits/auth_sync_lifecycle_reliability_remeasure_review_2026-08-10.md`](../audits/auth_sync_lifecycle_reliability_remeasure_review_2026-08-10.md)
- Local logs (gitignored): `tmp/reliability_remeasure/`
- Local tracker (gitignored under `tasks/cursor/`): `todo_auth_sync_lifecycle_remeasure.md` — does not overwrite active web/iOS `todo.md`

## Locked follow-ups

| PR | ID | Score | Intent |
| --- | --- | ---: | --- |
| PR1 | SEARCH-01 | 9 | Clear search Hive cache on Firebase session cleanup |
| PR2 | AUTH-CUBIT-01 | 9 | AppAuthCubit + SignOutAware A→B session-ready integration test |
| PR3 | AUTH-CUBIT-02 | 8 | AppAuthCubit late-event-after-close regression |

## Proof (PR0)

```bash
# Matrix summary: all exit 0 — see audit measurement table
bash tool/check_docs_gardening.sh
# Note: ./bin/checklist-fast --no-reuse may fail on pre-existing
# ai/* snapshot freshness vs HEAD; not introduced by this docs PR.
```
