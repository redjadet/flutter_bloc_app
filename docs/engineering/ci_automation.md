# CI Automation

This repo uses GitHub Actions as the merge gate + drift detector.

## Required checks (branch protection)

Require these checks on `main`:

- **`CI / build`**: runs `./bin/checklist` (analyze + repo static checks + mix_lint + coverage).
- **`CI / integration-preflight`**: runs `./bin/integration_preflight` on PRs / merge queue to catch browser/bootstrap/import drift before slower simulator lanes.
- **`Dependency Review / dependency-review`**: GitHub dependency review action.
- **`OSV-Scanner PR Scan / scan-pr`**: vulnerability scan of `pubspec.lock`.

Optional (only if Renovate/Dependabot are in use and you want to enforce bot PRs):

- **`Dependency Updates / Test Dependency Updates`**: runs analyze + coverage on dependency update PRs.

## Merge queue compatibility

If merge queue enabled for `main`, these workflows must trigger on `merge_group`:

- [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml)
- [`.github/workflows/dependency-review.yml`](../../.github/workflows/dependency-review.yml)
- [`.github/workflows/osv-scanner-pr.yml`](../../.github/workflows/osv-scanner-pr.yml)

## Drift checks (scheduled)

Workflow: [`.github/workflows/drift.yml`](../../.github/workflows/drift.yml)

- **nightly**: `./bin/checklist`
- **weekly**: `./bin/upgrade_validate_all`

## Local equivalents

- Full merge gate: `./bin/checklist`
- Fast docs/tooling sanity: `./bin/checklist-fast`
- Router/auth gates: `./bin/router_feature_validate`
- Early integration/bootstrap guardrails: `./bin/integration_preflight`
- Integration flows: `./bin/integration_tests`

## Integration preflight on PRs

`CI / integration-preflight` now runs automatically on:

- `pull_request`
- `merge_group`

It executes `./bin/integration_preflight` as an early browser/bootstrap/import
guard before any slower simulator-based integration lane is requested.

## Manual integration rollout

Workflow-dispatch integration uses two macOS jobs in order when `run_integration`
is enabled:

- **`CI / integration-preflight`**: runs `./bin/integration_preflight`
- **`CI / integration`**: runs `./bin/integration_tests` only after preflight passes

Workflow inputs:

- `integration_tier`: `smoke` | `standard` | `exhaustive` (maps to suite entry files;
  see [`engineering/integration_runner_contract.md`](integration_runner_contract.md))
- `integration_phase`: `observe` | `non_blocking` | `enforced` (rollout strictness)

This keeps browser/bootstrap/import/patch drift failures visible before the
slower simulator lane starts.
