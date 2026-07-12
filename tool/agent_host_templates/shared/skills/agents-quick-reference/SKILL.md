---
name: agents-quick-reference
description: Fast repo orientation, command entrypoints, cross-host guardrails, and shared Codex/Cursor pointers. Repo canon wins.
---

# Quick reference

Repo canon wins. Pointers only.

**Start:** `AGENTS.md` + **Context ladder** (`docs/ai/context_loading.md`). Skill routing: `docs/ai/skill_routing.md` (`agents-skill-routing`). Tool route: `./bin/agent-maintain preflight --intent "<goal>"` or `tools --intent "<goal>" --paths <files>`. Commands: `docs/agents_quick_reference.md`. Doctrine/review: `docs/agent_knowledge_base.md`, `docs/ai_code_review_protocol.md`.

**UI/platform:** `DESIGN.md`, `docs/design_system.md`, `flutter-cross-platform-modern`.

**Validation:** `tool/check_agent_knowledge_base.sh`, `tool/check_design_md.sh`, `tool/run_mix_lint.sh`, `tool/check_agent_asset_drift.sh`, `tool/sync_agent_assets.sh --dry-run`.

**Do not duplicate:** **reusable agent conclusion** -> owning doc / `docs/changes/` / `tasks/lessons.md`. Trackers: Codex `tasks/codex/todo.md`; Cursor `tasks/cursor/todo.md`.

**Cursor-only:** `tasks/cursor/team/<run-id>/` (multi-agent hub, `agent_knowledge_base.md#multi-agent-hub`).
