# Interview showcase — mobile SaaS portfolio walk

## 1. Purpose

This repo is a **modular monolith** Flutter reference app: Clean Architecture, Cubit-first state, offline-first sync, typed routing, and broad demo surface area. For a **mobile SaaS** interview, use this doc as a **30-minute script** — not a tour of every demo route.

Honest positioning: one codebase with **33+ feature modules** and shared infrastructure; spine features prove delivery depth; everything else is linked as **depth branches**.

## 2. Prerequisites

- Flutter **3.44.2** / Dart **3.12.2** (see [README](../README.md))
- First run: [new_developer_guide.md](new_developer_guide.md)
- Default entry: `lib/main_dev.dart` (dev flavor)
- Agent harness (optional): [AGENTS.md](../AGENTS.md), [agent_knowledge_base.md](agent_knowledge_base.md)

## 3. 30-minute walk (frozen spine)

| Step | Route | Say this | Open in code |
| --- | --- | --- | --- |
| 1 | `/` Counter | Offline-first counter: local Hive, pending sync queue, Cubit lifecycle. Tap +/-; mention sync banner and queue inspector when pending ops exist. | [`lib/features/counter/`](../lib/features/counter/) |
| 2 | `/todo-list` | List CRUD with filters, selection, realtime-capable repo; same sync patterns as counter. | [`lib/features/todo_list/`](../lib/features/todo_list/) |
| 3 | `/chat-list` → `/chat` | API-first chat: local history, transport badges (Supabase / direct / Render orchestration). Open one thread; send is gated on connectivity/state. | [`lib/features/chat/`](../lib/features/chat/) |
| 4 | `/settings` → **Sync diagnostics** | “Validate what you ship”: scroll to Sync diagnostics (theme/locale E2E does **not** cover this — **demo live**). | [`sync_diagnostics_section.dart`](../lib/features/settings/presentation/widgets/sync_diagnostics_section.dart) |
| 5 | Repo harness | Plan → implement → verify: [`AGENTS.md`](../AGENTS.md), `./bin/checklist`, validation routing. | [AGENTS.md](../AGENTS.md), [validation_scripts.md](validation_scripts.md) |

**Depth on request** (not spine): case study, staff app, therapy, charts, GraphQL, iGaming, **native platform showcase** (MethodChannel + FFI layering), etc. → [feature_overview.md](feature_overview.md).

## 4. JD evidence table

| JD theme | Claim | Proof path | Command / demo |
| --- | --- | --- | --- |
| Flutter / Dart / Cubit | Production-style feature modules, typed state | Spine #1–3 | Run app; open `counter/presentation/cubit/counter_cubit.dart`, `todo_list_cubit.dart`, `chat_cubit.dart` |
| Modular architecture | Feature boundaries + leak checks | [modularity.md](modularity.md), `tool/check_feature_modularity_leaks.sh` | `bash tool/check_feature_modularity_leaks.sh` |
| Automated testing | Unit/widget + integration tiers | [testing_overview.md](testing_overview.md) | `./bin/checklist-fast`; PR smoke below |
| API-first / cross-stack | Chat + HTTP stack | [ai_integration.md](ai_integration.md), `lib/shared/http/` | Spine #3; badges on chat |
| Validate / instrument | Structured errors, sync telemetry, Crashlytics when Firebase on | [observability.md](observability.md), [counter_outcome_brief.md](features/counter_outcome_brief.md) | Spine #4 sync diagnostics |
| AI-enabled delivery | Agent loop + review protocol | [ai_code_review_protocol.md](ai_code_review_protocol.md), [changes/2026-05-12_modular_architecture_plan_implementation.md](changes/2026-05-12_modular_architecture_plan_implementation.md) | Spine #5 |
| Ownership | Counter vertical narrative | [features/counter_outcome_brief.md](features/counter_outcome_brief.md) | Read brief; tie to sync + persistence test |
| Agile / SaaS | CI + vertical demos as depth | README badges, [feature_overview.md](feature_overview.md) | CI badge; depth table §13 |
| Mixpanel / Sentry (nice) | **Not shipped** — documented seams | [plans/future_observability.md](plans/future_observability.md) | Interview appendix script §12 |
| Patrol (nice) | **Plan only** | [plans/patrol_e2e_pilot.md](plans/patrol_e2e_pilot.md) | — |
| Platform channels / FFI (nice) | Live Swift/Kotlin/C interop behind clean-arch ports; web compiles with unavailable stubs | [`lib/features/native_platform_showcase/`](../lib/features/native_platform_showcase/), [reference_features.md](architecture/reference_features.md) | Example → Native platform showcase; `flutter test test/features/native_platform_showcase/` |
| Store release (nice) | Release scripts + deployment doc | [deployment.md](deployment.md) | `./tool/release_both_stores.sh` (reference) |

## 5. Proof commands

```bash
# Docs/tooling only (no lib/ changes)
./bin/checklist-fast

# After lib/ or mixed lib+docs delivery (merge gate)
./bin/checklist

# PR-aligned integration smoke (macOS + booted simulator)
./bin/integration_tests integration_test/pr_smoke_flows_test.dart

# Broader smoke tier (optional)
INTEGRATION_TESTS_TIER=smoke ./bin/integration_tests
```

**Manual proof (spine step 4):** Counter offline change → Settings → Sync diagnostics (pending ops, last sync).

**Linux CI note:** Full iOS integration often runs from GitHub Actions workflow dispatch, not every PR path — see [validation_scripts.md](validation_scripts.md).

### PR smoke flows (after showcase alignment)

Registered in `registerPrSmokeIntegrationFlows()`:

1. Guest sign-in (anonymous → Home/counter; real Firebase Auth)
2. App launch
3. Charts
4. Search
5. Settings (theme/locale)
6. Todo list
7. Counter persistence
8. Chat list

## 6. Testing story

- **Unit / widget:** ~399 tests; CI coverage gate **60%** (see [coverage/coverage_summary.md](../coverage/coverage_summary.md))
- **Integration tiers:** `smoke` / `standard` / `exhaustive` via `integration_test/*_flows_test.dart` and env `INTEGRATION_TESTS_TIER`
- **PR smoke:** `integration_test/pr_smoke_flows_test.dart` — matches spine steps 1–3 plus launch/charts/search/settings
- **Patrol:** not in `pubspec.yaml`; pilot scoped in [plans/patrol_e2e_pilot.md](plans/patrol_e2e_pilot.md)

## 7. Modular architecture

- Policy: [modularity.md](modularity.md)
- Enforcement: `bash tool/check_feature_modularity_leaks.sh`, `tool/modular_metrics.sh`
- Ports/adapters in `lib/core/` and shared sync under `lib/shared/sync/`
- Implementation notes: [changes/2026-05-12_modular_architecture_plan_implementation.md](changes/2026-05-12_modular_architecture_plan_implementation.md)

## 8. Cross-stack

- **Chat:** FastAPI / Render orchestration, Supabase paths — [integrations/render_fastapi_chat_demo.md](integrations/render_fastapi_chat_demo.md)
- **Supabase:** [supabase/README.md](../supabase/README.md)
- **GraphQL demo:** feature module + shared HTTP
- Resilience: [reliability_error_handling_performance.md](reliability_error_handling_performance.md), `lib/shared/http/`

## 9. AI delivery

Loop: plan once → execute → verify → report proof ([agent_knowledge_base.md](agent_knowledge_base.md)).

Review: [ai_code_review_protocol.md](ai_code_review_protocol.md).

**Annotated example (agent session):** [changes/2026-05-12_modular_architecture_plan_implementation.md](changes/2026-05-12_modular_architecture_plan_implementation.md) — modular metrics, leak script, DI split, domain surface tests.

## 10. Release

- [deployment.md](deployment.md)
- Store release reference: `./tool/release_both_stores.sh`
- Lifecycle: [REPOSITORY_LIFECYCLE.md](REPOSITORY_LIFECYCLE.md)

## 11. Observability (current)

- **Crashlytics:** registered when Firebase initializes ([`firebase_bootstrap_service.dart`](../lib/core/bootstrap/firebase_bootstrap_service.dart))
- **Structured errors:** `AppErrorCode`, `NetworkErrorMapper`, localized user messaging
- **Sync telemetry:** diagnostics UI + pending queue inspection on counter
- **Product analytics SDK:** not configured (no Mixpanel/Sentry in `pubspec.yaml`)

Details: [observability.md](observability.md)

## 12. Future observability (interview script)

If asked about Mixpanel/Sentry:

> “We structured errors and sync telemetry today; Crashlytics is on when Firebase is enabled. Product analytics would plug in at logging/sync seams — see [`plans/future_observability.md`](plans/future_observability.md) — not claimed as shipped.”

See [plans/future_observability.md](plans/future_observability.md).

## 13. Depth branches

| Topic | Doc |
| --- | --- |
| Native platform showcase (MethodChannel, FFI, layered ports) | [`lib/features/native_platform_showcase/README.md`](../lib/features/native_platform_showcase/README.md), [2026-06-08 brief](changes/2026-06-08_native_platform_showcase_feature_brief.md) |
| Case studies | [case_studies/README.md](case_studies/README.md) |
| Staff app demo | [staff_app_demo_walkthrough.md](staff_app_demo_walkthrough.md) |
| Online therapy | [online_therapy_demo/README.md](online_therapy_demo/README.md) |
| Realtime market | [features/realtime_market.md](features/realtime_market.md) |
| Full catalog | [feature_overview.md](feature_overview.md) |

## 14. Last verified

- **Date:** 2026-05-20
- **Scoped validation (lib + docs):** `dart analyze` on touched files — PASS; widget tests (counter app bar, todo page, chat contact tile) — PASS (36 tests); `bash tool/check_docs_gardening.sh` — PASS; `bash tool/validate_task_trackers.sh` — PASS
- **`./bin/checklist`:** PASS — full delivery gate (2221 tests, coverage summary refresh)
- **PR smoke runtime:** `./bin/integration_tests integration_test/pr_smoke_flows_test.dart` — PASS (7/7 on iPhone 17 Pro sim)
