# AI agent governance

Roles, handoffs, and stop conditions. Map entry: [`AGENTS.md`](../../AGENTS.md).

## Roles

| Role | Owns | Reads first | Output |
| --- | --- | --- | --- |
| Planner | Scope, phases, Feature Brief | [`PLAN.md`](../../PLAN.md), user request | Approved brief |
| Implementer | Code + tests in bounds | [`CODEMAP.md`](../../CODEMAP.md), [`CONTEXT_MAP.md`](../../ai/CONTEXT_MAP.md) | PR-sized diff |
| Reviewer | Correctness, architecture, tests | Diff, review protocol | Findings |
| Documenter | Canon docs, reports refresh | [`README.md`](../README.md) | Doc-only diff |
| Validator | Commands and evidence | quick reference | Pass/fail proof |

One session may hold multiple roles; declare role in PR description.

## Handoff protocol

1. Planner -> Implementer: Feature Brief linked; ARCH/REC IDs cited.
2. Implementer -> Reviewer: diff, validation output, test list.
3. Reviewer -> Implementer: blockers vs nits with file:line references.
4. Documenter -> Validator: markdownlint; add `check_agent_knowledge_base.sh` when agent docs change.

## Stop conditions (escalate to human)

- Cross-feature dependency without agreed port
- `lib/` change without tests when behavior changes
- AGENTS.md would exceed 120 lines
- Secrets or credentials in diff
- Ambiguity below 95% confidence on product behavior
- Repeated validation failure: same error twice means add repo script/doc, not longer prompt
- UX, visual, or naming preference without an agreed spec
- Architecture redesign outside the approved scope
- Product behavior decision not covered by brief or request
- Benchmarking, model training, or long-running experiments

## Context budget

[`context_loading.md`](context_loading.md) ladder; skill picks: [`skill_routing.md`](skill_routing.md). Expand only [`CONTEXT_MAP.md`](../../ai/CONTEXT_MAP.md) paths → barrel/DI as needed. No whole-feature tree scans unless refactoring.

## Evidence hygiene

- Cite `ai/reports/` or `docs/audits/` for architecture claims.
- Regenerate metrics after merge to main when structure changes.

## Related

- Review protocol: [`docs/ai_code_review_protocol.md`](../ai_code_review_protocol.md)
- Prompt patterns: [`prompt_patterns.md`](prompt_patterns.md)
- Context ladder: [`context_loading.md`](context_loading.md)
