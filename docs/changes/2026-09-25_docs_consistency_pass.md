# Docs consistency pass (high-traffic)

**Date:** 2026-09-25  
**Base:** `d009f5a0`

## Intent

Fix inconsistencies and rot across frequently used docs (not only recently
touched files): stale phase wording, index/onboarding bloat, tracker-link
honesty, and one optional local-symlink markdown link.

## Changes

| Area | Change |
| --- | --- |
| [`scope_register.md`](../scope_register.md) | Phase 4 heading → **shipped** |
| [`README.md`](../README.md) | Replace long Core-docs catalog with thin highlights + folder READMEs |
| [`new_developer_guide.md`](../new_developer_guide.md) | Compress §§3–6 to pointers (architecture / feature / validation / testing owners) |
| Agent tracker docs | Mark `tasks/*/todo.md` as local/gitignored; link tracker template (skip `agents_quick_reference.md` — that path triggers host asset-drift on CI) |
| [`design_system.md`](../design_system.md) | Dedupe DESIGN.md CLI block; shorten Mix examples |
| [`ai/gstack_integration.md`](../ai/gstack_integration.md) | Drop broken markdown link to optional host symlink |

## Non-goals

- Rewriting historical `docs/changes/*` (except this note)
- Renaming files again
- Removing harness-required [`tasks/cursor/todo.md`](../../tasks/cursor/todo.md) path strings
- README badge / “Do not conflate” edits

## Validation

```bash
bash tool/check_docs_gardening.sh
./tool/check_agent_knowledge_base.sh
./bin/checklist-fast
```
