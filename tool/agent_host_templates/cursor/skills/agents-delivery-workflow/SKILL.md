---
name: agents-delivery-workflow
description: Non-trivial delivery start-to-finish, validation routing, meta/subagent pointers, and completion gate before done/commit.
---

# Delivery workflow

## When to use

Non-trivial feature/fix, validation routing, completion before done/commit.

## Open (order)

1. `AGENTS.md` + `docs/agents_quick_reference.md` (§ Automatic Workflow Triggers)
2. `docs/ai/context_loading.md` — **context ladder**; `docs/agent_knowledge_base.md` — **File verified reusable conclusions**, `#multi-agent-hub`
3. `docs/ai_code_review_protocol.md`
4. `docs/engineering/validation_routing_fast_vs_full.md`

**Loop:** Plan → Execute → Verify → Report; **95% confident**; **Surgical diff**; **Report only after Verify**; **Self-verify final response**. Ladder → `docs/ai/context_loading.md`. Commands → `docs/agents_quick_reference.md`. **Multi-agent:** `Benefit: team` / `Benefit: single`; `tasks/cursor/team/<run-id>/`; `agent_knowledge_base.md#multi-agent-hub`. `DESIGN.md` + `docs/design_system.md`; `tasks/cursor/todo.md`. `./tool/check_agent_knowledge_base.sh` on doc changes.
