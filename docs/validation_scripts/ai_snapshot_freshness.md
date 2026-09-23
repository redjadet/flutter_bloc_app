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
bash tool/check_ai_snapshot_freshness.sh --strict-head   # Optional: needs snapshot git_head in local Git history
```

## Refresh

```bash
bash tool/refresh_ai_reports.sh
bash tool/refresh_ai_reports.sh --self-test # frontmatter idempotency + malformed/body-delimiter safety
```

The refresh command validates every active snapshot, stages the complete output
set, and then installs it under a repo-scoped lock. A normal install failure or
handled interruption rolls back already installed targets, preventing mixed
snapshot generations.

`--strict-head` treats `git_head` as source provenance. It accepts later commits
and squash-merged branches when the snapshot's source paths have the same
content at `HEAD`; it rejects a missing revision or a change under app
source/tests, packages, relevant maps and owner docs, or report generators.
It compares committed content only. A shallow checkout
without the recorded revision cannot prove this condition; the harness fixture
uses a temporary full-history repository to test both outcomes.

Source unchanged does not prove curated narrative is correct. Agents still
confirm material claims in current code/tests and owning docs before editing.

## Related

- Change note (PR #516): search `docs/changes/` for AI-native repository hardening.
- Forbidden patterns fixture: `tool/fixtures/harness/ai_snapshot_forbidden_patterns.txt`
