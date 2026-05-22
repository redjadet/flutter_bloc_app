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
| Missing capability beats retry. | Repeated failure => add doc/tool/test/fixture/script. |
| Enforce invariants, not taste. | Automate boundaries; keep local implementation freedom. |
| Tools beat prompts. | Prefer repo/MCP/browser/connector evidence over longer instructions. |
| Clarity compounds output. | Vague requirements create vague systems faster; define boundaries and proof before generation. |
| Outcome beats process bloat. | Treat agents as senior engineers: give Goal / Context / Boundaries / Verification; exact steps only when repo safety requires them. |
| Harness beats model choice. | Protect context, memory, orchestration, and recovery; switch strategy when session state degrades. |

## AI Productivity Traps (And How This Repo Avoids Them)

AI can be slower when it produces “almost correct” code: polished surface, subtle mismatches. Flutter amplifies mismatch cost (widget trees, rebuild/state, architectural seams).

Repo guardrails:

- **AI output not default implementation**: treat as draft; prefer smallest coherent change inside existing seams (Clean Architecture, Cubit/BLoC, DI, GoRouter).
- **Stop re-prompt loops**: if 2 cycles of “almost right” appear, stop generating. Switch to evidence: read owning code/docs, implement manually, add missing fixture/test/script.
- **Prefer micro-edits over rewrites**: patch exact failing line(s) instead of regenerating whole files/widgets.
- **Early proof beats late polish**: run narrowest honest validation lane early (see [`agents_quick_reference.md`](agents_quick_reference.md)). Catch subtle issues before they spread.
- **Architecture consistency beats local correctness**: “works in isolation” code that violates repo patterns is net loss; align first, then iterate.
- **System shape beats screen shape**: start from feature/domain boundary, dependency graph, and contracts. Avoid screen-centric rewrites, giant cubits/view models, hidden dependencies, and cross-feature leakage.
- **Capabilities beat concrete classes**: reusable widgets/services receive narrow callbacks or domain/core ports, not feature implementations, when that keeps ownership explicit and tests cheap.
- **Boring seams beat clever abstractions**: add interfaces, mixins, or shared services only when they remove repeated behavior or hide an external dependency; do not add indirection for style.

## Progressive Disclosure

**Ladder (canonical numbered steps):** [`docs/ai/context_loading.md`](ai/context_loading.md) only. After ladder: this doc (rules) → project context → review protocol → [`agents_quick_reference.md`](agents_quick_reference.md) (commands) → task docs via [`README.md`](README.md). UI: [`../DESIGN.md`](../DESIGN.md) + [`design_system.md`](design_system.md).

## Adaptive Execution

Owner: [`agent_kb/adaptive_execution.md`](agent_kb/adaptive_execution.md)

Required anchors (kept here for mechanical checks):

- unsafe ambiguity below 95% confident
- 95% confident
- Before report
- Stop when value met

## Tool Orchestration

Owner: [`agent_kb/tool_orchestration.md`](agent_kb/tool_orchestration.md)

## Prompt Hygiene

Agent-facing guidance stays short, stable, outcome-first.

- Use `Goal / Context / Boundaries / Verification`; context = task-relevant repo facts only.
- Stable doctrine first, task context last.
- Prefer success criteria, evidence, side effects, stop/report contract over long process scripts.
- Exact order only for safety, validation, migrations, codegen, destructive work, or repo-required workflows.
- Delete stale, duplicate, or nonessential instructions once script/test/doc owns invariant.
- Add date/timezone only for task policy, user locale, or time-sensitive evidence.

## Long Session Health

Agent quality depends on harness architecture: context management, memory tiering, orchestration, cache/tool-output discipline, and failure recovery.

- Treat memory as layers: in-context facts for active work, persistent files for durable evidence, and instruction files for rules that must survive summarization.
- Compact tool output to decisions, evidence, paths, and blockers; do not carry long logs when a precise pointer is enough.
- Watch circuit-breaker symptoms: repeated contradictions, stale file claims, lost goal, invented tool output, or circular repair attempts.
- After two failed repair loops or clear context drift, stop generation, reread source files, restate Goal / Context / Boundaries / Verification, then continue from verified state.
- If reset was needed because repo guidance was missing, add the smallest durable capability: doc pointer, script, test, fixture, skill, or automation rule.

## Agent Legibility

Owner: [`agent_kb/legibility_and_finish_gate.md`](agent_kb/legibility_and_finish_gate.md)

## Missing Capability Loop

don't answer repeated failure with bigger prompt.

1. Identify missing capability: context, tool, fixture, test, script, ownership boundary, acceptance criterion.
2. Add smallest durable repo capability.
3. Validate directly.
4. Update host templates only if Codex/Cursor need cold-start discovery.
5. Remove stale guidance once mechanical guard covers it.

Examples: route mistake -> route validator/doc; repeated review comment -> invariant/linter/test helper; UI proof gap -> smoke path/screenshot/integration map.

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

Steps: [`docs/ai/context_loading.md`](ai/context_loading.md). Detail: [`agent_kb/memory_and_context_ladder.md`](agent_kb/memory_and_context_ladder.md)

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

Loop: [`AGENTS.md`](../AGENTS.md) § Loop. Execution: [`agent_kb/adaptive_execution.md`](agent_kb/adaptive_execution.md). Finish/report: [`agent_kb/legibility_and_finish_gate.md`](agent_kb/legibility_and_finish_gate.md). Review gate: [`ai_code_review_protocol.md`](ai_code_review_protocol.md). **Report after checking** request, diff, proof, blockers (details in legibility doc).

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
