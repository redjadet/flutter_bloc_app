# Agent instruction dedup matrix (2026-05-22)

Classify before edit. **Canonical** = single owner; others → pointer. **Echo** = minimal repeat for cold-start/CI anchors.

| Theme | File | Class | Action |
| --- | --- | --- | --- |
| Context ladder (numbered) | [`ai/context_loading.md`](../ai/context_loading.md) | Canonical | Keep only numbered ladder |
| Context ladder | [`agent_knowledge_base.md`](../agent_knowledge_base.md) § Progressive Disclosure | Echo | Keep one-line “then AKM → …”; no second numbered list |
| Context ladder | [`agents_quick_reference.md`](../agents_quick_reference.md) § Harness | Stale | Pointer to [`ai/context_loading.md`](../ai/context_loading.md) only |
| Context ladder | agents-quick-reference SKILL (host template) | Skill-echo | Point to context_loading.md, not AKM |
| Context ladder | agents-global.mdc (host template) | Skill-echo | One-line pointer; drop prose ladder |
| Context ladder | agents-delivery-workflow SKILL (host template) | Skill-echo | Pointer only |
| Context ladder | flutter-bloc-app Codex skills (host template) | Skill-echo | Pointer only |
| Validation chooser | [`agents_quick_reference.md`](../agents_quick_reference.md) § Validation Chooser | Canonical | Keep full table |
| Validation chooser | flutter-bloc-app-quick-reference SKILL (host template) | Stale | Remove inline picks; link § Validation Chooser |
| Validation chooser | agents-validation-testing SKILL (host template) | Echo | Keep repo-specific rows only |
| Loop / report proof | [`AGENTS.md`](../../AGENTS.md) § Loop | Canonical (short) | Keep |
| Loop / report proof | [`agents_quick_reference.md`](../agents_quick_reference.md) | Stale | Remove duplicate phrase from Harness |
| Loop / report proof | [`agent_knowledge_base.md`](../agent_knowledge_base.md) | Echo | Anchors only |
| Multi-agent hub | [`agent_kb/multi_agent_hub.md`](../agent_kb/multi_agent_hub.md) + AKM § Hub | Canonical | Keep anchors in AKM |
| Multi-agent hub | [`agents_quick_reference.md`](../agents_quick_reference.md) § Harness | Stale | Link `#multi-agent-hub` only (table keeps Benefit rows) |
| Key file paths | agents-references SKILL (host template) | Stale | Collapse to categories + CODEMAP / rg |
| Key file paths | [`agent_project_context.md`](../agent_project_context.md) | Canonical | Topic table stays |
| Widget tests | [`testing_overview.md`](../testing_overview.md) + playbook | Canonical | — |
| Widget tests | agents-global.mdc (host template) | Echo | Playbook pointer; no repo-wide WidgetTester.view until harness |
| Widget tests | codex AGENTS.md (host template) | Resolved | Matches root AGENTS.md — playbook pointer, no blanket WidgetTester.view |
| UI / Mix | [`DESIGN.md`](../../DESIGN.md), [`design_system.md`](../design_system.md) | Canonical | — |
| Codex map | [`AGENTS.md`](../../AGENTS.md) | Canonical | Root source |
| Codex map | codex AGENTS.md (host template) | Echo | Codex-only deltas only |

## WidgetTester.view note

- Root [`AGENTS.md`](../../AGENTS.md) and Codex template § Must Keep: feature-defined testing + [`docs/testing/widget_test_playbook.md`](../testing/widget_test_playbook.md) (aligned 2026-05-22).
- agents-global.mdc: explicitly **not** repo-wide `WidgetTester.view` until harness — intentional guardrail, not a conflict.
