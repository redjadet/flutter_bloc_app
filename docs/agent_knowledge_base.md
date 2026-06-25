# Agent Knowledge Base

Source of truth for agent workflow + where truth lives. Goal: progressive disclosure; open only task-needed files.

## Core Beliefs

| Belief | Repo rule |
| --- | --- |
| Context beats instructions. | Ground in real files, current docs, current diff, repo scripts. |
| Project facts beat generic Flutter tips. | Open project/version caveats before relying on model memory. |
| Closed loop. | Plan once, execute end-to-end, verify, report proof. |
| AI output = draft. | Review gate + scope-matched validation before trust. |
| Codebase = memory. | Durable facts live in docs/plans/tests/scripts/ADRs, not chat. |
| Retrieval beats recall. | Search/retrieve owning repo artifacts before answering from model memory. |
| Missing capability beats retry. | Repeated failure => add doc/tool/test/fixture/script. |
| Enforce invariants, not taste. | Automate boundaries; keep local implementation freedom. |
| Tools beat prompts. | Prefer repo/MCP/browser/connector evidence over longer instructions. |
| Harness beats model choice. | Optimize prompts, evaluators, tests, runtime checks, and feedback loops before blaming the model. |
| Clarity compounds output. | Vague requirements create vague systems faster; define boundaries and proof before generation. |
| Outcome beats process bloat. | Treat agents as senior engineers: give Goal / Context / Boundaries / Verification; exact steps only when repo safety requires them. |
| Session harness beats willpower. | Protect context, memory, orchestration, and recovery; switch strategy when session state degrades. |

## AI Productivity Traps

“Almost correct” AI output costs more in Flutter (widgets, state, seams). Repo response:

| Trap | Response |
| --- | --- |
| Draft treated as ship | Draft until review; smallest change in Clean Architecture / Cubit/BLoC / DI / GoRouter seams |
| Re-prompt loops | After 2 “almost right” cycles: read owning code/docs, patch manually, add fixture/test/script |
| Full rewrites | Micro-edit failing lines; do not regenerate whole files/widgets |
| Late validation | Narrowest lane early — [`agents_quick_reference.md`](agents_quick_reference.md) |
| Local-only correctness | Align architecture before local fixes |
| Screen-shaped changes | Feature/domain boundary + contracts first; no giant cubits or cross-feature leakage |
| Concrete coupling | Reusable UI gets narrow callbacks/ports, not feature types |
| Style abstractions | New indirection only for repeated behavior or external deps |

## Business logic must be separated from UI (agent rule)

Short rule: **keep widgets/pages dumb**. `build()` renders only; business rules,
derived data, and async work move to **cubit/state** (presentation) or **domain**.

Owner docs: [`clean_architecture.md`](clean_architecture.md) and
[`architecture/feature_structure_contract.md`](architecture/feature_structure_contract.md).
Detection scripts: `bash tool/check_solid_presentation_data_imports.sh`,
`bash tool/check_direct_getit.sh`.

Full agent-facing guidance lives in
[`agent_knowledge_base_details.md`](agent_knowledge_base_details.md)
§ “Business logic must be separated from UI”.

## Self-Improvement

Owner: [`agent_kb/self_improvement.md`](agent_kb/self_improvement.md)

Required anchors (kept here for mechanical checks):

- no verifier, no persistence
- Reflection
- Memory
- Scaffold evolution
- model fine-tuning
- Expected benefit
- version history

## Progressive Disclosure

After cold-start ladder (see § Context Navigation Ladder): this doc → [`agent_project_context.md`](agent_project_context.md) → [`ai_code_review_protocol.md`](ai_code_review_protocol.md) → [`agents_quick_reference.md`](agents_quick_reference.md) → task docs via [`README.md`](README.md). UI: [`../DESIGN.md`](../DESIGN.md) + [`design_system.md`](design_system.md).

## Adaptive Execution

Owner: [`agent_kb/adaptive_execution.md`](agent_kb/adaptive_execution.md)

Required anchors (kept here for mechanical checks):

- unsafe ambiguity below 95% confident
- 95% confident
- Before report
- Stop when value met

## Tool Orchestration

Owner: [`agent_kb/tool_orchestration.md`](agent_kb/tool_orchestration.md) · host maintain: [`agent_kb/host_maintenance_automation.md`](agent_kb/host_maintenance_automation.md) (`preflight` / `closeout` / `after-host-edit`)

## Prompt Hygiene

Short, stable, outcome-first: `Goal / Context / Boundaries / Verification`; prompts name the target, while evaluators/tests/runtime checks decide trust. Doctrine before task context; evidence/stop contract over long scripts; step order only for safety/validation/migrations/codegen/destructive/repo-required flows; delete prose once script/test/doc owns invariant.

## Long Session Health

Harness = context tiers + evaluators + tests + runtime checks + compact tool output + recovery. Keep in-context facts, file-backed evidence, and instruction rules separate. Log pointers, not dumps. Circuit-breakers: contradictions, stale paths, lost goal, invented tool output, repair loops. After two failed repairs or drift: reread sources, restate Goal / Context / Boundaries / Verification, continue from verified state; missing guidance → smallest durable doc/script/test/fixture.

## Agent Legibility

Owner: [`agent_kb/legibility_and_finish_gate.md`](agent_kb/legibility_and_finish_gate.md)

## Missing Capability Loop

Repeated failure → durable repo capability, not bigger prompt: identify gap (prompt, evaluator, runtime check, context, tool, fixture, test, script, boundary, acceptance) → add smallest fix → validate → sync host templates only for cold-start discovery → delete stale prose when a guard owns it. Post-bug procedure: `agents-regression-capture` skill.

## Finish Gate

Owner: [`agent_kb/legibility_and_finish_gate.md`](agent_kb/legibility_and_finish_gate.md)

Required anchors (kept here for mechanical checks):

- Self-verify
- Edge cases
- Failure paths
- Operational clarity
- Breakage impact

## Memory Compounding

Owner: [`agent_kb/memory_and_context_ladder.md`](agent_kb/memory_and_context_ladder.md)

Required anchors (kept here for mechanical checks):

- reusable conclusions
- Semantic lint
- File reusable conclusions
- Do not dump chat transcripts
- explicit user approval
- separate RAG layer
- code-review-graph
- targeted raw-file reads

## Context Navigation Ladder

Numbered steps: [`docs/ai/context_loading.md`](ai/context_loading.md) only. Before implementation, skill picks: [`docs/ai/skill_routing.md`](ai/skill_routing.md). Unnumbered discovery: [`agent_kb/memory_and_context_ladder.md`](agent_kb/memory_and_context_ladder.md).

## System Of Record Layout

Details moved to keep this file small. See:

- [`agent_knowledge_base_details.md`](agent_knowledge_base_details.md) (system-of-record table, multi-agent hub mechanics, invariants, host notes)

Required anchors (kept here for agent checks; details in linked doc):

- **Plans As Artifacts** (see details)
- **Invariant Enforcement** (see details)
- **Codex And Cursor** (see details)
- Trackers: [`../tasks/codex/todo.md`](../tasks/codex/todo.md), [`../tasks/cursor/todo.md`](../tasks/cursor/todo.md)
- **Surgical diffs** (see details)

## Multi-Agent Hub

Owner: [`agent_kb/multi_agent_hub.md`](agent_kb/multi_agent_hub.md)

Required anchors (kept here for mechanical checks):

```text
Benefit: team
Benefit: single
tasks/cursor/team/<run-id>/
Coordinator
Specialists
Researcher
Analyst
Implementer
Reviewer
untrusted
```

## Final Agent Contract

Loop: [`AGENTS.md`](../AGENTS.md) § Loop. Execution: [`agent_kb/adaptive_execution.md`](agent_kb/adaptive_execution.md). Finish/report: [`agent_kb/legibility_and_finish_gate.md`](agent_kb/legibility_and_finish_gate.md). Review gate: [`ai_code_review_protocol.md`](ai_code_review_protocol.md). **Report after checking** request, diff, proof, blockers (details in legibility doc). T1/T2 coding discipline: [`docs/ai/agent_operating_manual.md`](ai/agent_operating_manual.md).

## Host Parity

Owner: [`agent_kb/host_parity_and_enforcement.md`](agent_kb/host_parity_and_enforcement.md)

## Mechanical Enforcement

Owner: [`agent_kb/host_parity_and_enforcement.md`](agent_kb/host_parity_and_enforcement.md)

New durable agent rule: update owning source doc first, then thin host templates, then validation if rule needs mechanical check.

## Operator Preferences (Durable)

Owner: [`agent_kb/operator_preferences_durable.md`](agent_kb/operator_preferences_durable.md)

## Doc Gardening

- If behavior changes, update owning source doc in same change.
- Obsolete plan => mark historical or move durable decision into ADR/source doc.
- Doc contradicts code => trust code/tests, then repair doc.
- Move tracker reusable conclusions into source doc, `docs/changes/`, or [`tasks/lessons.md`](../tasks/lessons.md).
- Remove stale host-template rules; keep source docs smaller.
- **Agent-facing doc size:** keep long harness docs at **≤200 lines** per file; use a thin router + shards (example: [`validation_scripts.md`](validation_scripts.md) → [`validation_scripts/`](validation_scripts/)).
- For broad doc sweeps, run targeted markdown/link checks; escalate to `./bin/checklist` when validation or agent policy changes materially.
