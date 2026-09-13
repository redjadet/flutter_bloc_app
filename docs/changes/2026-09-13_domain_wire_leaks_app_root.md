# Repair domain wire-leak scan root + refresh AI snapshots

## What landed

- `tool/check_domain_wire_leaks.sh` now scans
  `${APP_ROOT}/lib/features/*/domain` via `workspace_paths.sh` (Melos live
  tree), not stale repo-root `lib/features`.
- Still **warn-only** (exit 0 on findings); not promoted to fail gate.
- `bash tool/refresh_ai_reports.sh` refreshes `ai/reports/*` + CONTEXT_MAP
  snapshot metadata for freshness gate.

## Verification

```bash
bash tool/check_domain_wire_leaks.sh
bash tool/check_ai_snapshot_freshness.sh --strict-head
```
