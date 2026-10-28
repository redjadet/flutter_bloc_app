# AI Flutter review pitfalls → agent gates

## Summary

Map seven recurring Flutter agent failure classes into existing owners: AGENTS
entry, `ai_failure_risks` slip-class table, security checklist (auth≠ownership,
no unrequested Cloud/Edge functions), review playbook risk order
(security → correctness → architecture), `bloc_standards` ChangeNotifier ban for
feature state, and `agents-common-pitfalls` rows. Analyzer already errors
`unawaited_futures`, `discarded_futures`, and `use_build_context_synchronously`.

## Why

Agents kept reinventing backend functions, treating signed-in as ownership,
using async `forEach`, inventing config, or slipping `ChangeNotifier` into a
Cubit/BLoC portfolio. Coverage existed in pieces; entry maps and review order
were incomplete.

## Proof

- `bash tool/check_ai_failure_risk_register.sh`
- Docs gardening / agent closeout for host-skill template sync when applicable
- CI: `check_agent_asset_drift.sh` applies host assets when `CI` is set (empty
  runner HOME), then verifies — unblocks AGENTS/template docs-only PRs
