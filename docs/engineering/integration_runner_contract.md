# Integration Runner Contract

This document defines stable contract for `./bin/integration_tests` and
`tool/run_integration_tests.sh`.

## Stable default behavior

- `./bin/integration_tests` with no args runs aggregate integration suite.
- Exit semantics remain compatible: `0` on success, non-zero on failure.
- Only one integration runner instance may hold repo lock at time.
- second run exits with code `2` while another active run owns lock.
- Stale lock directories are removed automatically when recorded owner PID is no longer alive.

## Tier selectors

Optional selectors:

- `INTEGRATION_TESTS_TIER=smoke|standard|exhaustive`
- `INTEGRATION_TESTS_TARGET_SET=smoke|standard|exhaustive|full`

If selectors are invalid, runner falls back to `exhaustive`.

## Artifact contract

Each run writes structured summary under:

- `artifacts/integration/<timestamp>/summary.json`

latest artifact directory path is also written to:

- `artifacts/integration/.last-run-dir` (single line; used by CI summaries)

Optional companion logs:

- `flutter_test_<label>.log` inside artifact directory when run fails

Schema fields include:

- `started_at`
- `ended_at`
- `exit_code`
- `status`
- `failure_category`
- `device_id`
- `targets`
- `retried`
- `retry_reason`
- `duration_ms` (wall-clock duration when available)
- `tier` (`smoke` | `standard` | `exhaustive`)
- `selective_resolution_reason` (when selective mode runs)

## Failure categories

Runner emits one final category per run (exit-code classification plus, when
available, inference from captured `flutter test` output):

- `ok`
- `timeout`
- `cancelled_or_terminated`
- `retry_on_failure_enabled` (after opt-in generic retry)
- `test_assertion_or_app_failure`
- `simulator_build_infra`
- `infra_device_or_tooling`
- `unknown_transient_or_infra`

With `INTEGRATION_TESTS_RETRY_ON_FAILURE=1`, **retries are skipped** when
inferred category is `test_assertion_or_app_failure` (fail-fast on deterministic
test failures).

## Selective mapping

Source of truth:

- `tool/integration_selective_map.json` — path prefixes → `integration_test/` targets
- `tool/integration_selective_resolve.py` — resolver (ambiguous or unmapped → `FULL_SUITE`)

Enable with:

- `INTEGRATION_TESTS_ENABLE_SELECTIVE=1`
- `INTEGRATION_TESTS_CHANGED_FILES` — newline- or comma-separated repo-relative paths

**Exhaustive tier** skips selective narrowing (always uses tier aggregate target).

Legacy hard-coded fallbacks were replaced by `force_full_suite_prefixes` in JSON map.

## Selective mapping fallback rules

When selective mode is enabled, runner falls back to full suite for ambiguous
or broad changes; see `force_full_suite_prefixes` in `tool/integration_selective_map.json`,
including runner, harness, flow scenario, and map files.

## Coverage summary behavior

Coverage summary refresh is only guaranteed for full aggregate suite runs.
Targeted/tiered runs prioritize fast feedback and may skip merged coverage
summary updates.

## Rollout threshold validation

Use `tool/check_integration_rollout_threshold.sh` before switching CI rollout
to `enforced` phase.

Default gates:

- `success_rate >= 90%`
- `flake_rerun_rate <= 20%`
- `uncategorized_failure_count <= 0`
