# file_length_lint promoted (QG-D02)

**Date:** 2026-06-08  
**Gate:** QG-D02 — `file_too_long` via native `file_length_lint` plugin

## Summary

Promoted deferred quality gate **QG-D02** to fail-by-default file length enforcement under `lib/`.

## What shipped

- `analysis_options.yaml`: `plugins.file_length_lint.diagnostics.file_too_long: error`
- `file_length_lint.max_lines: 225` with `include_defaults: true` and `integration_test/**` exclude
- `plugins.file_length_lint.path: custom_lints/file_length_lint` (native plugin wiring for CLI/IDE)
- Path package on `analysis_server_plugin` with `dependency_overrides: analyzer: 10.0.2`
- `./tool/run_file_length_lint.sh` — `dart analyze --format machine .`, grep `FILE_TOO_LONG` under `lib/`, fail on plugin errors
- Checklist hook: `CHECKLIST_RUN_FILE_LENGTH_LINT=auto|0|1` (default `auto`)

## Verification

```bash
dart analyze --format machine . | grep FILE_TOO_LONG || true
./tool/run_file_length_lint.sh
cd custom_lints/file_length_lint && dart test
./tool/check_pubspec_codegen_compat.sh
```

Baseline at promotion: **0** `lib/` files over 225 lines (longest 224).

## Fix policy

Split oversized files into `*.part.dart` helpers; do not raise `max_lines` to silence violations.

## Related

- [`docs/plans/checklist_quality_gates_deferred.md`](../plans/checklist_quality_gates_deferred.md) — QG-D02 row updated to **promoted (fail)**
- [`docs/changes/2026-06-03_renovate-dashboard-issue-2.md`](2026-06-03_renovate-dashboard-issue-2.md) — analyzer 10 / plugin stack context
