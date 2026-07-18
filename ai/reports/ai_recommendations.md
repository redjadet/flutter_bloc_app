---
ai_snapshot:
  generated_at: "2026-07-18T08:57:20Z"
  git_head: "cd2c35ed609a8301079fea2efab8d70dbbcd9c8b"
  app_root: "apps/mobile"
  canon_links:
    - docs/architecture_details.md
    - CODEMAP.md
    - docs/feature_overview.md
---

# AI recommendations

Prioritized actions from discovery (2026-05-21). Each item links evidence; implementation needs Feature Brief per [`docs/plans/FEATURE_TEMPLATE.md`](../docs/plans/FEATURE_TEMPLATE.md) when touching code.

| ID | Priority | Recommendation | Evidence | Effort |
| --- | --- | --- | --- | --- |
| REC-001 | P0 | Document AI entry path in AGENTS Map ([PLAN.md](../../PLAN.md), [CODEMAP.md](../../CODEMAP.md), governance) | This plan Wave 2 | S |
| REC-002 | P0 | Keep [AGENTS.md](../../AGENTS.md) ≤120 lines; route roles to [`docs/ai/governance.md`](../../docs/ai/governance.md) | `check_agent_knowledge_base.sh` | S |
| REC-003 | P1 | ~~Decouple `case_study_demo` from `camera_gallery` / `supabase_auth` domain imports~~ **done** | ARCH-001, [FINAL_OPTIMIZATION_REPORT.md](FINAL_OPTIMIZATION_REPORT.md) | M |
| REC-004 | P1 | ~~Split `case_study_session_cubit_actions.part.dart` (385 LOC)~~ **done** | ARCH-002, [FINAL_OPTIMIZATION_REPORT.md](FINAL_OPTIMIZATION_REPORT.md) | M |
| REC-005 | P1 | ~~Add missing feature barrels~~ **done** (PR #239) | ARCH-003 | S |
| REC-006 | P2 | Pilot CONTEXT_MAP loads ≤8 files for `counter`, `chat`, `auth` | [CONTEXT_MAP.md](../CONTEXT_MAP.md) | S |
| REC-007 | P2 | Curate `docs/domain/domain_glossary.md` from language v1 report | [ai_domain_language_report_v1.md](../../docs/audits/ai_domain_language_report_v1.md) | M |
| REC-008 | P2 | Consolidate chat remote failure mappers | [anti_patterns.md](anti_patterns.md) AP-04, ARCH-008 | M |
| REC-009 | P3 | ~~Script or checklist to refresh `ai/reports` after feature adds~~ **done** | `tool/refresh_ai_reports.sh` | M |
| REC-010 | P3 | ~~Phase 5: mechanical Feature Brief guard~~ **done** | `tool/check_feature_brief_linked.sh` | L |

**Next audit refresh:** after first Phase 4 merge or quarterly.
