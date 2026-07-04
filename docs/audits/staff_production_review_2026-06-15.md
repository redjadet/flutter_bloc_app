# Staff+ production review — 2026-06-15

**Scope:** Modular monolith hygiene, spine reliability, agent-facing doc hubs, and seven remediation items (R1–R7) from the build-ready plan.
**Baseline commit:** `6e184623` (Wave 0 preflight).
**Out of scope:** DI split, mandatory use-cases, demo removal, Patrol, new observability vendors, full router refactor.

## Executive summary

| Area | Verdict |
| --- | --- |
| Modular boundaries | **Improved** — chat→supabase cross-feature edge removed (AP-01) |
| Test signal (therapy + chat) | **Improved** — success-path cubit tests + mapper barrel re-export (AP-04) |
| Agent doc surface | **Improved** — thin hubs + canonical anti-patterns / failure notebook |
| Route auth | **Documented** — settings remains `publicRoute`; no policy bug found |
| Interview spine | **Guarded** — named spine golden + existing ADR-0005 scope |

## Scores (post-remediation)

Subjective 1–5 for interview/portfolio readiness; not a CI gate.

| Dimension | Before (est.) | After | Notes |
| --- | ---: | ---: | --- |
| Modular monolith clarity | 3 | **4** | Cross-feature imports empty; AP-01 fixed |
| Cubit / error-handling tests | 3 | **4** | R1 success paths; mutation guard enforced |
| Documentation for agents | 3 | **4** | Hubs + failure notebook + AP table |
| Auth mental model | 3 | **4** | Repository roles table; route audit recorded |
| Visual regression (spine) | 3 | **4** | `spine_counter_reference` golden |
| **Overall** | **3.0** | **4.0** | Seven-item remediation complete |

## Remediation status (R1–R7)

| # | Item | Status | Evidence |
| --- | --- | --- | --- |
| R1 | Therapy cubit success tests | Done | `test/features/online_therapy_demo/presentation/cubit/*_cubit_test.dart` |
| R2 | Chat mapper barrel re-export (AP-04) | Done | `apps/mobile/lib/features/chat/data/chat_remote_failure_mapper.dart` (re-exports transport mappers) |
| R3 | GraphQL cubit placement (AP-03) | Done | `presentation/cubit/graphql_demo_cubit.dart` |
| R4 | Auth repository clarity | Done | [`authentication.md`](../authentication.md) roles table |
| R5 | Route auth audit | Done (no code change) | [`route_auth_policy.dart`](../../apps/mobile/lib/app/router/route_auth_policy.dart); router tests |
| R6 | AP-01 edge removal | Done | `RemoteBackendAuthPort`; empty cross-feature metrics |
| R7 | Spine golden | Done | `test/goldens/spine_counter_reference.phone.png` |

**Dropped (unchanged):** barrels for `case_study_demo` / `staff_app_demo`.

## Evidence table (commands)

| Check | Command | Result (2026-06-15) |
| --- | --- | --- |
| Cross-feature imports | `bash tool/modular_metrics.sh --cross-feature-only` | **No edges** (header only) |
| Mutation success guard | `bash tool/check_mutation_success_after_guard.sh` | `✅ No mutation-success-after-guard violations` |
| Modularity leaks | `bash tool/check_feature_modularity_leaks.sh` | `✅ No modularity or domain-purity violations` |
| Clean architecture imports | `bash tool/check_clean_architecture_imports.sh` | `✅ Clean Architecture imports are valid` |
| Targeted tests (R1–R7) | `flutter test` therapy cubits + chat + router + graphql + goldens | **240 passed** (includes spine golden) |
| Full delivery checklist | `./bin/checklist` | **Passed** (analysis, static checks, full test suite, coverage/docs updates) |
| Static analysis (scoped) | `flutter analyze --fatal-infos` (touched paths) | **No issues found** (~11.6s) |
| Static analysis (full repo) | `bash tool/analyze.sh` | **Passed** (`flutter analyze`, mix_lint, file_length_lint) |

## Doc deliverables

| Artifact | Path |
| --- | --- |
| Architecture hub | [`docs/architecture.md`](../architecture.md) — **link-only** [`system_design_showcase.md`](../system_design_showcase.md) |
| Testing hub | [`docs/testing.md`](../testing.md) |
| Engineering decisions hub | [`docs/engineering-decisions.md`](../engineering-decisions.md) |
| AI workflow hub | [`docs/ai-workflow.md`](../ai-workflow.md) |
| Anti-patterns (canonical) | [`docs/flutter-anti-patterns.md`](../flutter-anti-patterns.md) |
| Failure notebook | [`docs/failure-notebook.md`](../failure-notebook.md) |
| Agent stub | [`ai/reports/anti_patterns.md`](../../ai/reports/anti_patterns.md) |
| Change note | [`docs/changes/2026-06-15_staff-production-review.md`](../changes/2026-06-15_staff-production-review.md) |

## Dependency map note

[`ai/reports/dependency_map.md`](../../ai/reports/dependency_map.md) cross-feature section updated **2026-06-15**: **0 edges** (was **11** in 2026-05-21 snapshot, including chat→supabase). Regenerate before future citations:

```bash
bash tool/modular_metrics.sh > /tmp/modular_metrics.txt
bash tool/modular_metrics.sh --cross-feature-only > /tmp/cross_feature.txt
```

## Follow-ups (not in this pass)

- AP-02: periodic audit for presentation→foreign-data imports
- Case study / staff demo barrels (explicitly dropped)
- Expand `AppRoutePolicies` if new sensitive routes ship without cubit-level guards
