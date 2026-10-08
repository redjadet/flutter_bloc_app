# Self-Improvement

Back: [Agent Knowledge Base](../agent_knowledge_base.md)

Persisted agent improvements require measurement. Put as much design effort
into **how the agent learns after each run** as into picking the model — using
this repo's existing gates and stores, not a parallel memory stack.

## Verifiability Gate

- Rule: **no verifier, no persistence**.
- Good verifiers: `dart analyze`, formatter, unit/widget/integration tests,
  repo validation scripts, reproducible error reproduction, CI check.
- Weak verifiers: model opinion, "looks cleaner", self-scoring, unproven
  claims.
- No automatic verifier: keep change ephemeral or mark **human review required**
  before persisting.

## Safe Stack

Default to these only:

- **Reflection:** critique/revise current output; store nothing unless repo
  evidence verifies it. Reflection is an **evidence-backed review pass**
  (finish gate, review protocol, validation lane) — not an LLM self-score
  threshold. One serious pass usually enough; high-stakes code may take a
  second host or human review.
- **Memory:** store only verified repo conventions, fixes, risks, and workflow
  rules with source/proof pointers. Purpose map:
  [`memory_and_context_ladder.md`](memory_and_context_ladder.md)
  § Memory by purpose.
- **Scaffold evolution:** improve prompts, templates, checklists, tool order,
  docs, or scripts only when reversible and tied to repo outcomes. Prefer a
  **skill / playbook** over a longer prompt when the workflow is proven
  ([`skill_routing.md`](../ai/skill_routing.md)).

Avoid by default inside this app repo:

- model fine-tuning
- self-generated training loops
- autonomous model replacement
- agent-population contests
- Redis / Postgres / vector-DB / knowledge-graph **product** memory for agents
  (map industry “memory by purpose” to session trackers, prefs, lessons,
  skills — see memory ladder)

Benchmark exception: population-style exploration only for narrow measurable
experiments with correctness, maintainability, regression checks, and human
review.

## After-run loop (map to owners)

Industry “planner → executor → evaluate → reflect → memory → skill” already
lives here; do not invent a second pipeline:

| Step | Repo owner |
| --- | --- |
| Plan | AIDLC / AI-SDLC intent→spec→plan; operating manual |
| Execute | Feature delivery + skill routing |
| Evaluate | Validation routing + pre-complete gate (format → analyze → tests) |
| Reflect | This page + finish-gate teach-back; review protocol when shipping |
| Memory | Memory ladder; [`tasks/lessons.md`](../../tasks/lessons.md); operator prefs; `docs/changes/` |
| Skill library | [`skill_routing.md`](../ai/skill_routing.md), `docs/ai-sdlc/skills/` |

**Learn from success too:** when a run is verified, promote a reusable
workflow into an owner doc or fat skill (triggers, write scope, tools, quality
bar). Do not only file failure lessons. **Learn from failure:** miss /
two-plus attempts → [`tasks/lessons.md`](../../tasks/lessons.md) +
`agents-regression-capture` when it was a bug fix.

## Persistence Questions

Answer in PR description or commit body before persisting process/doc/rule
changes:

1. What changed?
2. Why change?
3. How verified?
4. Expected benefit?
5. Rollback path?
6. Where is version history?
7. If verifier weak: who approved?
