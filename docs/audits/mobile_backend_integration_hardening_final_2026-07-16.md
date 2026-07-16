# Mobile–Backend Integration Hardening — Final Audit (2026-07-16)

**Scope:** Post-remediation evidence for Tasks 2–7 of the mobile/backend integration hardening program.
**Baseline:** [`mobile_backend_integration_hardening_baseline_2026-07-16.md`](mobile_backend_integration_hardening_baseline_2026-07-16.md) @ `ebfc0c54` (score **3.0 / 5**).
**Head:** branch `codex/mobile-backend-integration-hardening` (includes deferred-work owner doc `4d59eb31` + audit pin).
**Out of scope (unchanged):** Live backend calls, pagination implementation, product analytics events, domain/route/UI rewrites, new dependencies. See [`backend/MOBILE_BACKEND_DEFERRED_WORK.md`](../backend/MOBILE_BACKEND_DEFERRED_WORK.md).

## Executive summary

| Area | Verdict |
| --- | --- |
| Contract safety | **Fixed** — AI Decision + GraphQL country DTOs throw `FormatException`; GraphQL maps to `GraphqlDemoErrorType.data` |
| Transport / auth | **Fixed** — three `?? Dio()` fallbacks removed; CI guard enforces allowlisted factories |
| Documentation | **Fixed** — API contract guide, six-boundary doc, PR networking checklist + hub links |
| Sync / pagination | **Unchanged (doc contract)** — pagination still future-only |
| Observability | **Unchanged (doc-only analytics)** — ADR-0005 posture preserved |
| Testing | **Improved** — focused DTO/client/repository + regression pack green |
| Architecture | **Strong** — Clean Architecture imports pass; Dio lifetime still composition-owned |

**Overall weighted score: 4.35 / 5** (was 3.0).

## Scores (after remediation)

| Category | Weight | Before | After | Notes |
| --- | ---: | ---: | ---: | --- |
| Architecture seams | 15% | 4 | **4** | Unchanged; still strong |
| Transport / auth | 20% | 3 | **5** | No production `?? Dio()`; guard in checklist |
| Contract safety | 25% | 2 | **5** | Controlled failures; cast leaks closed on targeted DTOs |
| Sync / pagination | 10% | 4 | **4** | Pagination documented in API guide |
| Observability | 10% | 4 | **4** | Explicit deferral linked from contract/observability |
| Testing | 10% | 3 | **4** | FormatException + data-failure coverage; regressions green |
| Documentation | 10% | 2 | **5** | Three canonical docs + hub links |
| **Overall** | **100%** | **3.0** | **4.35** | Weighted: 0.60 + 1.00 + 1.25 + 0.40 + 0.40 + 0.40 + 0.50 |

## Remediation status

| Task | Item | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Baseline audit | Done | This program's baseline doc |
| 2 | AI Decision defensive JSON | Done | `ai_decision_json.dart`, DTO/client tests |
| 3 | GraphQL DTO + data mapping | Done | `graphql_json.dart`, repository data-failure test |
| 4 | Required Dio injection | Done | RestCounter / CountriesGraphql / HuggingFaceApiClient |
| 5 | Ad-hoc Dio CI guard | Done | `tool/check_adhoc_dio_construction.sh` in checklist |
| 6 | Canonical docs | Done | API guide, boundaries, PR checklist |
| 7 | Regression pack | Done | 127 focused tests + analyze + guards |
| 8 | Final audit + checklist | This doc | `./bin/checklist` evidence below |

## Residual risks

- No live-backend validation — unit/fixture proof only.
- Domain wire-leak warn-only list still 45 pre-existing hits.
- Pagination / product analytics remain documentation contracts until a product feature requires implementation — owner list: [`backend/MOBILE_BACKEND_DEFERRED_WORK.md`](../backend/MOBILE_BACKEND_DEFERRED_WORK.md).
- Broad demo DTOs outside AI Decision + GraphQL country scope still use direct casts (explicitly out of scope).

## Tech debt (tracked)

- Analyze fatal-infos on Dio injection constructors cleared in `c910bc5b` (prefer initializing formals / avoid types on closure parameters).
- Consider gitignore exception for `*_baseline_*.md` audits (baseline required `git add -f`).
- Deferred owner list (pagination, analytics, live-backend proof, broad DTO rewrite, domain-wire backlog): [`backend/MOBILE_BACKEND_DEFERRED_WORK.md`](../backend/MOBILE_BACKEND_DEFERRED_WORK.md).

## Modified files (program)

- `apps/mobile/lib/features/ai_decision_demo/data/ai_decision_json.dart` (new)
- `apps/mobile/lib/features/ai_decision_demo/data/ai_decision_dto.dart`
- `apps/mobile/lib/features/ai_decision_demo/data/ai_decision_api_client.dart`
- `apps/mobile/lib/features/graphql_demo/data/graphql_json.dart` (new)
- `apps/mobile/lib/features/graphql_demo/data/graphql_country_dto.dart`
- `apps/mobile/lib/features/graphql_demo/data/countries_graphql_repository.dart`
- `apps/mobile/lib/features/graphql_demo/data/countries_graphql_repository_queries.part.dart`
- `apps/mobile/lib/features/counter/data/rest_counter_repository.dart`
- `apps/mobile/lib/features/chat/data/huggingface_api_client.dart`
- `apps/mobile/lib/features/chat/data/huggingface_chat_repository.dart`
- Matching tests under `apps/mobile/test/...`
- `tool/check_adhoc_dio_construction.sh` + fixtures + `tool/delivery_checklist.sh`
- `docs/backend/API_CONTRACT_GUIDE.md`, `docs/architecture/MOBILE_BACKEND_BOUNDARIES.md`, `docs/contributing/PR_REVIEW_CHECKLIST.md`
- `docs/backend/MOBILE_BACKEND_DEFERRED_WORK.md` (not-done owner list)
- Hub link updates + validation_scripts catalog/overview/checklist_index
- Baseline + final audits + change note

## Evidence table (commands)

| Check | Command | Result (2026-07-16) |
| --- | --- | --- |
| Ad-hoc Dio | `bash tool/check_adhoc_dio_construction.sh` | `✅ ok|adhoc-dio|violations=0` |
| Clean Architecture | `bash tool/check_clean_architecture_imports.sh` | Pass |
| Domain wire leaks | `bash tool/check_domain_wire_leaks.sh` | Warn-only, 45 (pre-existing) |
| Focused regressions | `flutter test` AI Decision/GraphQL/counter/HF + `test/shared/http/` | **127 passed** |
| Analyze | `bash tool/analyze.sh` | Pass (infos only) |
| Full delivery | `./bin/checklist` | **Passed** (2026-07-16, head includes analyze lint fix `c910bc5b`) |

## No-live-backend limitation

All contract proof is offline (unit tests + fixtures). No Render/Hugging Face/AI Decision live calls were made in this program.
