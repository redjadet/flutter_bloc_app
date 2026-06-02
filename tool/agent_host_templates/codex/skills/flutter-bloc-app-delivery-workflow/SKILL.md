---
name: flutter-bloc-app-delivery-workflow
description: Codex delivery loop; tracker path and validation picks are Codex-specific.
---

# Delivery (Codex)

**Open:** `AGENTS.md`, `docs/agents_quick_reference.md`, `docs/agent_knowledge_base.md`, `docs/ai_code_review_protocol.md`, `docs/engineering/validation_routing_fast_vs_full.md`, `tasks/codex/todo.md`.

**Loop:** Plan → Execute → Verify → Report; **95% confident**; **Surgical diff**; **Report only after Verify**; **Self-verify final response**. **context ladder** → `docs/ai/context_loading.md`. **File verified reusable conclusions** in AKM. UI: `DESIGN.md` + `docs/design_system.md`; after app-code/UI edits, hot reload active controllable debug session (hot restart when needed). `./tool/check_agent_knowledge_base.sh` when agent docs change. No `./tool/request_codex_feedback.sh` unless user asks.
