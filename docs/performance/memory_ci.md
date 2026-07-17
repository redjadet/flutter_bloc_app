# Memory CI / checklist

Both Wave A gates run through the existing delivery checklist (same path as
normal PR / push / merge-group CI via `.github/workflows/ci.yml`).

## Gates

| Gate | How |
| --- | --- |
| Static | `bash tool/run_memory_lint.sh` (checklist `CHECKLIST_RUN_MEMORY_LINT=auto\|0\|1`) |
| Runtime | `bash tool/run_memory_leak_tests.sh` (default **on**: `CHECKLIST_RUN_MEMORY_LEAK_TESTS=1`) |

## Local opt-out

```bash
SKIP_MEMORY_LINT=1            # or CHECKLIST_RUN_MEMORY_LINT=0
CHECKLIST_RUN_MEMORY_LEAK_TESTS=0
```

## Proof inventory

Also listed on the engineering scorecard (proof row only; does not change badge
math):

```bash
bash tool/run_memory_lint.sh
bash tool/run_memory_leak_tests.sh
```

## Wave A boundary

No dedicated CI job and no memory report artifact in Wave A. Checklist stdout is
the failure surface.

## Wave B0 — report-only dry-run (not a gate)

```bash
bash tool/run_memory_leak_tracking_dry_run.sh
```

- Opt-in via `--dart-define=MEMORY_LEAK_TRACKING_DRY_RUN=true`
- Always exits 0; artifacts under `tmp/memory_leak_dry_run/`
- **Must not** be wired into `delivery_checklist.sh` or required CI checks
- Default remains `withIgnoredAll()` for untagged tests
