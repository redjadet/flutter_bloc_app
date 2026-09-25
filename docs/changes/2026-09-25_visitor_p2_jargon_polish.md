# Visitor P2 polish — jargon density

**Date:** 2026-09-25  
**Base:** `main` @ `512a09c2`  
**Companion:** [`2026-09-25_claim_ledger_sha_refresh.md`](2026-09-25_claim_ledger_sha_refresh.md)

## Intent

Reduce cold-visitor jargon on the short public path without renaming
`authority_*` files and without regressing README (badges / scorecard strings /
reference-first layout stay).

## Touched

| Doc | Change |
| --- | --- |
| [`ai/human_ai_collaboration.md`](../ai/human_ai_collaboration.md) | Visitor header; ledger → footnote; soften W12 / 10/10 / Phase wording |
| [`platforms/README.md`](../platforms/README.md) | “Skim: matrices only” for ≤15 min |
| [`architecture_tour.md`](../architecture_tour.md) | Offline invariants wording; skim pointer for platforms |
| [`README.md`](../README.md) (docs index) | One-line Outsider 15‑min path |
| [`interview_showcase.md`](../interview_showcase.md) | “claim ledger” instead of “Phase 0A ledger” |
| [`offline_first/README.md`](../offline_first/README.md) | “Named offline invariants” label |

## Non-goals

- No `authority_*` renames
- No README root first-impression restructuring

## Tests

`bash tool/check_docs_gardening.sh --paths …` on touched docs.
