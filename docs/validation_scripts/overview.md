# Validation scripts — overview

Router: [`../validation_scripts.md`](../validation_scripts.md).

## About this catalog

Catalog of validation scripts in `tool/`. **81** `check_*.sh` scripts on disk
excluding `check_helpers.sh`; **63** in `./bin/checklist` (`CHECK_SCRIPTS`) —
see inventory map in
[`catalog.md`](catalog.md#inventory-map-disk-vs-docs) and auto list in
[`checklist_index.md`](checklist_index.md). Run scripts directly for targeted
proof, `./bin/checklist` for full sweep, and `./bin/checklist-fast` only for
clean-tree or narrow docs/tooling sanity.

**Host agent upkeep:** [`./bin/agent-maintain`](../../bin/agent-maintain) routes
composed workflows (`preflight`, scope `closeout`, `docs-sync`, `after-host-edit`)
to existing `tool/*` scripts — see
[`agent_kb/host_maintenance_automation.md`](../agent_kb/host_maintenance_automation.md)
and [`operations_host_skills.md`](operations_host_skills.md). Catalog row:
[`agent_maintain.sh`](catalog.md) (not part of `CHECK_SCRIPTS`; contract smoke via
[`check_checklist_cli_contract.sh`](catalog.md)).

For complete docs index, see [docs index](../README.md).

## Overview

Scripts guard architecture, UI/UX, async, perf, and memory hygiene. Prefer
targeted scripts for local changes; use `./bin/checklist` for broad/pre-ship
validation.

## Policy: changing validation scripts

Validation scripts are **quality gates**. When a script produces a false positive,
fix it without weakening the invariant:

- Prefer **narrower matching/scope**, better parsing, or **fixtures** that prove the old false positive and a real violation.
- Prefer local, explicit suppressions: `// check-ignore: <reason>` on the exact line (or previous line) when the exception is intentional.
- Avoid broad exclusions (“ignore demos”, “ignore feature X”) unless the repo policy truly intends that behavior and it is documented here with rationale.

Checklist includes guards:

- **Architecture compliance** - Ensures clean architecture boundaries and dependency injection patterns
- **UI/UX best practices** - Enforces platform-adaptive widgets, proper image caching, and responsive design
- **Async safety** - Detects missing lifecycle guards and context usage after async operations
- **Performance** - Flags performance anti-patterns like unnecessary rebuilds and missing repaint boundaries
- **Dynamic list safety** - Prevents builder callbacks from indexing live Cubit/BLoC state lists after async shrink/rebuild races
- **Memory hygiene** - Prevents leaks and ensures proper cleanup of resources

Full documentation and suppression guidance is provided in sections below.

## CI (GitHub Actions)

On pushes and pull requests, [`.github/workflows/ci.yml`](../.github/workflows/ci.yml) runs **`./bin/checklist`** on `ubuntu-latest` (same delivery pipeline as local pre-merge validation). Golden widget tests are skipped in GitHub Actions CI.

**Integration tests not run on push/PR.** Run only via manual workflow (**Actions → CI → Run workflow**) with **`run_integration`** on (default off). macOS job picks an available **iPhone** on the **newest installed iOS simulator runtime** (see `tool/ios_simulator_pick.py`), then `IOS_SIMULATOR_PREFERRED_NAMES`; optional `IOS_SIMULATOR_PREFERRED_RUNTIME_VERSION` pins an exact runtime. If none/boot fail/boot timeout, integration step skips (no job fail).

For broader local or pre-ship validation, `./bin/integration_tests` runs on a
non-web device. Default tier is `exhaustive` (`integration_test/all_flows_test.dart`);
set `INTEGRATION_TESTS_TIER=smoke|standard` for smaller suites. Contract:
[`engineering/integration_runner_contract.md`](../engineering/integration_runner_contract.md).

## Current state (May 2026)

- Router now relies on route-level gates (`AppRouteAuthGate` + `AppRoutePolicies`) for deep-link-safe auth on selected routes.
- When adding or modifying auth gates, expect **integration flows** to need explicit sign-in before visiting newly protected routes.
- Preferred validation after auth/routing changes:
  - `./bin/router_feature_validate`
  - `./bin/checklist`
  - `./bin/integration_tests`
