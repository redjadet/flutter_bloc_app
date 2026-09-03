# QG-D04: context.read/watch fail-default — 2026-08-04

## Summary

Promoted **QG-D04** from checklist **warn** to default **fail** after Wave0
remeasure: zero unsuppressed non-demo presentation hits and fixture/harness
triad proof.

## Changes

- `tool/check_context_read_watch.sh` default `CHECK_CONTEXT_READ_WATCH_MODE=fail`
- Harness fixtures for good / bad / suppressed under fail mode
- [`docs/engineering/checklist_quality_gates_deferred.md`](../engineering/checklist_quality_gates_deferred.md) → **promoted (fail)**
- [`engineering/checklist_quality_gates_deferred.md`](../engineering/checklist_quality_gates_deferred.md) → pointer to engineering owner
- catalog severity text updated

## Scope

Presentation under `apps/mobile/lib/features/**` excluding `*_demo/**` only
(not router). Rollback: `CHECK_CONTEXT_READ_WATCH_MODE=warn`.

## Verification

```bash
bash tool/run_harness_fixtures.sh
bash tool/check_context_read_watch.sh
./bin/checklist
```
