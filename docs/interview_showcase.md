# Interview showcase - mobile SaaS portfolio walk

## 1. Purpose

This repo is a **modular monolith** Flutter reference app: Clean Architecture,
Cubit-first state, offline-first sync, typed routing, and broad demo surface
area. For a **mobile SaaS** interview or technical screen, use this doc as a
**30-minute walkthrough**. It is not a tour of every demo route.

Positioning: one codebase with **33+ feature modules** and shared
infrastructure. The spine features prove delivery depth; the remaining modules
are **depth branches** for follow-up questions.

## 2. Prerequisites

- Flutter / Dart pins: [`tech_stack.md`](tech_stack.md) (machine:
  [`toolchain_versions.env`](toolchain_versions.env))
- First run: [new_developer_guide.md](new_developer_guide.md)
- Default entry: `apps/mobile/lib/main_dev.dart` (dev flavor)
- Agent harness (optional): [AGENTS.md](../AGENTS.md), [agent_knowledge_base.md](agent_knowledge_base.md)

## 3. 30-minute walk (frozen spine)

| Step | Route | Signal | Open in code |
| --- | --- | --- | --- |
| 1 | `/` Counter | Offline-first counter: local Hive, sync, Cubit lifecycle. Tap +/-; mention sync banner. Pending-queue UI (counts + inspector) is behind `--dart-define=SHOW_PENDING_SYNC_QUEUE_UI=true` (default off). | [`apps/mobile/lib/features/counter/`](../apps/mobile/lib/features/counter/) |
| 2 | `/todo-list` | List CRUD with filters, selection, realtime-capable repo; same sync patterns as counter. | [`apps/mobile/lib/features/todo_list/`](../apps/mobile/lib/features/todo_list/) |
| 3 | `/chat-list` → `/chat` | API-first chat: local history, transport badges (Supabase / direct / Render orchestration). Open one thread; send is gated on connectivity/state. | [`apps/mobile/lib/features/chat/`](../apps/mobile/lib/features/chat/) |
| 4 | `/settings` → **Sync diagnostics** | “Validate what you ship”: scroll to Sync diagnostics (theme/locale E2E does **not** cover this — **demo live**). | [`sync_diagnostics_section.dart`](../apps/mobile/lib/features/settings/presentation/widgets/sync_diagnostics_section.dart) |
| 5 | Repo harness | Plan → implement → verify: [`AGENTS.md`](../AGENTS.md), `./bin/checklist`, validation routing. | [AGENTS.md](../AGENTS.md), [validation_scripts.md](validation_scripts.md) |

### 3b. 12-minute production ownership walkthrough

Use when the JD emphasizes **production ownership** (analytics consent, Remote
Config kill-switch, FCM safety, Crashlytics, frame budgets, release dry-run).
Policy: [ADR 0005](adr/0005-interview-showcase-scope.md) and
[ADR 0006](adr/0006-production-readiness-demo.md). Does **not** replace §3;
it is a registered alternate.

| Min | Do | Evidence |
| --- | --- | --- |
| 0–2 | Run `apps/mobile` (`main_dev.dart`). Open **Example → Production readiness**. | Route [`/production-readiness`](../apps/mobile/lib/app/router/app_routes.dart); no Firebase redirect. |
| 2–4 | Confirm **mode** (live \| simulated), Crashlytics status, **Emit test non-fatal**, kill-switch / RC variant + retry. | Cubit/page under [`features/production_readiness/`](../apps/mobile/lib/features/production_readiness/); RC keys `production_demo_*`; triage [crashlytics_triage_runbook.md](observability/crashlytics_triage_runbook.md). |
| 4–6 | Toggle **analytics consent** (default off). Event count stays silent until opt-in. | [`app/analytics/`](../apps/mobile/lib/app/analytics/); Settings section [`analytics_consent_section.dart`](../apps/mobile/lib/features/settings/presentation/widgets/analytics_consent_section.dart). |
| 6–8 | In simulated mode, **Emit simulated notification**. Logs show source / presence / key count only. | [`SimulatedFcmMessagingService`](../apps/mobile/lib/features/fcm_demo/data/simulated_fcm_messaging_service.dart); [`fcm_log_redaction.dart`](../apps/mobile/lib/features/fcm_demo/data/fcm_log_redaction.dart). |
| 8–10 | Watch **frame** p90/p99 / missed counters update. | [`frame_timing_monitor.dart`](../apps/mobile/lib/app/diagnostics/frame_timing_monitor.dart); budgets [`tool/perf_budgets.json`](../tool/perf_budgets.json). |
| 10–12 | Point at CI dry-run; optional depth: auth-gated Functions diagnostic or Counter sync. | [`.github/workflows/mobile_release_dry_run.yml`](../.github/workflows/mobile_release_dry_run.yml); [`firebase_functions_test_page.dart`](../apps/mobile/lib/features/example/presentation/pages/firebase_functions_test_page.dart) (no raw token UI); general spine #1. |

```bash
cd apps/mobile && flutter test test/features/production_readiness test/app/analytics test/app/diagnostics
python3 -m unittest tool/analyze_perf_trace_test.py
./bin/integration_tests integration_test/pr_smoke_flows_test.dart   # includes J6 production readiness
```

Case study: [production readiness](changes/2026-07-31_production_readiness_case_study.md).

**Depth on request** (not spine): case study, therapy, charts, GraphQL,
iGaming, **native platform showcase** (MethodChannel + EventChannel + FFI +
mobile PlatformView/haptic/share), and other
modules in [feature_overview.md](feature_overview.md).

## 4. JD evidence table

| JD theme | Claim | Proof path | Command / demo |
| --- | --- | --- | --- |
| Flutter / Dart / Cubit | Production-style feature modules, typed state | Spine #1–3 | Run app; open `counter/presentation/cubit/counter_cubit.dart`, `todo_list_cubit.dart`, `chat_cubit.dart` |
| Modular architecture | Feature boundaries + leak checks | [modularity.md](modularity.md), `tool/check_feature_modularity_leaks.sh` | `bash tool/check_feature_modularity_leaks.sh` |
| Automated testing | Unit/widget + integration tiers | [testing_overview.md](testing_overview.md) | `./bin/checklist-fast`; PR smoke below |
| API-first / cross-stack | Chat + HTTP stack | [ai_integration.md](integrations/ai_integration.md), `packages/networking/lib/src/` | Spine #3; badges on chat |
| Validate / instrument | Structured errors, sync telemetry, Crashlytics when Firebase on (allowlisted keys + test non-fatal); **consent-gated** product analytics allowlist | [observability.md](observability.md), [crashlytics_triage_runbook.md](observability/crashlytics_triage_runbook.md), [ADR 0006](adr/0006-production-readiness-demo.md) | Spine #4; `/production-readiness` Emit test non-fatal (simulated = local only) |
| Ownership | Counter vertical narrative **or** production-readiness case study | [features/counter_outcome_brief.md](features/counter_outcome_brief.md), [changes/2026-07-31_production_readiness_case_study.md](changes/2026-07-31_production_readiness_case_study.md) | Read brief; tie to sync + persistence test **or** `/production-readiness` |
| Delivery ownership | CI, validation routing, release docs, dry-run workflow (**not** store publishing) | README badges, [feature_overview.md](feature_overview.md), [deployment.md](deployment.md), [mobile_release_dry_run.yml](../.github/workflows/mobile_release_dry_run.yml) | CI badge; depth table §13; dry-run Actions |
| Firebase Functions (deep) | Auth-gated callable diagnostic; `hf_read_token` never rendered (presence + length only) | [`firebase_functions_test_page.dart`](../apps/mobile/lib/features/example/presentation/pages/firebase_functions_test_page.dart) | Example → Firebase Functions; signed-out disables token action |
| Firestore mapper seam | Inbox recipient/message map isolated + unit-tested; feature-level P3 still deferred | [`staff_demo_inbox_firestore_map.dart`](../apps/mobile/lib/features/staff_app_demo/data/staff_demo_inbox_firestore_map.dart); [senior_patterns_review_2026-06.md](audits/senior_patterns_review_2026-06.md) | `flutter test …/staff_demo_inbox_firestore_map_test.dart` |
| RTL / i18n | Six locales including Arabic; ownership spine RTL widget proof | [localization.md](engineering/localization.md); production_readiness + Counter RTL tests | `flutter test` Counter/PR RTL suites |
| Mixpanel / Sentry (nice) | **Not shipped** — documented seams; Firebase Analytics only via consent-gated port | [observability.md](observability.md) | Interview appendix script §12 |
| Patrol (nice) | **Plan only** (not in pubspec; local pilot notes may exist under gitignored docs/plans) | [observability.md](observability.md), this showcase | — |
| Platform channels / FFI (nice) | Live Swift/Kotlin/C interop, EventChannel telemetry, mobile PlatformView banner, haptic + system share behind clean-arch ports; web/desktop unavailable stubs | [`apps/mobile/lib/features/native_platform_showcase/`](../apps/mobile/lib/features/native_platform_showcase/), [reference_features.md](architecture/reference_features.md) | Example → Native platform showcase; `cd apps/mobile && flutter test test/features/native_platform_showcase/` |
| Store release (nice) | Release scripts + deployment doc; **dry-run workflow is not publishing** | [deployment.md](deployment.md) | `./tool/release_both_stores.sh` (reference); Actions → Mobile release dry-run |

## 4a. Decision-density stories

Experience should change the default from implementing the first workable
solution to proving the problem, choosing the smallest reversible design,
protecting security and reliability boundaries, and turning lessons into
reusable tests, standards, automation, or documentation. Decision density—not
implementation volume—is the signal.

Present each story in this order:

**Context → Ownership → Options → Decision → Rejected approach → Trade-off →
Proof/outcome → Reflection → New default → Revisit trigger**

| Story | Changed default | Case study |
| --- | --- | --- |
| Mobile release secrets | Classify every value as public-client or server-only before build forwarding. | [Mobile release secret boundary](case_studies/engineering/mobile_release_secret_boundary.md) |
| macOS plugin compatibility | Isolate incompatible plugins; preserve SwiftPM for compatible dependencies. | [macOS dependency compatibility](case_studies/engineering/macos_dependency_compatibility.md) |
| Offline-first ownership | Prove newer local intent survives remote merge and online-write/replay overlap. | [Social Feed offline ownership](case_studies/engineering/social_feed_offline_ownership.md) |
| Performance | Prove a production-path bottleneck before optimizing; retain regression and runtime evidence. | [Todo measurement-gated performance](case_studies/engineering/todo_measurement_gated_performance.md) |

Each case separates implemented behavior, current repository proof, historical
evidence, deferred scope, and individual contribution from team/system behavior.
Use **I** only for work personally designed, implemented, reviewed, or driven;
Git state proves system behavior, not team size, adoption, or one person's role.

## 4b. Flutter judgment guidance

Use this structure for design questions: **choose → name constraints → state the
trade-off → point to proof**. “It depends” is incomplete until the answer names
the deciding conditions and selects an approach for the stated scenario.

### How do you structure a large app?

Use feature-first modules with the repo dependency rule
`Presentation -> Domain <- Data`. Keep UI rendering and interaction in widgets,
workflow state in one consistent Cubit/BLoC approach, pure policy in domain, and
I/O/mapping in data. Prefer explicit names and constructor-injected contracts
over clever indirection: the target reader is the developer changing the code
six months later. Proof: [Clean Architecture](clean_architecture.md),
[feature structure contract](architecture/feature_structure_contract.md), and
[state-management choice](architecture/state_management_choice.md).

Let folders grow with complexity. Keep layer boundaries, but do not pre-create
empty trees or a nested folder for one file. Make a folder when two or more
related, distinct things need separation from their siblings; split or rename
later when that boundary earns its cost. IDE refactors and Git history make that
routine maintenance, not a reason to preserve speculative structure.

### What changes when it must serve millions?

Bound every growing surface. Add cursor or offset pagination only when a product
list becomes unbounded; define refresh, load-more, dedupe, and termination
semantics before building helpers. Give each cache an owner plus freshness,
invalidation, eviction, and failure behavior. Move measured CPU-heavy parsing or
transforms off the UI isolate, but keep short work and Flutter APIs on it. Profile
first; otherwise optimization guesses consume time without proving a bottleneck.
This repo currently has a pagination contract, not a shipped generic pagination
framework. Proof: [API contract guide](backend/API_CONTRACT_GUIDE.md),
[deferred backend work](backend/MOBILE_BACKEND_DEFERRED_WORK.md), and
[performance guidance](reliability_error_handling_performance.md).

### How do you keep it testable?

Depend on narrow domain abstractions, inject implementations at composition
boundaries, and keep pure logic outside Flutter. Then domain, data, and Cubit
behavior stay cheap to unit-test; widget tests cover rendering contracts; a
small integration set guards critical journeys such as auth, payments, core
navigation, and persistence. Proof: [testing overview](testing_overview.md) and
[integration journey map](engineering/integration_journey_map.md).

### How do you stop the app getting owned?

Treat the client as untrusted. Keep provider/backend secrets server-side, store
session material through Keychain/Keystore abstractions rather than
`SharedPreferences`, and enforce authorization and input validation on the
server. Use certificate pinning only with an explicit threat model, rotation,
and recovery plan; this repo defaults pinning to disabled. Release obfuscation
may raise reverse-engineering cost, but it never makes an embedded secret safe.
Request permissions at point of need, explain the benefit before the platform
prompt, and exclude personal data, tokens, and payloads from logs and telemetry.
Proof: [security and secrets](security_and_secrets.md),
[certificate pinning](security/certificate_pinning.md), and
[logging](engineering/logging.md).

### Third-party package or roll your own?

Use a trusted maintained package for hard, solved infrastructure such as HTTP
or serialization after checking release activity, issue health, null safety,
license, transitive cost, and real support for every target platform. Keep a
two-line helper local when a dependency would create more ownership than value.
Own code when behavior is core product differentiation or available packages
are materially bloated, unsafe, or mismatched. Record the decision and verify
the pinned API rather than assuming “latest” means compatible. Proof:
[dependency update guidance](engineering/DEPENDENCY_UPDATES.md) and
[package API verification](agent_kb/package_docs_mcp.md).

### Does it work when the app is closed?

Only promise what each OS can schedule. Android WorkManager and iOS background
task APIs are candidates for short, idempotent, resumable jobs, not permanent
processes or exact-time execution. Design for cancellation, retry, expiry, and
duplicate delivery; test on physical devices and state OS restrictions. This
repo does not currently claim general terminated-app background work. FCM has a
separate documented delivery scope. Proof:
[reliability guidance](reliability_error_handling_performance.md) and
[FCM integration](integrations/fcm_demo_integration.md).

### How do you keep battery use low and frames smooth?

Batch and coalesce calls, avoid tight polling, and stop timers, streams, and
route-owned work when the surface is not visible. Use const widgets, narrow
state selection, builder lists, bounded image caching, and lifecycle cleanup.
Profile CPU, memory, network, and frame timelines in profile mode before and
after a change. A stable frame budget wins over an animation that repeatedly
janks. Proof: [performance review checklist](review/performance_checklist.md) and
[performance notes](performance/performance_bottlenecks.md).

### Pattern underneath every answer

Coworkers and anyone trying to understand this project are looking for
judgment: make a decision, expose its costs, name the revisit trigger, and show
how evidence can falsify it. Generated code makes this more important, because
producing a working screen is cheap while preserving a design through a year of
change remains engineering work.

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

**Linux CI note:** Full iOS integration often runs from GitHub Actions workflow
dispatch, not every PR path; see [validation_scripts.md](validation_scripts.md).

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
9. Production readiness (J6: route → optional simulated emit → consent → release retry)

## 6. Testing story

- **Unit / widget:** See current counts and filtered rollup in the generated
  coverage summary artifact.
  CI coverage floor is **75%** filtered rollup; team target is **85%**
  (source of truth: [`CODE_QUALITY.md`](CODE_QUALITY.md)).
- **Integration tiers:** `smoke` / `standard` / `exhaustive` via `integration_test/*_flows_test.dart` and env `INTEGRATION_TESTS_TIER`
- **PR smoke:** `integration_test/pr_smoke_flows_test.dart` — matches spine steps 1–3 plus launch/charts/search/settings
- **Patrol:** not in `pubspec.yaml`; pilot remains deferred (local plan notes only)

## 7. Modular architecture

- Policy: [modularity.md](modularity.md)
- Enforcement: `bash tool/check_feature_modularity_leaks.sh`, `tool/modular_metrics.sh`
- Ports/adapters in `apps/mobile/lib/app/` or packages, and shared sync under
  `packages/storage/lib/src/sync/`
- Implementation notes: [changes/2026-05-12_modular_architecture_plan_implementation.md](changes/2026-05-12_modular_architecture_plan_implementation.md)

## 8. Cross-stack

- **Chat:** FastAPI / Render orchestration, Supabase paths — [integrations/render_fastapi_chat_demo.md](integrations/render_fastapi_chat_demo.md)
- **Supabase:** [supabase/README.md](../supabase/README.md)
- **GraphQL demo:** feature module + shared HTTP
- Resilience: [reliability_error_handling_performance.md](reliability_error_handling_performance.md), `packages/networking/lib/src/`

## 9. AI delivery

Loop: plan once → execute → verify → report proof
([agent_knowledge_base.md](agent_knowledge_base.md)).

Review: [ai_code_review_protocol.md](ai_code_review_protocol.md).

**Annotated example (agent session):**
[changes/2026-05-12_modular_architecture_plan_implementation.md](changes/2026-05-12_modular_architecture_plan_implementation.md)

- modular metrics, leak script, DI split, domain surface tests.

## 10. Release

- [deployment.md](deployment.md)
- Store release reference: `./tool/release_both_stores.sh`
- Lifecycle: [REPOSITORY_LIFECYCLE.md](engineering/REPOSITORY_LIFECYCLE.md)

## 11. Observability (current)

- **Crashlytics:** registered when Firebase initializes ([`firebase_bootstrap_service.dart`](../apps/mobile/lib/app/bootstrap/firebase_bootstrap_service.dart))
- **Structured errors:** `AppErrorCode`, `NetworkErrorMapper`, localized user messaging
- **Sync telemetry:** diagnostics UI + pending queue inspection on counter
- **Product analytics SDK:** not configured (no Mixpanel/Sentry in `pubspec.yaml`)

Details: [observability.md](observability.md)

## 12. Future observability (interview script)

If asked about Mixpanel/Sentry:

> “We structured errors and sync telemetry today; Crashlytics is on when Firebase is enabled. Product analytics would plug in at logging/sync seams — see [observability.md](observability.md) — not claimed as shipped.”

See [observability.md](observability.md) § Sentry + Crashlytics and § Product analytics.

## 13. Depth branches

| Topic | Doc |
| --- | --- |
| Native platform showcase (MethodChannel, FFI, layered ports) | [`apps/mobile/lib/features/native_platform_showcase/README.md`](../apps/mobile/lib/features/native_platform_showcase/README.md), [2026-06-08 brief](changes/2026-06-08_native_platform_showcase_feature_brief.md) |
| Case studies | [case_studies/README.md](case_studies/README.md) |
| Online therapy | [online_therapy_demo/README.md](online_therapy_demo/README.md) |
| Realtime market | [features/realtime_market.md](features/realtime_market.md) |
| Social feed demo (simulated judgment guidance) | [features/social_feed_demo.md](features/social_feed_demo.md), Example → Social feed demo |
| Full catalog | [feature_overview.md](feature_overview.md) |

## 14. Verification snapshot

- **Current proof:** run `./bin/checklist` and read live counts from the run
  output plus its generated coverage summary artifact.
  Do not hardcode test counts here.
- **Engineering claim:** [`engineering/engineering_quality_scorecard.md`](engineering/engineering_quality_scorecard.md)
  (badge + `tool/check_engineering_quality_scorecard_gate.sh`).
- **Edit expectation:** documentation-only changes can use
  `./bin/checklist-fast --no-reuse`; lib or mixed lib+docs changes require the
  full gate above.
