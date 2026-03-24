# Integration Runner Contract

This document defines the stable contract for `./bin/integration_tests` and
`tool/run_integration_tests.sh`.

## Stable default behavior

- `./bin/integration_tests` with no args runs the aggregate integration suite.
- Exit semantics remain compatible: `0` on success, non-zero on failure.

## Tier selectors

Optional selectors:

- `INTEGRATION_TESTS_TIER=smoke|standard|exhaustive`
- `INTEGRATION_TESTS_TARGET_SET=smoke|standard|exhaustive|full`

If selectors are invalid, runner falls back to `exhaustive`.

## Artifact contract

Each run writes a structured summary under:

- `artifacts/integration/<timestamp>/summary.json`

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

## Failure categories

Runner emits one final category per run:

- `ok`
- `timeout`
- `cancelled_or_terminated`
- `retry_on_failure_enabled`
- `test_assertion_or_app_failure`

## Selective mapping fallback rules

When selective mode is enabled, runner falls back to full suite for ambiguous
or broad changes, including:

- `tool/run_integration_tests.sh` edits
- `integration_test/test_harness.dart` edits
- `integration_test/flow_scenarios.dart` edits

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
