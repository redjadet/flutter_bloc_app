# Mobile–Backend Integration Hardening — Baseline Audit (2026-07-16)

**Scope:** Contract-safety and transport-injection gaps on existing mobile/backend seams before Tasks 2–8 remediation.
**Baseline commit:** `ebfc0c54` on branch `codex/mobile-backend-integration-hardening`.
**Program:** [`tasks/codex/mobile_backend_integration_hardening_plan.md`](../../tasks/codex/mobile_backend_integration_hardening_plan.md).
**Out of scope:** Pagination implementation, product analytics wiring, live backend calls, domain/route/UI changes, new dependencies.

## Executive summary

| Area | Verdict |
| --- | --- |
| Architecture seams | **Strong baseline** — Clean Architecture import guard passes; composition injects shared `Dio` for GraphQL + Hugging Face |
| Transport / auth | **Mixed** — `createAppDio` / refresh / retry / pinning stack exists; three production constructors still allow implicit `Dio()` |
| Contract safety | **Gap** — AI Decision + GraphQL DTOs use brittle `as` casts; tests currently **expect** `TypeError` on malformed JSON |
| Sync / pagination | **Acceptable for scope** — offline-first merge patterns present; pagination not implemented (documented deferral) |
| Observability | **Aligned to ADR-0005** — error coding in place; product analytics explicitly doc-only |
| Testing | **Partial signal** — DTO/client tests green but encode cast-leak behavior, not controlled `FormatException` |
| Documentation | **Fragmented** — reliability/offline/auth/observability/DTO guidance exists; canonical contract + boundary + PR checklist missing |

**Overall weighted score: 3.0 / 5** — solid transport/composition foundation; contract parsing and doc consolidation are the primary remediation targets.

## Scores (baseline — pre-remediation)

Subjective 1–5 per program rubric; overall = weighted average. Task 8 will record post-remediation delta.

| Category | Weight | Score | Notes |
| --- | ---: | ---: | --- |
| Architecture seams | 15% | **4** | Data owns wire; composition owns `Dio` lifetime for production GraphQL/HF; domain-wire warn-only (45 pre-existing hits) |
| Transport / auth | 20% | **3** | Shared stack strong; three `?? Dio()` fallbacks in production data constructors |
| Contract safety | 25% | **2** | 30+ brittle cast sites in AI Decision + GraphQL DTOs/client; `TypeError` leaks to callers |
| Sync / pagination | 10% | **4** | Offline merge / idempotency patterns OK; pagination deferred to API guide (Tasks 6–7) |
| Observability | 10% | **4** | Errors coded; ADR-0005 doc-only analytics posture explicit |
| Testing | 10% | **3** | Focused DTO tests exist; malformed-payload tests assert `TypeError`, not controlled failures |
| Documentation | 10% | **2** | No `API_CONTRACT_GUIDE`, `MOBILE_BACKEND_BOUNDARIES`, or PR networking checklist yet |
| **Overall** | **100%** | **3.0** | Weighted: 0.60 + 0.60 + 0.50 + 0.40 + 0.40 + 0.30 + 0.20 |

## Baseline findings (evidence lock)

| Finding | Evidence |
| --- | --- |
| Shared Dio, token refresh single-flight, retry, offline merge, pinning already strong | [`apps/mobile/lib/app/http/app_dio.dart`](../../apps/mobile/lib/app/http/app_dio.dart), `networking` package, offline-first repositories, existing transport tests |
| AI Decision / GraphQL DTOs use brittle `as` casts; tests currently **expect** `TypeError` | [`ai_decision_dto.dart`](../../apps/mobile/lib/features/ai_decision_demo/data/ai_decision_dto.dart), [`graphql_country_dto.dart`](../../apps/mobile/lib/features/graphql_demo/data/graphql_country_dto.dart), [`ai_decision_dto_test.dart`](../../apps/mobile/test/features/ai_decision_demo/data/ai_decision_dto_test.dart), [`graphql_country_dto_test.dart`](../../apps/mobile/test/features/graphql_demo/data/graphql_country_dto_test.dart) |
| AI Decision API client already injects `Dio`; list mapping still uses `.cast<_JsonMap>()` | [`ai_decision_api_client.dart`](../../apps/mobile/lib/features/ai_decision_demo/data/ai_decision_api_client.dart):41 |
| Implicit `Dio()` fallbacks remain | `RestCounterRepository`, `CountriesGraphqlRepository`, `HuggingFaceApiClient` (see evidence commands) |
| Production composition injects shared Dio for GraphQL + HF | [`register_graphql_services.dart`](../../apps/mobile/lib/app/composition/features/register_graphql_services.dart):33, [`register_chat_services.dart`](../../apps/mobile/lib/app/composition/features/register_chat_services.dart):62–64 |
| No pagination / product-analytics implementation | [`docs/adr/0005-interview-showcase-scope.md`](../adr/0005-interview-showcase-scope.md), [`docs/plans/future_observability.md`](../plans/future_observability.md) |
| Guidance split across reliability / offline / auth / observability / DTO / review | Missing `docs/backend/API_CONTRACT_GUIDE.md`, `docs/architecture/MOBILE_BACKEND_BOUNDARIES.md`, `docs/contributing/PR_REVIEW_CHECKLIST.md` (Tasks 6–7) |

## Risks

| ID | Risk | Severity | Likelihood |
| --- | --- | --- | --- |
| R1 | Malformed API payloads surface raw `TypeError` to cubits/UI instead of mapped load failures | High | Medium (demo backends + evolving schemas) |
| R2 | Implicit `Dio()` bypasses refresh, retry, pinning when repositories constructed outside composition | Medium | Low in production (composition injects); higher in tests/examples |
| R3 | `.cast<_JsonMap>()` on AI Decision list responses throws before repository can map to domain failure | Medium | Medium |
| R4 | Fragmented contract docs → inconsistent PR review of networking/DTO changes | Medium | High without Tasks 6–7 deliverables |
| R5 | Domain wire-leak warnings (45) mask new leaks in future diffs | Low | Medium (warn-only gate) |

## Planned remediations (Tasks 2–8 — none applied at baseline)

| Task | Remediation |
| --- | --- |
| 2 | AI Decision defensive JSON helpers + `FormatException`; update DTO/client tests |
| 3 | GraphQL country DTO hardening + repository maps `FormatException` → data failure |
| 4 | Remove `?? Dio()` from three data constructors; tests pass explicit `Dio()` |
| 5 | CI guard `tool/check_adhoc_dio_construction.sh` + fixtures |
| 6–7 | Publish `API_CONTRACT_GUIDE`, `MOBILE_BACKEND_BOUNDARIES`, PR checklist; hub link-only updates |
| 8 | Final audit with score delta and `./bin/checklist` evidence |

## Residual risks (expected post-program)

- No live-backend validation in CI; contract hardening verified by unit tests and fixtures only.
- Domain wire-leak warn-only list unchanged by this program (pre-existing freezed/json in domain).
- Pagination and product analytics remain documentation contracts until a product feature requires implementation.

## Tech debt (tracked, not in this pass)

- Broad demo DTOs outside AI Decision + GraphQL country scope still use direct casts.
- `RestCounterRepository` remains example/spine code (fallback removal only).
- 45 domain `Map<String, dynamic>` / `fromJson` warn-only hits across chat, counter, case study, etc.

## Evidence table (commands)

Captured 2026-07-16 on worktree @ `ebfc0c54`.

### Implicit `Dio()` fallbacks

**Command:**

```bash
rg -n "client \?\? Dio\(\)|dio \?\? Dio\(\)" apps/mobile/lib --glob '*.dart'
```

**Result:**

```
apps/mobile/lib/features/chat/data/huggingface_api_client.dart:19:  }) : _dio = dio ?? Dio(),
apps/mobile/lib/features/counter/data/rest_counter_repository.dart:38:       _client = client ?? Dio(),
apps/mobile/lib/features/graphql_demo/data/countries_graphql_repository.dart:26:    : this._fromClient(client ?? Dio());
```

### Brittle casts (AI Decision + GraphQL)

**Command:**

```bash
rg -n " as String| as num| as Map<|\.cast<" \
  apps/mobile/lib/features/ai_decision_demo/data \
  apps/mobile/lib/features/graphql_demo/data/graphql_country_dto.dart
```

**Result:**

```
apps/mobile/lib/features/graphql_demo/data/graphql_country_dto.dart:8:        code: json['code'] as String,
apps/mobile/lib/features/graphql_demo/data/graphql_country_dto.dart:9:        name: json['name'] as String,
apps/mobile/lib/features/graphql_demo/data/graphql_country_dto.dart:30:        code: json['code'] as String,
apps/mobile/lib/features/graphql_demo/data/graphql_country_dto.dart:31:        name: json['name'] as String,
apps/mobile/lib/features/graphql_demo/data/graphql_country_dto.dart:33:          json['continent'] as Map<String, dynamic>,
apps/mobile/lib/features/graphql_demo/data/graphql_country_dto.dart:35:        capital: json['capital'] as String?,
apps/mobile/lib/features/graphql_demo/data/graphql_country_dto.dart:36:        currency: json['currency'] as String?,
apps/mobile/lib/features/graphql_demo/data/graphql_country_dto.dart:37:        emoji: json['emoji'] as String?,
apps/mobile/lib/features/ai_decision_demo/data/ai_decision_dto.dart:19:        id: json['id'] as String,
apps/mobile/lib/features/ai_decision_demo/data/ai_decision_dto.dart:20:        applicantName: json['applicant_name'] as String,
apps/mobile/lib/features/ai_decision_demo/data/ai_decision_dto.dart:21:        businessName: json['business_name'] as String,
apps/mobile/lib/features/ai_decision_demo/data/ai_decision_dto.dart:22:        amount: (json['amount'] as num).toDouble(),
apps/mobile/lib/features/ai_decision_demo/data/ai_decision_dto.dart:23:        status: json['status'] as String,
apps/mobile/lib/features/ai_decision_demo/data/ai_decision_dto.dart:24:        lastDecisionBand: json['last_decision_band'] as String?,
apps/mobile/lib/features/ai_decision_demo/data/ai_decision_dto.dart:56:    riskScore: (json['risk_score'] as num).toDouble(),
apps/mobile/lib/features/ai_decision_demo/data/ai_decision_dto.dart:57:    riskBand: json['risk_band'] as String,
apps/mobile/lib/features/ai_decision_demo/data/ai_decision_dto.dart:58:    recommendedAction: json['recommended_action'] as String,
apps/mobile/lib/features/ai_decision_demo/data/ai_decision_dto.dart:59:    rationale: json['rationale'] as String,
apps/mobile/lib/features/ai_decision_demo/data/ai_decision_dto.dart:60:    proof: json['proof'] as Map<String, dynamic>? ?? const <String, dynamic>{},
apps/mobile/lib/features/ai_decision_demo/data/ai_decision_dto.dart:92:    final caseJson = json['case'] as Map<String, dynamic>;
apps/mobile/lib/features/ai_decision_demo/data/ai_decision_dto.dart:94:      caseId: caseJson['id'] as String,
apps/mobile/lib/features/ai_decision_demo/data/ai_decision_dto.dart:95:      status: caseJson['status'] as String,
apps/mobile/lib/features/ai_decision_demo/data/ai_decision_dto.dart:96:      createdAt: caseJson['created_at'] as String,
apps/mobile/lib/features/ai_decision_demo/data/ai_decision_dto.dart:98:          json['applicant'] as Map<String, dynamic>? ??
apps/mobile/lib/features/ai_decision_demo/data/ai_decision_dto.dart:101:          json['business'] as Map<String, dynamic>? ??
apps/mobile/lib/features/ai_decision_demo/data/ai_decision_dto.dart:103:      loan: json['loan'] as Map<String, dynamic>? ?? const <String, dynamic>{},
apps/mobile/lib/features/ai_decision_demo/data/ai_decision_dto.dart:105:          .map((final e) => e as Map<String, dynamic>)
apps/mobile/lib/features/ai_decision_demo/data/ai_decision_dto.dart:108:          .map((final e) => e as Map<String, dynamic>)
apps/mobile/lib/features/ai_decision_demo/data/ai_decision_dto.dart:113:              json['latest_decision'] as Map<String, dynamic>,
apps/mobile/lib/features/ai_decision_demo/data/ai_decision_dto_mappers.dart:73:        json['input_snapshot'] as Map<String, dynamic>? ??
apps/mobile/lib/features/ai_decision_demo/data/ai_decision_api_client.dart:41:            .cast<_JsonMap>();
```

### Architecture guards

**Command:** `bash tool/check_clean_architecture_imports.sh`

**Result:**

```
🔍 Checking Clean Architecture import boundaries...
✅ Clean Architecture imports are valid
```

**Command:** `bash tool/check_domain_wire_leaks.sh`

**Result:** Warn-only — **45** domain wire-leak hits (freezed/json in domain across chat, counter, case study, chart, igaming, iot, search, todo, staff demo). Exit code 0. Representative lines include `counter_snapshot.freezed.dart`, `chat_conversation.dart`, `case_study_record.dart`. Full output archived in command run; not a regression introduced by this program.

## Composition evidence (production Dio injection)

| Service | Registration | Injected client |
| --- | --- | --- |
| GraphQL countries | `register_graphql_services.dart:33` | `CountriesGraphqlRepository(client: getIt<Dio>())` |
| Hugging Face chat | `register_chat_services.dart:62–64` | `HuggingFaceApiClient(dio: getIt<Dio>(), …)` |

Approved factories per program constraints: `createAppDio` ([`app_dio.dart`](../../apps/mobile/lib/app/http/app_dio.dart)), `createRenderChatDio` ([`render_chat_dio_factory.dart`](../../apps/mobile/lib/features/chat/data/render_chat_dio_factory.dart)).

## Test signal (malformed payload expectations)

| Test file | Current assertion on bad JSON |
| --- | --- |
| `ai_decision_dto_test.dart` | `throwsA(isA<TypeError>())` (lines 30, 43) |
| `graphql_country_dto_test.dart` | `throwsA(isA<TypeError>())` (lines 30, 41) |

## Out of scope (explicit)

| Item | Why deferred |
| --- | --- |
| Offset/cursor pagination | No product list needing it; contract in API guide only (Task 6) |
| Product analytics taxonomy / SDK | ADR-0005 doc-only; see `future_observability.md` |
| Broad per-demo DTO rewrite | Only AI Decision + GraphQL country in Tasks 2–3 |
| Live Render / HF / Supabase network validation | This audit records **no-live-backend** limitation |
| Domain wire-leak cleanup | Pre-existing warn-only debt outside program scope |

## No-live-backend limitation

This baseline and the full hardening program validate contract and transport seams through **static analysis, unit tests, CI fixtures, and architecture guards only**. No calls were made to Render, Hugging Face, Supabase GraphQL, or other live backends during evidence capture. Runtime behavior against real API drift remains a manual/staging follow-up after Tasks 2–8.

## Modified files (Task 1 — docs only)

| Path | Change |
| --- | --- |
| `docs/audits/mobile_backend_integration_hardening_baseline_2026-07-16.md` | **Created** — this document |
| `docs/audits/README.md` | Link under Architecture reviews |
| `tasks/codex/mobile_backend_integration_hardening_plan.md` | Task 1 checkboxes marked complete |

## Follow-ups

- Task 8: final audit with post-remediation scores and `./bin/checklist` evidence table.
- After Task 5: add `check_adhoc_dio_construction.sh` row to evidence table.
- Optional staging smoke against live backends (operator-owned, out of program scope).
