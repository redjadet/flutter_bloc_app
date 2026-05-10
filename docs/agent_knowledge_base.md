# Agent Knowledge Base

Source of truth for agent workflow + where truth lives. Goal: progressive disclosure; open only task-needed files.

## Core Beliefs

| Belief | Repo rule |
| --- | --- |
| Context beats instructions. | Ground in real files, current docs, current diff, repo scripts. |
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
3. [`ai_code_review_protocol.md`](ai_code_review_protocol.md) before accepting AI-written code.
4. [`agents_quick_reference.md`](agents_quick_reference.md) for commands.
5. [`agent_environment_setup.md`](agent_environment_setup.md) for host/tool setup.
6. UI/design: root [`../DESIGN.md`](../DESIGN.md) + [`design_system.md`](design_system.md) before widgets/theme/Mix/typography/spacing/component work.
7. [`README.md`](README.md) for task docs.
8. Open only needed docs/code/tests/plans.

## Adaptive Execution

Scale effort to task value; default to one small loop.

1. Classify complexity/risk/scope/uncertainty; local/mechanical stays light.
2. Plan once (<=10 lines), then execute end-to-end.
3. Ask only hard blockers: missing credentials/tooling, unsafe ambiguity below 95% confident, or user-owned decision.
4. Do not edit until 95% confident in goal/scope/approach.
5. Vague/risky => assumptions, success criteria, boundaries, data flow, failure handling, smallest verifiable slice.
6. Broad/codegen work => name modules, ownership, I/O, persistence/sync, logs, dry-run/test seams, rollback.
7. Debug => reproduce/reason, isolate, fix cause, verify.
8. Before report, run finish gate: edge cases, failure paths, readability, operational clarity, breakage impact.
9. Stop when value met, material risks handled, proof matches scope.

Search budget:

- Single loop: plan -> tool -> observe -> revise. No disconnected plans.
- Branch only when risk pays: architecture, security, sync, migrations, CI, performance, or unclear root cause. Compare 2-3 candidate approaches with evidence, then continue one; do not produce multiple full diffs unless asked.
- Verifier/critique rejects => retry with concrete evidence once or twice, then replan/escalate.
- Empty/truncated/malformed tool output = failed observation; retry narrower, inspect raw output, or mark blocker.
- Keep stable/cacheable instructions before task-specific context in agent-facing docs/templates.

## Tool Orchestration

Use capabilities as an execution system, not decoration.

- Prefer direct repo scripts/tests/fixtures, code-review-graph, browser/app proof, and available MCP/connectors over model memory when they can observe the real system.
- Use external MCP/connectors only for state they own (GitHub/CI, browser runtime, databases, docs); keep secrets out of prompts and artifacts.
- Semantic search/code graph finds likely files; targeted raw reads still confirm before edits.
- Faster/mechanical tools or models may do repetitive edits only after the owner has fixed scope, write set, and validation; final judgment stays with the coordinating agent.
- More agents/tools are not automatically better. Add them when they reduce uncertainty, isolate context, or verify a risky decision.
- Setup details live in [`agent_environment_setup.md`](agent_environment_setup.md).

## Agent Legibility

Agents reason over inspectable state.

- Prefer app-visible proof: screenshots, widget tests, integration flows, route validators, emulator/browser evidence.
- Turn unclear goals into inspectable artifacts: acceptance criteria, data-flow sketch, fixture, dry-run, focused proof route.
- Non-trivial risk => define acceptance contract before broad execution; executable specs/tests beat model confidence.
- Keep state inspectable: tracker, task graph/checklist, commands, failures, retries, blocker.
- UI/design chain: [`../DESIGN.md`](../DESIGN.md) -> [`design_system.md`](design_system.md) -> `AppTheme` / `buildAppMixScope` / `AppStyles` / `UI`.
- Prefer repo-local logs/fixtures/schemas/examples/generated clients/test harnesses over chat-only claims.
- For UI/runtime work, expose narrow runnable surface first: route tile, demo control, smoke test, or fixture.

## Missing Capability Loop

Do not answer repeated failure with bigger prompt.

1. Identify missing capability: context, tool, fixture, test, script, ownership boundary, acceptance criterion.
2. Add smallest durable repo capability.
3. Validate directly.
4. Update host templates only if Codex/Cursor need cold-start discovery.
5. Remove stale guidance once mechanical guard covers it.

Examples: route mistake -> route validator/doc; repeated review comment -> invariant/linter/test helper; UI proof gap -> smoke path/screenshot/integration map.

## Finish Gate

Last 20% builds trust. Before report/commit, ask when suitable:

- Edge cases: empty, malformed, duplicate, concurrent, offline/resume, permission-denied, slow/large input.
- Failure paths: how errors surface, retry/rollback/idempotency, cleanup, user-visible state, logs/metrics.
- Readability: names, seams, comments, tests, and docs make the next change obvious.
- Operational clarity: run/verify/debug steps are discoverable from repo artifacts.
- Breakage impact: what fails first, blast radius, detection signal, and safe recovery path.

## Memory Compounding

Next session smarter, no bloated wiki.

- Treat source docs, ADRs, plans, changes, tests, scripts, fixtures, and host trackers as compiled memory.
- File reusable conclusions into owning source doc, `docs/changes/`, `docs/plans/`, or [`../tasks/lessons.md`](../tasks/lessons.md). Keep transient state in host trackers.
- Preserve source-of-truth boundaries: code/tests beat summaries; source docs beat host templates; user corrections beat inferred rules.
- Do not dump chat transcripts or generic summaries. Add compact, cited,
  actionable facts only.
- Prefer fat skills only for repeated, validated workflows with clear triggers/write scope/tools/quality bar. No cron/autonomous behavior without explicit user approval.
- Vendor skills may exist via Cursor plugins. If a vendor skill is high-frequency
  and bloats context, prefer **repo-owned shadow shims** synced into
  `~/.cursor/skills/` (same `name:`) that route to repo canon and keep hard gates.
- For this repo, prefer maps, `rg`, code-review-graph, and targeted
  validation over separate RAG layer.
- Semantic lint during doc/agent changes: stale plans, duplicate rules,
  source/host-template contradictions, reusable conclusions stranded in task
  notes.

## Context Navigation Ladder

Use when exact file is not known:

1. **Map layer:** [`AGENTS.md`](../AGENTS.md), this doc, [`README.md`](README.md), task docs.
2. **Memory layer:** owning docs, `docs/changes/`, `docs/plans/`, [`tasks/lessons.md`](../tasks/lessons.md), current tracker. Chat memory is pointer only; verify drift-prone facts.
3. **Structural layer:** code-review-graph or [`../tool/refresh_code_review_graph.sh`](../tool/refresh_code_review_graph.sh) `--status-only` / `--if-needed`.
4. **Raw-file layer:** targeted raw-file reads only for edit/proof. Use `rg` when graph is stale/missing/too broad.

Related: [`changes/2026-05-05_codex_context_navigation_ladder.md`](changes/2026-05-05_codex_context_navigation_ladder.md), [`code_review_graph.md`](code_review_graph.md).

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

See [`agent_knowledge_base_details.md`](agent_knowledge_base_details.md) for full mechanics. Required labels:

```text
Benefit: team - short reason
Benefit: single - short reason
```

Artifacts live under `tasks/cursor/team/<run-id>/`. Roles: **Coordinator**, **Specialists**: Researcher, Analyst, Implementer, Reviewer. Specialist output is **untrusted** until coordinator validates.

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

- Root [`AGENTS.md`](../AGENTS.md) = repo-local map.
- [`../tool/agent_host_templates/codex/AGENTS.md`](../tool/agent_host_templates/codex/AGENTS.md) = Codex host bootstrap synced to ~/.codex/AGENTS.md and worktrees.
- Behavior change order: owning source doc -> quick reference if command choice changed -> review protocol if acceptance changed -> Codex/Cursor templates if cold-start affected.
- After host-template changes: sync apply, dry-run, drift check.
- No Cursor-only/Codex-only workaround unless host capability differs; document delta in template, not source rule.

## Mechanical Enforcement

- `./tool/check_agent_knowledge_base.sh`: keeps [`AGENTS.md`](../AGENTS.md) short; checks required links, host-template pointers, closed-loop invariants.
- `./tool/check_agent_memory_compounding.sh`: source-aligned memory-compounding; autonomous action explicit-approval-gated.
- `./tool/validate_validation_docs.sh`: validation docs vs checklist scripts.
- `./tool/normalize_doc_links.py`: clickable local links.
- `./tool/check_agent_asset_drift.sh`: managed Cursor/Codex assets vs templates.
- `./bin/checklist`: full gate. `./bin/checklist-fast`: local-only clean/narrow docs/tooling.
- `.original.md` compression backups temporary; delete after verifying active docs.

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
