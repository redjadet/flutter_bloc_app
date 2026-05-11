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

## Progressive Disclosure

1. [`AGENTS.md`](../AGENTS.md) map.
2. This doc for agent rules + source layout.
3. [`agent_project_context.md`](agent_project_context.md) for project-specific/version-specific caveats.
4. [`ai_code_review_protocol.md`](ai_code_review_protocol.md) before accepting AI-written code.
5. [`agents_quick_reference.md`](agents_quick_reference.md) for commands.
6. [`agent_environment_setup.md`](agent_environment_setup.md) for host/tool setup.
7. UI/design: root [`../DESIGN.md`](../DESIGN.md) + [`design_system.md`](design_system.md) before widgets/theme/Mix/typography/spacing/component work.
8. [`README.md`](README.md) for task docs.
9. Open only needed docs/code/tests/plans.

## Adaptive Execution

Owner: [`agent_kb/adaptive_execution.md`](agent_kb/adaptive_execution.md)

Required anchors (kept here for mechanical checks):

- unsafe ambiguity below 95% confident
- 95% confident
- Before report
- Stop when value met

## Tool Orchestration

Owner: [`agent_kb/tool_orchestration.md`](agent_kb/tool_orchestration.md)

## Agent Legibility

Owner: [`agent_kb/legibility_and_finish_gate.md`](agent_kb/legibility_and_finish_gate.md)

## Missing Capability Loop

Do not answer repeated failure with bigger prompt.

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

Owner: [`agent_kb/memory_and_context_ladder.md`](agent_kb/memory_and_context_ladder.md)

## System Of Record Layout

Details moved to keep this file small. See:

- [`agent_knowledge_base_details.md`](agent_knowledge_base_details.md) (system-of-record table, multi-agent hub mechanics, invariants, host notes)

Required anchors (kept here for agent checks; details in the linked doc):

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

1. Start from map; open only task-relevant sources.
2. Record non-trivial scope, risks, write set, validation target in tracker.
3. Make task legible before coding: current files, runnable surface, fixtures, logs, route proof, or acceptance criteria.
4. Implement smallest coherent slice inside existing seams.
5. Validate deterministic checks/specs first, then risk-based review.
6. Compact tool/subagent results to decisions, evidence, paths, and blockers.
7. Repeated context/review failure => add durable repo capability.
8. Sync host assets when agent behavior changed.
9. Report after checking final answer against request, changed files, proof, blockers, residual risk.

## Host Parity

Owner: [`agent_kb/host_parity_and_enforcement.md`](agent_kb/host_parity_and_enforcement.md)

## Mechanical Enforcement

Owner: [`agent_kb/host_parity_and_enforcement.md`](agent_kb/host_parity_and_enforcement.md)

New durable agent rule: update owning source doc first, then thin host templates, then validation if rule needs mechanical check.

## Operator Preferences (Durable)

Keep [`AGENTS.md`](../AGENTS.md) lean map; put behavioral detail here.

- Fix failures in **product code/DI/config** first; do not “pass” checks by weakening scripts or validators (only change scripts for demonstrated false positives).
- Treat analyzer warnings/info and lints as **code fixes** first (structure, l10n, mounted guards); avoid broad ignore comments when a proper fix fits.
- After meaningful workflow/policy shifts, update agent-facing docs referenced from the map (knowledge base, quick reference, review protocol, validation docs, and host templates when cold-start changes).

Repo fact:

- `./bin/checklist-fast` runs a report-only skill-budget pass when a skill inventory file resolves (`docs/audits/skill_inventory_latest.json`, otherwise newest dated `docs/audits/skill_inventory_*.json`); implemented in `tool/check_skill_budgets.sh`.

## Doc Gardening

- If behavior changes, update owning source doc in same change.
- Obsolete plan => mark historical or move durable decision into ADR/source doc.
- Doc contradicts code => trust code/tests, then repair doc.
- Move tracker reusable conclusions into source doc, `docs/changes/`, or [`tasks/lessons.md`](../tasks/lessons.md).
- Remove stale host-template rules; keep source docs smaller.
- For broad doc sweeps, run targeted markdown/link checks; escalate to `./bin/checklist` when validation or agent policy changes materially.
