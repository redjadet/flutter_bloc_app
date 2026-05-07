---
name: verification-before-completion
description: Auto-use before “done”; require proof before claiming done.
---

# Verification before completion

Use when about to claim “done”, “fixed”, “passes”, “ready”.

Triggers (examples):

- “done”, “fixed”, “resolved”, “ready to ship”, “passes now”
- “I think it works”, “should be good”

Canon first:

- `AGENTS.md`
- `docs/agent_knowledge_base.md`
- `docs/ai_code_review_protocol.md`

Hard gates:

- Evidence before assertions.
- Run smallest matching validation (fast vs full).

Checklist:

- Re-read request; ensure diff matches ask.
- Run relevant repo script(s) (prefer `./bin/checklist-fast` when applicable).
- Check lints for edited files; fix introduced errors.
- Summarize proof: commands run + results + residual risk.
