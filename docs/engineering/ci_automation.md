# CI Automation

This repo uses GitHub Actions as the merge gate + drift detector.

## Required checks (branch protection)

Workflow runs create check results; they enforce a merge gate only when live
branch protection or a ruleset requires them. Before merge, confirm the checks
below passed on the submitted PR head and were not skipped. Treat live GitHub
settings as the enforcement source of truth; this list is the project policy.

Require these check contexts on `main` (verified in branch protection on
2026-09-23; recheck live settings before merge):

- **`build`** (`CI / build`): runs `./bin/checklist` (analyze + repo static checks + mix_lint + coverage).
- **`integration-preflight`** (`CI / integration-preflight`): runs `./bin/integration_preflight` on code-relevant PRs / merge queue (Ubuntu + Chrome web smoke + unit guards) before slower simulator lanes.
- **`dependency-review`** (`Dependency Review / dependency-review`): GitHub dependency review action.
- **`scan-pr / osv-scan`** (`OSV-Scanner PR Scan`): vulnerability scan of `pubspec.lock`.

Renovate / Dependabot PRs are gated by the same **`CI / build`** check — there is no
separate duplicate analyze/coverage workflow.

## Documentation-only PRs

`CI / changes` uses `./bin/checklist --print-scope` on the PR merge commit.
`build` still runs `./bin/checklist`, but skips Flutter
installation and coverage upload when every changed path is documentation.
The checklist then runs documentation, agent-knowledge, harness, and snapshot
checks without app analyze/tests/coverage. `integration-preflight` still reports
a successful required check, with its Flutter/Chrome work bypassed. The
dependency-review and OSV required checks remain present.

The scope rule accepts Markdown/MDX/reStructuredText/AsciiDoc files and root
`llms.txt`. Empty, unknown, mixed,
configuration, workflow, script, dependency, and source diffs use full CI.
`tool/checklist_scope.sh` owns this rule; `tool/check_checklist_cli_contract.sh`
tests adversarial path examples. Keep required job names stable, since branch
protection names `build` and `integration-preflight`.
CodeQL uses the same scope command and skips its language matrix for
documentation-only PR diffs; its code scans remain active for all other scopes.
Push and merge-queue events take the full route: their one-parent diff may omit
earlier commits in a batch.

## Shared Flutter setup

Flutter install + `tool/workspace_pub_get.sh` (+ optional apt: ripgrep, lcov, Chrome)
live in the composite action
[`.github/actions/setup-flutter-workspace`](../../.github/actions/setup-flutter-workspace/action.yml).
Workflows pass `flutter-version: ${{ env.FLUTTER_VERSION }}`; keep pins synced via
`docs/toolchain_versions.env` / `tool/update_agent_toolchain_versions.py`.

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

`CI / integration-preflight` runs its integration command on code-relevant:

- `pull_request`
- `merge_group`

Runner: **`ubuntu-latest`** (not macOS). The job installs Chrome when needed and
executes `./bin/integration_preflight` (SwiftPM patch syntax/guard, log-filter
unit test, Chrome web bootstrap smoke). Documentation-only PRs keep the
required job green without installing Flutter or Chrome. Job
**name** stays `integration-preflight` so branch protection does not need updating.

## Manual integration rollout

Workflow-dispatch integration uses two jobs in order when `run_integration`
is enabled:

- **`CI / integration-preflight`**: Ubuntu Chrome / unit guards (`./bin/integration_preflight`)
- **`CI / integration`**: macOS simulator lane (`./bin/integration_tests`) only after preflight passes

Workflow inputs:

- `integration_tier`: `smoke` | `standard` | `exhaustive` (maps to suite entry files;
  see [`engineering/integration_runner_contract.md`](integration_runner_contract.md))
- `integration_phase`: `observe` | `non_blocking` | `enforced` (rollout strictness)

This keeps browser/bootstrap/import/patch drift failures visible before the
slower simulator lane starts.

## CodeQL

[`.github/workflows/codeql.yml`](../../.github/workflows/codeql.yml) runs on PR,
push, merge_group, and weekly schedule for languages this repo ships meaningfully:
`actions`, `c-cpp` (`native/`), `javascript-typescript`, `python`. Ruby is omitted
(no first-party Ruby sources).
