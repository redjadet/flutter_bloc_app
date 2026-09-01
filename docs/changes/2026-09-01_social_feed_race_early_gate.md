# 2026-09-01 — Social Feed race early gate

## Why

The full coverage lane could detect an online-apply-versus-replay race only
after slower checklist work. The existing stale-replay guard did not select
Social Feed tests.

## Change

- Add Social Feed offline repository tests to
  `tool/check_offline_first_remote_merge.sh` for CI and relevant local edits.
- Make the guard inventory recognize queued-like dispatch races so a matching
  regression test cannot be added without checklist wiring.
- Document online-apply-versus-replay testing in the offline-first adoption,
  validation catalog, and regression-anchor guidance.

## Proof

- `bash tool/check_offline_first_remote_merge.sh`
- `bash tool/check_docs_gardening.sh`
- `bash tool/validate_task_trackers.sh`
