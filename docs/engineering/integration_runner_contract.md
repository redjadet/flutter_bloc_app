# Integration Runner Contract

This document defines stable contract for `./bin/integration_tests` and
`tool/run_integration_tests.sh`.

## Stable default behavior

- `./bin/integration_tests` with no args runs the suite for `INTEGRATION_TESTS_TIER`
  (default `exhaustive` → `integration_test/all_flows_test.dart`).
- Passing explicit targets (for example `integration_test/smoke_flows_test.dart`)
  runs those files and bypasses tier selection.
- Exit semantics remain compatible: `0` on success, non-zero on failure.
- Only one integration runner instance may hold the repo lock at a time.
- A second run exits with code `2` while another active run owns the lock.
- Stale lock directories are removed automatically when the recorded owner PID is
  no longer alive.
- By default the runner executes `./bin/integration_preflight` first (browser/bootstrap
  guardrails). Set `INTEGRATION_TESTS_RUN_PREFLIGHT=0` to skip.

## Tier selectors

Optional selectors:

- `INTEGRATION_TESTS_TIER=smoke|standard|exhaustive` (default `exhaustive`)
- `INTEGRATION_TESTS_TARGET_SET=smoke|standard|exhaustive|full` (overrides tier target when set)

Invalid tier or target-set values fall back to `exhaustive` / full aggregate.

| Tier / target set | Entry file (no explicit args) |
| --- | --- |
| `smoke` | `integration_test/smoke_flows_test.dart` |
| `standard` | `integration_test/standard_flows_test.dart` |
| `exhaustive` / `full` | `integration_test/all_flows_test.dart` |

`integration_test/pr_smoke_flows_test.dart` remains an explicit smallest
high-signal target for PR-level confidence; current PR CI runs
`./bin/integration_preflight`, not a device integration suite. See
[`integration_journey_map.md`](integration_journey_map.md) and
[`ci_automation.md`](../ci_automation.md).

## Common environment variables

| Variable | Default | Meaning |
| --- | --- | --- |
| `INTEGRATION_TESTS_RUN_PREFLIGHT` | `1` | Run `./bin/integration_preflight` before device tests |
| `INTEGRATION_TESTS_RUN_COVERAGE` | `1` | Collect/merge coverage on full-suite runs when baseline exists |
| `INTEGRATION_TESTS_RETRY_ON_FAILURE` | `0` | Opt-in retry; skipped for inferred assertion failures |
| `INTEGRATION_TESTS_TIMEOUT_SECONDS` | `1800` | Per-invocation timeout passed to `flutter test` |
| `INTEGRATION_TESTS_ALLOW_CONCURRENT` | `0` | Set `1` to bypass single-run lock (unsafe) |
| `INTEGRATION_TESTS_ARTIFACTS_ROOT` | `artifacts/integration` | Artifact root directory |
| `CHECKLIST_INTEGRATION_DEVICE` | auto-discovered | Device id for `flutter test -d`; when set, runner validates via `simctl`/`adb` first and skips slow `flutter devices` when the id is already usable |
| `INTEGRATION_TEST_DEVICE` | — | Alias for `CHECKLIST_INTEGRATION_DEVICE` |
| `INTEGRATION_TESTS_SOURCE_ONLY` | `0` | Set `1` to source helper functions and exit before preflight/device work (runner contract tests) |

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

## iOS simulator build prep (proactive)

Before the first `flutter test` on an iPhone simulator (and again after
simulator-build recovery retries), the runner:

1. Enables the CocoaPods shim when applicable (see below).
2. Runs `pod install` in `ios/` when the `pod` CLI is available.
3. Runs `xcodebuild -resolvePackageDependencies` for `Runner.xcworkspace`.

Set `INTEGRATION_TESTS_SKIP_IOS_BUILD_PREP=1` to skip this path.

## CocoaPods shim (local / CI recovery)

When the real `pod` CLI is missing or killed during version checks (exit `137`),
`tool/run_integration_tests.sh` may prepend `tool/pod_shim` to `PATH` if
`Podfile.lock` matches `Pods/Manifest.lock`.

| Variable | Default | Meaning |
| --- | --- | --- |
| `INTEGRATION_TESTS_ALLOW_POD_SHIM` | `1` | Allow shim when lock files match |
| `INTEGRATION_TESTS_PODFILE_LOCK` | set by runner | Absolute path to `ios/Podfile.lock` |
| `INTEGRATION_TESTS_PODS_MANIFEST` | set by runner | Absolute path to `ios/Pods/Manifest.lock` |

Shim behavior (`tool/pod_shim/pod`):

- `install` with no extra args: no-op **only** when allow flag is `1` and locks match.
- `install` with extra args, or any other subcommand: delegates to real `pod` when found.
- Unknown commands without a real `pod`: exit `1` (no silent success).

Set `INTEGRATION_TESTS_ALLOW_POD_SHIM=0` to require a working CocoaPods install.
Commit `tool/pod_shim/pod` (executable) so clones and CI can use the same path.

## Related docs

- Flow authoring: [`testing_integration_flows.md`](../testing_integration_flows.md)
- Policy and ownership: [`integration_test_policy.md`](integration_test_policy.md)
- Journey → target map: [`integration_journey_map.md`](integration_journey_map.md)
- CI jobs and preflight: [`ci_automation.md`](../ci_automation.md)
- Browser-only lane: `./bin/integration_preflight` ([`agents_quick_reference.md`](../agents_quick_reference.md))
