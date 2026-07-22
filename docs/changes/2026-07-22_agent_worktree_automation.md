# Safe agent worktree automation

## Why

AI agents repeatedly assembled `git worktree add` commands by hand. Branch,
base-ref, and adjacent-path checks were prose-only, increasing setup time and
collision risk.

## Decision

`./bin/agent-worktree --name <task>` now prints a complete plan. Explicit
`--apply` creates the branch and worktree only after validating the local base
ref, new branch, parent directory, target path, and registered worktrees.

`./bin/agent-maintain worktree` exposes the same operation through the common
agent command surface. Neither entrypoint fetches, deletes, reuses, or
overwrites refs or paths.

## Regression capture

- Bug class: plan-only closeout executed a state-dependent freshness gate.
- Root cause: `cmd_closeout` applied plan mode to composed stages but not its
  final scorecard-freshness stage.
- Fix: plan mode now emits the exact freshness command without executing it.
- Prevention: `check_checklist_cli_contract.sh` asserts the planned stage while
  harness inputs are modified in the active worktree.

## Verification

- `bash tool/create_agent_worktree_test.sh`
- `bash tool/check_checklist_cli_contract.sh`
- `./bin/checklist-fast --no-reuse`
- `./bin/agent-maintain closeout`
