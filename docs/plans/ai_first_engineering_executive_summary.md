# AI-first engineering — executive summary

**Date:** 2026-05-21  
**Status:** Waves 1–2 + Phase 4 (ARCH-003) + Phase 5 doc baseline on [PR #239](https://github.com/redjadet/flutter_bloc_app/pull/239) (open). **Merge deferred** to operator.

## Outcome

Established an **AI operability layer** (`/ai`, `CODEMAP.md`, `PLAN.md`) that routes agents to existing `docs/` canon without duplicating behavior rules or changing application code.

## Baseline metrics (preflight)

| Metric | Value |
| --- | ---: |
| Feature modules | 31 |
| Largest feature LOC | chat (6384) |
| Cross-feature import edges | 11 (sample) |
| Shared package fan-in | ~497 files |
| Domain/router/DI violations | 0 |
| Feature map coverage | 16 full + 15 stub |
| Ranked architecture issues | 11 (`ARCH-###`) |
| Prioritized recommendations | 10 (`REC-###`) |

## Delivered artifacts

- **Routing:** `CODEMAP.md`, `PLAN.md`, `ai/README.md`, `ai/CONTEXT_MAP.md`
- **Evidence:** `ai/reports/*` (architecture, dependencies, anti-patterns, data flows, feature map, hotspots, recommendations)
- **Audits:** `docs/audits/ai_architecture_audit.md`, `docs/audits/ai_domain_language_report_v1.md` (force-tracked)
- **Workflow (Wave 2):** Feature template, glossary, testing strategy router, contracts pilots, `docs/ai/governance.md`

## Phases

| Phase | Focus | Status |
| --- | --- | --- |
| 1 | Stabilisation — legible architecture for agents | In progress (docs) |
| 2 | Workflow — alignment, contracts, TDD router | Wave 2 docs |
| 3 | Velocity — CONTEXT_MAP ≤8 files per pilot | Pilot maps written |
| 4 | Scalability — ARCH-driven code refactors | ARCH-003 complete (4 barrels); ARCH-001/002 backlog |
| 5 | Continuous — refresh + mechanical gates | Doc baseline only (honor system; no CI script) |

## Top risks

1. **Stale reports** if metrics are not refreshed after large features.
2. **Cross-feature coupling** (`case_study_demo` → `camera_gallery` / `supabase_auth`).
3. **Large part files** driving agent context cost (385 LOC cubit actions).

## Next actions

1. Merge doc PR; run `git add -f docs/audits/ai_*.md` on commit.
2. Wave 2: enforce Feature Brief honor system + 5 contract pilots.
3. Phase 4: ARCH-001 / ARCH-002 with RED tests only.

**Full plan:** [`2026-05-21_ai_first_engineering_plan.md`](2026-05-21_ai_first_engineering_plan.md)
