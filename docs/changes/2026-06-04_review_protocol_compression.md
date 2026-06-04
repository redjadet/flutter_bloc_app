# Review protocol compression (2026-06-04)

## Goal

Tighten [`docs/ai_code_review_protocol.md`](../ai_code_review_protocol.md) for token load without weakening review coverage or mechanical guards.

## Changes

- Shorter intro and pointer block (legibility/finish gate, validation routing, closeout).
- Checks table: compressed “What to ask” cells; merged operational/tool/legibility rows; kept architecture, security, UI, Scope discipline, Self-verification anchors.
- “Before Accepting”: 10 → 8 steps; same intent.
- Special Cases: bold labels, same tool paths and Hive/widget/async rules.

## Preserved

- `tool/check_agent_knowledge_base.sh` substrings: `Before report`, `DESIGN.md`, `design_system.md`, `Scope discipline`, `Self-verification`, `Self-verify`.
- `## Special Cases` + `#special-cases` anchor (validation routing bug-fix link).
- Risk matrix, validation script list, cross-host explicit-request gate.

## Proof

```bash
bash tool/check_agent_knowledge_base.sh
wc -l docs/ai_code_review_protocol.md
```
