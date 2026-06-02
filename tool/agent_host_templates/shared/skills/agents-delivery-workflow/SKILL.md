---
name: agents-delivery-workflow
description: Shared Codex/Cursor delivery loop for non-trivial work, validation routing, tracker choice, and completion gate before done or commit.
---

# Delivery workflow

Use for non-trivial feature/fix, validation routing, completion before done/commit.

**Start:** `AGENTS.md` + **context ladder** (`docs/ai/context_loading.md`). Delivery pointers: `docs/agents_quick_reference.md`, `docs/agent_knowledge_base.md`, `docs/ai_code_review_protocol.md`, `docs/engineering/validation_routing_fast_vs_full.md`.

**Tracker:** Codex `tasks/codex/todo.md`; Cursor `tasks/cursor/todo.md`.

**Loop:** Plan -> Execute -> Verify -> Report; **95% confident**; **Surgical diff**; **Report only after Verify**; **Self-verify final response**. Commands -> `docs/agents_quick_reference.md`. **File verified reusable conclusions** in AKM. UI -> `DESIGN.md` + `docs/design_system.md`; after app-code/UI edits, hot reload active controllable debug session (hot restart when needed). Agent-doc changes -> `./tool/check_agent_knowledge_base.sh`.

**Cursor-only:** Multi-agent -> `Benefit: team` / `Benefit: single`; `tasks/cursor/team/<run-id>/`; `agent_knowledge_base.md#multi-agent-hub`.

**Codex-only:** no `./tool/request_codex_feedback.sh` unless user asks.
