# Self-Improvement

Back: [Agent Knowledge Base](../agent_knowledge_base.md)

Persisted agent improvements require measurement.

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
  evidence verifies it.
- **Memory:** store only verified repo conventions, fixes, risks, and workflow
  rules with source/proof pointers.
- **Scaffold evolution:** improve prompts, templates, checklists, tool order,
  docs, or scripts only when reversible and tied to repo outcomes.

Avoid by default inside this app repo:

- model fine-tuning
- self-generated training loops
- autonomous model replacement
- agent-population contests

Benchmark exception: population-style exploration only for narrow measurable
experiments with correctness, maintainability, regression checks, and human
review.

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
