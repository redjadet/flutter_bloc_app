# Clean code in the AI era (guidance)

**Date:** 2026-09-16  
**Type:** docs / agent guidance

## Summary

Fold AI-era rationale for readable, focused code into existing owners—no new
“clean code” program. Agents must read code before changing it; small focused
units, explicit names, **why** comments, and dead-code removal cut context cost,
change risk, and incident recovery time. Humans remain accountable in outages;
team-specific knowledge stays in structure and comments, not chat.

## Owners updated

- [`docs/CODE_QUALITY.md`](../CODE_QUALITY.md) — § Clean code in the AI era
- [`docs/ai/agent_operating_manual.md`](../ai/agent_operating_manual.md) — § Readable code and useful comments
- [`docs/agent_knowledge_base.md`](../agent_knowledge_base.md) — Core Belief + trap
- [`docs/ai/context_loading.md`](../ai/context_loading.md) — read before edit
- [`docs/ai_code_review_protocol.md`](../ai_code_review_protocol.md) — risk + review note
- [`docs/review/code_review_playbook.md`](../review/code_review_playbook.md) — readability with tests
- [`docs/engineering/critical_human_skills.md`](../engineering/critical_human_skills.md) — review skill

## Related

- File-length gate: [`2026-06-08_file_length_lint_qg-d02.md`](2026-06-08_file_length_lint_qg-d02.md)
- Prior judgment guidance: [`2026-09-11_senior_engineering_judgment_guidance.md`](2026-09-11_senior_engineering_judgment_guidance.md)
