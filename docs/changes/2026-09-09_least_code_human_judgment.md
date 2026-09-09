# Least-code human judgment guidance

## Why

Agent coding makes implementation volume cheap. Human guidance docs already
covered accountability and agent supervision, but under-emphasized restraint:
rejection of unnecessary architecture, carrying cost of every line, interrogation
of generated options, and deletion as engineering leverage.

## Change

- Extended
  [`engineering/critical_human_skills.md`](../engineering/critical_human_skills.md):
  scarcity framing; architecture “destroy boxes”; trade-off rejection; product
  reinvestment of saved hours; agent intent-first interrogation; new skill
  **Restraint, rejection, and deletion**; self-review asks for smallest surface.
- Aligned [`ai/best_areas_for_ai_agents.md`](../ai/best_areas_for_ai_agents.md)
  acceptance with least-surface review and link to human skills.
- Tightened judgment loop in
  [`ai/agent_operating_manual.md`](../ai/agent_operating_manual.md).
- Pointed onboarding and docs indexes at the updated human guide.

## Ownership

Human-skills synthesis remains the navigation owner. Deep architecture, review,
product, and governance rules stay in their existing owner docs.

## Validation

```bash
./bin/checklist-fast --no-reuse
bash tool/check_docs_gardening.sh --paths \
  docs/engineering/critical_human_skills.md \
  docs/engineering/README.md \
  docs/ai/best_areas_for_ai_agents.md \
  docs/ai/agent_operating_manual.md \
  docs/new_developer_guide.md \
  docs/README.md \
  docs/changes/2026-09-09_least_code_human_judgment.md \
  docs/changes/README.md
bash tool/check_agent_knowledge_base.sh
./bin/agent-maintain closeout
```
