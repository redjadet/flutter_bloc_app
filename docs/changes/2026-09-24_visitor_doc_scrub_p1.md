# Visitor doc scrub — Portfolio path + Authority Thesis labels (P1)

**Date:** 2026-09-24  
**Branch:** `cursor/visitor-doc-scrub-d7ce`  
**Base:** `origin/main` @ `6efdf38f` (#907 merged)  
**Worktree:** `/Volumes/Lacie_Ssd/projects/bloc_test_app/flutter_bloc_app-visitor-doc-scrub`

## Intent

After [#907](https://github.com/redjadet/flutter_bloc_app/pull/907), align the
README **Portfolio reading path** with the four-pillar cold-visitor route and
scrub leftover visitor-facing “Authority Thesis” / “authority” **labels**.
Filenames `authority_*` stay (rename deferred). Normative HITL / offline /
safety meaning unchanged — labels only.

## Write set

| File | Change |
| --- | --- |
| [`README.md`](../../README.md) | Portfolio path → HITL → platforms → architecture_tour; interview/system-design optional |
| [`ai/human_ai_collaboration.md`](../ai/human_ai_collaboration.md) | “README Authority Thesis” → README Four pillars |
| [`platforms/README.md`](../platforms/README.md) | “Authority Thesis #3” → “Four pillars #3” |
| [`architecture_tour.md`](../architecture_tour.md) | Minute 0–1 “Thesis” / “README thesis” → Four pillars + `#four-pillars` |
| [`interview_showcase.md`](../interview_showcase.md) | “authority pillars” → “pillars” |
| [`README.md`](../README.md) | “Authority scope / Archive” → “Scope / Archive” |
| [`feature_overview.md`](../feature_overview.md) | “Authority tiers” → “Feature tiers”; link label → Scope register |
| [`offline_first/README.md`](../offline_first/README.md) | Drop “(authority)” from W3 invariants row label |
| [`llms.txt`](../../llms.txt) | “Authority scope:” → “Scope register:” (hand-maintained companion to CODEMAP) |
| This note | Evidence |

Codex plan review used a **local** plan under gitignored `docs/plans/` (not
committed; see `.gitignore` `docs/plans/*`).

## Non-goals

- No rename of `authority_*` files
- No app/code/CI/security/DI/offline semantics changes
- No merge to main without explicit user “merge to main”

## Validation

- Relative links on edited surface: pass
- `bash tool/check_docs_gardening.sh --paths …`: pass
- `git diff --check`: pass
- Forbidden visitor-label scan (README any “authority”; visitor docs for
  Authority Thesis / authority pillars / Authority tiers / Authority scope): pass
- Codex: `./tool/run_codex_plan_review.sh` on local gitignored plan
  (GPT-5.6 Sol fallback after GPT-6 Sol unavailable)
