# Agent docs token compression (2026-06-04)

## Goal

Reduce frequently loaded agent instruction context without weakening mechanical checks or cold-start anchors.

## Changes

- [`docs/agent_knowledge_base.md`](../agent_knowledge_base.md): traps → table; merged progressive-disclosure + file-discovery pointers; tightened prompt/session/capability prose; removed duplicate § Context Navigation Ladder (pointer lives under Progressive Disclosure).
- [`docs/agents_quick_reference.md`](../agents_quick_reference.md): shorter intro; harness anchors kept for `check_agent_knowledge_base.sh`.
- [`docs/agent_kb/adaptive_execution.md`](../agent_kb/adaptive_execution.md): compressed numbered list + search budget.
- [`tool/agent_host_templates/cursor/rules/agents-global.mdc`](../../tool/agent_host_templates/cursor/rules/agents-global.mdc): merged sections; same guardrails, fewer lines when rule is engaged.
- [`docs/audits/dedup_matrix_2026-05-22.md`](../audits/dedup_matrix_2026-05-22.md): recorded pass.

## Preserved

- All `tool/check_agent_knowledge_base.sh` required substrings and ≤200-line budgets on hot paths.
- Canonical numbered ladder: [`docs/ai/context_loading.md`](../ai/context_loading.md) only.
- Validation chooser table: [`docs/agents_quick_reference.md`](../agents_quick_reference.md) § Validation Chooser.
- [`AGENTS.md`](../../AGENTS.md) map-only shape (unchanged).

## Proof

```bash
bash tool/check_agent_knowledge_base.sh
wc -l AGENTS.md docs/agent_knowledge_base.md docs/agents_quick_reference.md docs/agent_kb/adaptive_execution.md
```
