# Agent codegen / feedback-loop rules (explicit)

**Date:** 2026-10-14

**Scope:** Living agent docs and always-on execution reminder only. No app code.

## Why

External Flutter agent guidance stresses a tight write → analyze/test → repair
loop and calls out generated-file edits plus forgotten `build_runner` runs as
common friction. This repo already owned format/analyze/test/MCP/hot-reload and
platform-port isolation; the missing explicit rule was **never hand-edit**
`*.g.dart` / `*.freezed.dart` and regenerate after annotation changes.

## What changed

- [`engineering/code_generation_guide.md`](../engineering/code_generation_guide.md) — Agent rules (codegen)
- [`agents_quick_reference.md`](../agents_quick_reference.md) — Validation Chooser codegen row
- [`ai/agent_operating_manual.md`](../ai/agent_operating_manual.md) — AI behaviour row
- [`ai/best_areas_for_ai_agents.md`](../ai/best_areas_for_ai_agents.md) — name generated globs
- [`ai-sdlc/skills/platform-channel-safety.md`](../ai-sdlc/skills/platform-channel-safety.md) — human-review for
  Dart↔host signatures / threading / memory
- `tool/agent_host_templates/cursor/rules/agent-execution.mdc` — thin MCP +
  codegen bullets (sync via after-host-edit)

## Non-goals

- Riverpod workflow (this app uses Cubit/BLoC + Freezed)
- New failure-risk register ID
- Mass rewrite of feedback-loop docs already covered by the finish gate
