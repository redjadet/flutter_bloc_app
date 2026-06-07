# Cursor/Codex harness max-score contract

## Why

The repo now targets Cursor and Codex as primary AI maintainers. Future agents
need a durable way to verify the harness score instead of repeating audit prose.

## What changed

- Added deterministic feature and BLoC docs/skills.
- Added feature brief fail gate and feature scaffold preview/apply tool.
- Added `check_clean_architecture_imports.sh` for package and relative
  Clean Architecture import boundaries.
- Added `check_feature_folder_contract.sh` for cubit folder shape and banned
  legacy layers; wired into scorecard gate, harness fixtures, and checklist.
- Migrated continual-learning index keys to relative paths
  (`tool/transcript_index_path.dart`) so index stays under byte budget.
- Added [`ai/harness_scorecard.md`](../ai/harness_scorecard.md) as the max-score claim gate.
- Added [`ai/ai_failure_risks.md`](../ai/ai_failure_risks.md) and
  `tool/check_ai_failure_risk_register.sh` to keep prevention, detection, and
  recovery rules enforceable.
- Added `tool/check_harness_scorecard_gate.sh` and `./bin/agent-maintain harness`
  so scorecard owners, risk register, quick reference, skill routing, and host
  skill declarations are checked automatically.
- Added a README harness score badge linked to the scorecard and enforced it in
  `tool/check_harness_scorecard_gate.sh`.
- Added `tool/update_harness_score_badge.sh`; `./bin/agent-maintain harness`
  now derives the README badge from the scorecard table before gating.
- Wired the harness gate into `./bin/checklist-fast`, `./bin/checklist`, and
  `./bin/agent-maintain closeout` through `docs-sync` for docs/tooling scopes.
- Synced shared host skills to Cursor and Codex through repo host templates.

## Proof

Required proof before claiming `10/10`:

```bash
bash tool/check_harness_scorecard_gate.sh
bash tool/check_ai_failure_risk_register.sh
bash tool/check_agent_asset_drift.sh
./bin/checklist-fast --no-reuse
./bin/agent-maintain closeout
```

Use `./bin/checklist` instead of fast mode when app/runtime code changed.
