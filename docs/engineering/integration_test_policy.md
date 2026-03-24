# Integration Test Policy

Use this policy to decide where coverage should live and how failures are owned.

## Where to add tests

- **Unit test:** pure logic, deterministic input-output, no UI flow.
- **Cubit/Bloc test:** state transition logic and async orchestration.
- **Widget test:** visual/component behavior within one screen.
- **Integration test:** cross-screen user journey, persistence, and platform-like
  behavior.

If a production bug escapes and affects a user journey, add at least one
integration regression scenario.

## Required quality bars

- New integration scenarios must map to a named journey in
  `docs/engineering/integration_journey_map.md`.
- New flow should declare the intended tier (`smoke`, `standard`, `exhaustive`).
- Keep assertions explicit; avoid tests that only verify “does not crash.”

## Failure ownership routing

- **Infra/platform owner:** device discovery, simulator boot/build,
  infrastructure retries, cancellation/timeout infra causes.
- **Feature owner:** deterministic app assertions, journey behavior regressions,
  invalid UX/error handling.

## Monthly trend review inputs

Collect and review:

- integration success rate
- flake rerun rate
- median and p95 integration duration
- top failing targets
- uncategorized failure count

Suggested baseline command:

- `bash tool/build_integration_baseline.sh 14`
- Track manual metrics in `docs/engineering/integration_metrics_baseline.md`.

Escalate if flake rerun rate or uncategorized failures trend upward for two
consecutive windows.

## Enforced rollout gate

Before promoting CI rollout to `enforced`, run threshold validation:

- `bash tool/check_integration_rollout_threshold.sh`

Default threshold contract:

- success rate >= 90%
- flake rerun rate <= 20%
- uncategorized failures <= 0

Thresholds can be overridden per run:

- `MAX_FLAKE_RATE`
- `MIN_SUCCESS_RATE`
- `MAX_UNCATEGORIZED_FAILURES`
