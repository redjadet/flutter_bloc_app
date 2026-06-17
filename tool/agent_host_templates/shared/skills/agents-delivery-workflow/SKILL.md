---
name: agents-delivery-workflow
description: Shared Codex/Cursor delivery loop for non-trivial work, validation routing, tracker choice, and completion gate before done or commit.
---

# Delivery workflow

Use for non-trivial feature/fix, validation routing, completion before done/commit.

**Start:** `AGENTS.md` + **context ladder** (`docs/ai/context_loading.md`).

**Tracker:** Codex `tasks/codex/todo.md`; Cursor `tasks/cursor/todo.md`.

**Loop:** Plan -> Execute -> Verify -> Report; **95% confident**; **Surgical diff**; **Report only after Verify**; **Self-verify final response**.

Commands/routing: `docs/agents_quick_reference.md`. Doctrine/review/validation: `docs/agent_knowledge_base.md`, `docs/ai_code_review_protocol.md`, `docs/engineering/validation_routing_fast_vs_full.md`.

**File verified reusable conclusions** -> owning doc / `docs/changes/` / `tasks/lessons.md`.

**Cursor-only:** multi-agent hub anchors `Benefit: team` / `Benefit: single`; `tasks/cursor/team/<run-id>/`.
