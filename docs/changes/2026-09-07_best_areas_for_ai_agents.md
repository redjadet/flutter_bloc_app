# Best areas for AI agents guide

## Why

Repository documentation defined agent execution, tool routing, feature
delivery, debugging, testing, migration, and review procedures separately. It
lacked one discoverable English guide explaining which work areas benefit most
from AI agents and which decisions must remain human-owned.

## Change

- Added [`best_areas_for_ai_agents.md`](../ai/best_areas_for_ai_agents.md) covering
  ten requested work areas.
- Defined good-fit conditions, controls, expected outputs, and canonical owner
  links for every area.
- Kept product intent, architecture direction, security and business risk,
  production actions, and final approval under human ownership.
- Linked the guide from project, documentation, AI, operating-manual,
  tool-orchestration, and complementary human-skills entry points.

## Ownership

The new guide owns task-fit synthesis and navigation. Existing feature,
architecture, testing, debugging, security, migration, validation, and agent
documents continue to own their detailed procedures.

## Validation

```bash
bash tool/check_docs_gardening.sh --paths \
  AGENTS.md docs/README.md docs/ai/README.md \
  docs/ai/best_areas_for_ai_agents.md docs/ai/agent_operating_manual.md \
  docs/agent_kb/tool_orchestration.md \
  docs/engineering/critical_human_skills.md docs/changes/README.md \
  docs/changes/2026-09-07_best_areas_for_ai_agents.md
bash tool/check_agent_knowledge_base.sh
./bin/checklist-fast --no-reuse
./bin/agent-maintain closeout
```
