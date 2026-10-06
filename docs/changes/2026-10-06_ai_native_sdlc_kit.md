# AI-native SDLC kit (tool-agnostic)

**Date:** 2026-10-06  
**Scope:** Documentation + thin host rule template. No product behavior change.

## Summary

Translate industry AI-native SDLC ideas (intent → spec → plan → review;
agent instruction file; institutional skills; deterministic gates; feedback
loops) into **tool-agnostic** repo artifacts for coding agents. Hard-ban
Claude Code / Anthropic-only config.

## What changed

| Artifact | Change |
| --- | --- |
| [`AGENTS.md`](../../AGENTS.md) | Strengthened one-page map: prove-work commands, conventions, pitfalls, AI-SDLC link; still ≤50 lines / host-agnostic |
| [`docs/ai-sdlc/`](../ai-sdlc/README.md) | New kit: README concept map, templates, features folder convention, gates, skills |
| [`tool/agent_host_templates/cursor/rules/ai-native-sdlc.mdc`](../../tool/agent_host_templates/cursor/rules/ai-native-sdlc.mdc) | Project rule (globs; not always-on) pointing at the kit |
| Indexes | [`README.md`](../README.md), [`ai-workflow.md`](../ai-workflow.md), [`ai/README.md`](../ai/README.md), skill routing, context ladder, HITL map, interview showcase, quick reference |

## Industry → repo map (short)

| Idea | Landing |
| --- | --- |
| Vendor CLAUDE instruction file | [`AGENTS.md`](../../AGENTS.md) |
| Skills | `docs/ai-sdlc/skills/` (+ existing host skills) |
| Hooks | [`ai-sdlc/gates.md`](../ai-sdlc/gates.md) → scripts + required CI |
| Artifact chain | `docs/ai-sdlc/templates/` + `features/<slug>/` |
| Lifecycle gates | Existing AIDLC (unchanged schemas) |

## Skipped (hard ban)

- Vendor CLAUDE instruction file / `.claude/`
- Anthropic API review bots / Claude-only Actions
- Claude Code hook JSON as the gate system

## Proof

```bash
./tool/check_agent_knowledge_base.sh
bash tool/check_docs_gardening.sh --paths AGENTS.md docs/ai-sdlc docs/README.md
./bin/checklist-fast --no-reuse
./bin/agent-maintain after-host-edit   # sync new project rule
```
