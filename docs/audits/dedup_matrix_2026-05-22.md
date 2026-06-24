# Agent instruction dedup matrix (2026-05-22; pass 2026-06-04)

Classify before edit. **Canonical** = single owner; others → pointer. **Echo** = minimal repeat for cold-start/CI anchors.

**2026-06-04 pass:** Compressed [`agent_knowledge_base.md`](../agent_knowledge_base.md) (traps table, merged ladder pointer, dropped duplicate § Context Navigation Ladder), [`agents_quick_reference.md`](../agents_quick_reference.md) harness intro, [`agent_kb/adaptive_execution.md`](../agent_kb/adaptive_execution.md), host `agents-global.mdc` — mechanical anchors unchanged; `check_agent_knowledge_base.sh` green.

**2026-06-04 review-protocol pass:** Compressed [`ai_code_review_protocol.md`](../ai_code_review_protocol.md) (tighter checks table, merged ops/tool rows, pointer to [`legibility_and_finish_gate.md`](../agent_kb/legibility_and_finish_gate.md)); `#special-cases` and CI substrings preserved.

**2026-06-08 agent-doc pass:** Fixed broken `agent-maintain` command link; renamed AGENTS Map `Harness` → `Doctrine`; thinned host-maintain echoes in delivery-workflow skill, [`harness_auto_maintenance.md`](../ai/harness_auto_maintenance.md), quick ref host row, `agent-maintain` command; deduped AGENTS Start vs Loop Pre-Flight. Gate-required quick-ref harness anchors (`Harness max-score claim`, `Benefit: team`, etc.) stay **Echo** until `check_agent_knowledge_base.sh` relaxes needles.

| Theme | File | Class | Action |
| --- | --- | --- | --- |
| Context ladder (numbered) | [`ai/context_loading.md`](../ai/context_loading.md) | Canonical | Keep only numbered ladder |
| Context ladder | [`agent_knowledge_base.md`](../agent_knowledge_base.md) § Progressive Disclosure | Echo | Keep one-line “then AKM → …”; no second numbered list |
| Context ladder | [`agents_quick_reference.md`](../agents_quick_reference.md) § Harness | Echo | Pointer + gate anchors (`Benefit: team`, etc.); not a second numbered ladder |
| Context ladder | agents-quick-reference SKILL (host template) | Skill-echo | Point to context_loading.md, not AKM |
| Context ladder | agents-global.mdc (host template) | Skill-echo | One-line pointer; drop prose ladder |
| Context ladder | agents-delivery-workflow SKILL (host template) | Skill-echo | Pointer only |
| Context ladder | flutter-bloc-app Codex skills (host template) | Skill-echo | Pointer only |
| Validation chooser | [`agents_quick_reference.md`](../agents_quick_reference.md) § Validation Chooser | Canonical | Keep full table |
| Validation chooser | flutter-bloc-app-quick-reference SKILL (host template) | Stale | Remove inline picks; link § Validation Chooser |
| Validation chooser | agents-validation-testing SKILL (host template) | Echo | Keep repo-specific rows only |
| Loop / report proof | [`AGENTS.md`](../../AGENTS.md) § Loop | Canonical (short) | Keep |
| Loop / report proof | [`agents_quick_reference.md`](../agents_quick_reference.md) | Echo | Mechanical anchors only; canon in AGENTS § Loop |
| Loop / report proof | [`agent_knowledge_base.md`](../agent_knowledge_base.md) | Echo | Anchors only |
| Multi-agent hub | [`agent_kb/multi_agent_hub.md`](../agent_kb/multi_agent_hub.md) + AKM § Hub | Canonical | Keep anchors in AKM |
| Multi-agent hub | [`agents_quick_reference.md`](../agents_quick_reference.md) § Harness | Echo | Link `#multi-agent-hub` + Benefit rows (gate-required) |
| Key file paths | agents-references SKILL (host template) | Stale | Collapse to categories + CODEMAP / rg |
| Key file paths | [`agent_project_context.md`](../agent_project_context.md) | Canonical | Topic table stays |
| Widget tests | [`testing_overview.md`](../testing_overview.md) + playbook | Canonical | — |
| Widget tests | agents-global.mdc (host template) | Echo | Playbook pointer; no repo-wide WidgetTester.view until harness |
| Widget tests | codex AGENTS.md (host template) | Resolved | Matches root AGENTS.md — playbook pointer, no blanket WidgetTester.view |
| UI / Mix | [`DESIGN.md`](../../DESIGN.md), [`design_system.md`](../design_system.md) | Canonical | — |
| Codex map | [`AGENTS.md`](../../AGENTS.md) | Canonical | Root source |
| Codex map | codex AGENTS.md (host template) | Echo | Codex-only deltas only |
| Host sync flow | [`agent_kb/host_parity_and_enforcement.md`](../agent_kb/host_parity_and_enforcement.md) | Canonical | dry-run → apply → dry-run clean → drift check |
| Host sync flow | [`agents_quick_reference.md`](../agents_quick_reference.md) + [`agent_host_notes.md`](../agent_host_notes.md) + operator prefs | Echo | Keep same command order, no piecemeal host edits |
| Cross-host review | [`agents_quick_reference.md`](../agents_quick_reference.md) | Canonical | Explicit request only |
| Cross-host review | [`agent_host_notes.md`](../agent_host_notes.md) | Echo | Cursor/Codex caveat must preserve explicit-request gate |
| Cold-start numbered ladder | [`ai/context_loading.md`](../ai/context_loading.md) | Canonical | Only numbered load-order list |
| File discovery layers | [`agent_kb/memory_and_context_ladder.md`](../agent_kb/memory_and_context_ladder.md) § File discovery layers | Canonical | Unnumbered layers; not a second ladder |
| File discovery layers | [`agent_kb/memory_and_context_ladder.md`](../agent_kb/memory_and_context_ladder.md) (old § Context Navigation Ladder) | Resolved | Renamed/de-numbered 2026-05-22 pass 2 |
| Cold-start bootstrap output | [`tool/agent_session_bootstrap.sh`](../../tool/agent_session_bootstrap.sh) | Canonical echo | `read_next` → [`context_loading.md`](../ai/context_loading.md); discovery pointer only (no 1–4 ladder) |
| Auto memory upkeep | [`tool/agent_memory_auto_maintain.sh`](../../tool/agent_memory_auto_maintain.sh) | Canonical | `--verify` after sync `--apply`; `--if-changed` from KB check (local only) |
| Workspace rule duplicates | [`tool/agent_asset_lib.sh`](../../tool/agent_asset_lib.sh) `check_workspace_managed_rule_duplicates` | Canonical | Fail drift when `.cursor/rules/` repeats files synced to `~/.cursor/rules/` |
| Review gate / checks table | [`ai_code_review_protocol.md`](../ai_code_review_protocol.md) | Canonical | Full checks + risk matrix + special cases |
| Finish gate / report shape | [`agent_kb/legibility_and_finish_gate.md`](../agent_kb/legibility_and_finish_gate.md) | Canonical | Legibility + Files Changed / Follow-up Actions |
| Finish gate | [`ai_code_review_protocol.md`](../ai_code_review_protocol.md) | Echo | Pointer only; no duplicate report-shape prose |

## WidgetTester.view note

- Root [`AGENTS.md`](../../AGENTS.md) and Codex template § Must Keep: feature-defined testing + [`docs/testing/widget_test_playbook.md`](../testing/widget_test_playbook.md) (aligned 2026-05-22).
- agents-global.mdc: explicitly **not** repo-wide `WidgetTester.view` until harness — intentional guardrail, not a conflict.
