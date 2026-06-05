---
name: agents-quick-reference
description: Fast repo orientation, command entrypoints, cross-host guardrails, and shared Codex/Cursor pointers. Repo canon wins.
---

# Quick reference

Repo canon wins. Orientation / validation / host wrappers.

**Start:** `AGENTS.md` + **Context ladder** (`docs/ai/context_loading.md`). **Skills:** `agents-skill-routing` / `docs/ai/skill_routing.md` (invoke before implementation). Canon pointers: `docs/agent_knowledge_base.md`, `docs/agent_project_context.md`, `docs/agents_quick_reference.md`, `docs/ai_code_review_protocol.md`. Non-trivial: `agents-delivery-workflow`. Cursor delegation: `agents-meta-behavior`. Cross-platform Flutter/Web/Desktop/Mobile: `flutter-cross-platform-modern`.

**Do not duplicate:** commands -> quick ref section Validation Chooser; **reusable agent conclusion** -> owning doc / `docs/changes/` / `tasks/lessons.md`. Tracker: Codex `tasks/codex/todo.md`; Cursor `tasks/cursor/todo.md`. UI -> `DESIGN.md` + `docs/design_system.md`; app-code/UI edits -> hot reload active controllable debug session.

**Cursor-only:** multi-agent hub -> `agent_knowledge_base.md#multi-agent-hub`; `tasks/cursor/team/<run-id>/`.

**Codex-only:** `./tool/request_codex_feedback.sh` only when user asks; Codex must not self-invoke.

Checks: `./tool/check_agent_knowledge_base.sh`, `./tool/check_design_md.sh`, `./tool/run_mix_lint.sh`, `./tool/check_agent_asset_drift.sh`, `./tool/sync_agent_assets.sh --dry-run`.
