# Quality re-measure Wave 0 (PR0) — 2026-08-04

## Summary

Evidence-only re-measure of Engineering/Harness scorecards, modularity metrics,
filtered coverage, QG-D04 fail-mode production scope, memory lint, tagged leak
journeys, and **two full-suite** leak-tracking dry-runs. Locks ranking for the
multi-wave quality program. **No gate or product code changes.**

## Artifacts

- Audit: [`docs/audits/quality_remeasure_review_2026-08-04.md`](../audits/quality_remeasure_review_2026-08-04.md)
- Local (gitignored): `tmp/quality_remeasure_pr0/`, `tmp/memory_leak_dry_run/quality_remeasure_{a,b}/`
- Tracked prose: [`README.md`](README.md) coverage badge refreshed to **85.10%** by
  `tool/test_coverage.sh` (matches new unit rollup; lcov/summary not committed)

## Key measured results

| Signal | Result |
| --- | --- |
| Engineering / Harness badges | 10/10 checks pass |
| Cross-feature edges | **8** (`production_readiness` → `fcm_demo`) — honesty gap vs older “0 edges” prose |
| Coverage (filtered unit) | **85.10%**; app-shell **75.53%** |
| D04 full fail-mode scope | **0** unsuppressed presentation hits (non-demo) |
| Memory lint + tagged leaks | pass |
| Dry-run A/B | both `flutter_test_exit=1`, `notDisposed=310`; product candidates stable |

## Ranking (locked)

1. **PR1** — QG-D04 warn → fail (precondition met: zero production hits)
2. **PR2** — Memory MQ-B2 product class ownership / disposal (dual-run evidence)
3. **PR3** — QG-D03 report-only inventory (no checklist wire, no fail default)

See Ranking decision table in the audit.

## Verification

```bash
bash tool/check_engineering_quality_scorecard_gate.sh
bash tool/check_harness_scorecard_gate.sh
CHECK_CONTEXT_READ_WATCH_MODE=fail bash tool/check_context_read_watch.sh
# Snapshot HEAD was stale on baseline; refresh required for harness fixtures:
bash tool/refresh_ai_reports.sh
./bin/checklist   # checklist-fast rejects ai/ change-set paths
```

## Also in this PR (hygiene)

- `tool/refresh_ai_reports.sh` — rebased AI discovery frontmatter `git_head` to
  baseline `516a06de` so harness `check_ai_snapshot_freshness --strict-head`
  passes (was pointing at older SHA). Not an app/runtime change.
- Audit path uses gitignore allowlist name
  `docs/audits/quality_remeasure_review_2026-08-04.md` (`*_review_*.md`).

## Known limitations / follow-ups

- PR1–PR3 not started in this change.
- Deferred doc twin (`docs/plans` vs `docs/engineering`) still diverges; later
  gate PRs must edit **engineering** as scorecard owner and sync plans.
- Modular metrics edges are documented, not fixed.
- Dry-run artifacts are local-only; re-run full dual stamps before changing B2
  ranking.
