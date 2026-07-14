# AI snapshot freshness

Router: [`../validation_scripts.md`](../validation_scripts.md).

## Purpose

Rejects stale Melos-era paths and missing metadata in active `ai/` discovery
snapshots so agents do not open deleted `lib/core` / `lib/shared` locations.

## When to run

- After editing [`ai/CONTEXT_MAP.md`](../../ai/CONTEXT_MAP.md) or `ai/reports/*` discovery snapshots
- After `bash tool/refresh_ai_reports.sh`
- Included in `./bin/checklist-fast` via `run_harness_docs_checks`
- Scoped in `tool/check_docs_gardening.sh` when `ai/**` is in the path set

## Command

```bash
bash tool/check_ai_snapshot_freshness.sh
bash tool/check_ai_snapshot_freshness.sh --strict-head   # CI optional: source git_head must match HEAD (or HEAD^ for a metadata-only snapshot commit)
```

## Refresh

```bash
bash tool/refresh_ai_reports.sh
```

## Related

- Plan: [`docs/plans/2026-07-14_ai_native_repository_hardening_plan.md`](../plans/2026-07-14_ai_native_repository_hardening_plan.md)
- Forbidden patterns fixture: `tool/fixtures/harness/ai_snapshot_forbidden_patterns.txt`
