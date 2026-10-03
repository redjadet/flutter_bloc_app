# Agent pre-complete gate + checklist analyze/tests

## Why

Agents could treat format-only or `checklist-fast` as enough closeout proof.
Operators need a single mandatory pre-done gate (format → analyze → targeted
tests) and a guarantee that full `./bin/checklist` keeps `flutter analyze` and
Flutter tests.

## What changed

- Owner: [`agent_kb/legibility_and_finish_gate.md`](../agent_kb/legibility_and_finish_gate.md) § Agent pre-complete gate
- Thin pointers: [`AGENTS.md`](../../AGENTS.md), operating manual, quick reference, validation routing, durable prefs, delivery-workflow skill, always-on `agent-execution`, [`CODEMAP.md`](../../CODEMAP.md), [`ai/README.md`](../ai/README.md), [`engineering/README.md`](../engineering/README.md)
- Fixed operating-manual misroute that listed `./bin/checklist-fast` as the broad/full test lane
- Fixed [`quick_start.md`](../quick_start.md) row that treated `checklist-fast` as generic narrow/pre-commit
- Checklist audit: full path already runs Step 3 `flutter analyze` + Step 5 `tool/test_coverage.sh`; locked with `tool/check_checklist_cli_contract.sh` needles so they cannot be stripped for a lighter full gate
- Docs-only / `checklist-fast` remain separate documented shortcuts; agents still run the three-gate minimum (docs-only may skip tests with an explicit Verification note)
- Restored root [`README.md`](../../README.md) **image badges at the top** (after title, before prose); removed collapsed footer badge burial
- Living-docs audit (this pass): Flutter/Dart pins already matched tip (`3.47.6` / `3.13.5`); left intentional gitignored tracker links and historical `docs/changes/**` alone

## Verify

- `bash tool/check_checklist_cli_contract.sh`
- `bash tool/check_agent_knowledge_base.sh`
- `bash tool/check_docs_gardening.sh`
- Agent pre-complete gate on this docs/tooling change (format N/A; analyze N/A docs-only; tests = contract scripts above)
