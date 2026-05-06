# CI Automation

This repo uses GitHub Actions as the merge gate + drift detector.

## Required checks (branch protection)

Require these checks on `main`:

- **`CI / build`**: runs `./bin/checklist` (analyze + repo static checks + mix_lint + coverage).
- **`Dependency Review / dependency-review`**: GitHub dependency review action.
- **`OSV-Scanner PR Scan / scan-pr`**: vulnerability scan of `pubspec.lock`.

Optional (only if Renovate/Dependabot are in use and you want to enforce bot PRs):

- **`Dependency Updates / Test Dependency Updates`**: runs analyze + coverage on dependency update PRs.

## Merge queue compatibility

If merge queue enabled for `main`, these workflows must trigger on `merge_group`:

- [`.github/workflows/ci.yml`](../.github/workflows/ci.yml)
- [`.github/workflows/dependency-review.yml`](../.github/workflows/dependency-review.yml)
- [`.github/workflows/osv-scanner-pr.yml`](../.github/workflows/osv-scanner-pr.yml)

## Drift checks (scheduled)

Workflow: [`.github/workflows/drift.yml`](../.github/workflows/drift.yml)

- **nightly**: `./bin/checklist`
- **weekly**: `./bin/upgrade_validate_all`

## Local equivalents

- Full merge gate: `./bin/checklist`
- Fast docs/tooling sanity: `./bin/checklist-fast`
- Router/auth gates: `./bin/router_feature_validate`
- Integration flows: `./bin/integration_tests`
