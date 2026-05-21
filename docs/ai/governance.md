# AI agent governance

Roles, handoffs, and stop conditions for multi-agent or long-session work. Map entry: [`AGENTS.md`](../../AGENTS.md).

## Roles

| Role | Responsibility | Reads first | Delivers |
| --- | --- | --- | --- |
| Planner | Scope, phases, Feature Brief | `PLAN.md`, user request | Plan / brief approval |
| Implementer | Code + tests in bounds | `CODEMAP.md`, `CONTEXT_MAP.md`, canon docs | PR-sized diff |
| Reviewer | Correctness, architecture, tests | Diff + `ai_code_review_protocol.md` | Actionable review |
| Documenter | Canon docs, reports refresh | `docs/README.md` | Doc PR only |
| Validator | Scripts, checklist | `agents_quick_reference.md` | Pass/fail proof |

One session may hold multiple roles; declare role in PR description.

## Handoff protocol

1. **Planner → Implementer:** Feature Brief linked; ARCH/REC IDs cited if applicable.
2. **Implementer → Reviewer:** Validation output pasted; test list explicit.
3. **Reviewer → Implementer:** Blockers vs nits labeled; file:line references.
4. **Documenter → Validator:** markdownlint + `check_agent_knowledge_base.sh` when AGENTS touched.

## Stop conditions (escalate to human)

- Cross-feature dependency without agreed port
- `lib/` change without tests when behavior changes
- AGENTS.md would exceed 120 lines
- Secrets or credentials in diff
- Ambiguity below 95% confidence on product behavior
- Repeated validation failure (same error twice) — add repo script/doc, not longer prompts

## Context budget

1. Load `CONTEXT_MAP.md` paths only.
2. Expand to feature barrel + DI if compile fails.
3. Avoid whole-feature ripgrep unless refactoring.

## Evidence hygiene

- Cite `ai/reports/` or `docs/audits/` for architecture claims.
- Regenerate metrics after merge to main when structure changes.

## Related

- Review protocol: [`docs/ai_code_review_protocol.md`](../ai_code_review_protocol.md)
- Prompt patterns: [`prompt_patterns.md`](prompt_patterns.md)
- Context ladder: [`context_loading.md`](context_loading.md)
