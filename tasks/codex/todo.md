# Codex Task Tracker

## Goal

Review commit `2ac10278` against live integration and validation tooling; patch
only confirmed documentation-integrity issues.

## Write-set

- `docs/engineering/integration_runner_contract.md`
- `docs/testing_integration_flows.md`
- `docs/validation_scripts/catalog.md`
- `docs/validation_scripts/overview.md`
- `tool/validate_validation_docs.sh`
- `tasks/codex/todo.md`

## Risks

- Documenting a CI suite that current workflow does not run.
- Letting manually documented script counts drift from disk/checklist inventory.
- Making validation-doc sync reject intentionally undocumented helpers.

## Validation command

```bash
bash tool/validate_validation_docs.sh
bash tool/check_docs_gardening.sh --paths docs/engineering/integration_runner_contract.md docs/testing_integration_flows.md docs/validation_scripts/catalog.md docs/validation_scripts/overview.md
bash tool/validate_task_trackers.sh
./bin/checklist-fast --explain
git diff --check
```

## Evidence/result

- Completed: compared commit docs with `.github/workflows/ci.yml`,
  `tool/run_integration_tests.sh`, and `tool/delivery_checklist.sh`.
- Completed: found false PR integration-suite claim and unguarded inventory
  count/full-disk sync claims.
- Completed: new count guard exposed existing macOS `sed` parser as a no-op;
  replaced it with Bash regex extraction.
- Completed: focused validation and `./bin/checklist-fast --explain` passed.
