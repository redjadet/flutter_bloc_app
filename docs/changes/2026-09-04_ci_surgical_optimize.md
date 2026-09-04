# CI surgical optimize (2026-09-04)

## Why

CI workflows had clear waste and drift: macOS minutes for Chrome-only preflight,
duplicated Flutter setup steps, a redundant bot analyze/coverage workflow, CodeQL
ruby with no first-party sources, and Dependabot missing actions/npm ecosystems.

## What changed

- Composite action `.github/actions/setup-flutter-workspace` (Flutter + pub get + optional ripgrep/lcov/Chrome).
- `CI / integration-preflight` → `ubuntu-latest` + Chrome (job name unchanged for branch protection).
- Removed `.github/workflows/dependency-updates.yml` (duplicate of `CI / build` on bot PRs).
- CodeQL: drop `ruby`; keep PR/push/merge_group coverage for remaining languages.
- Dependabot: add `github-actions` and `npm` (`backend/firebase/functions`);
  `open-pull-requests-limit: 0` so only security-update PRs open (Renovate owns routine bumps).
- `actions/setup-node@v7`; Functions/CI Node pin `24.20.0`; `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24` on CodeQL + OSV.
- Docs: `docs/engineering/ci_automation.md`; toolchain sink list drops deleted workflow.

## Non-goals

- Did not remove CodeQL from PRs.
- Did not change required check names.
- Did not alter checklist / coverage thresholds.
