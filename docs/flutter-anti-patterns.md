# Flutter anti-patterns (canonical)

> **Do not duplicate** — [`ai/reports/anti_patterns.md`](../ai/reports/anti_patterns.md) is a stub pointer for agents. Edit this file only.

Static gates and review checklists reference these IDs. Status reflects the **2026-06-15** staff production review remediation pass.

| ID | Pattern | Why it hurts | Preferred fix | Status (2026-06-15) |
| --- | --- | --- | --- | --- |
| AP-01 | Feature `data` imports another feature's `domain` | Hidden coupling; breaks modular monolith | Narrow port in `apps/mobile/lib/core/` (or owning feature `domain` port); wire in DI | **Fixed (chat)** — `RemoteBackendAuthPort`; `modular_metrics --cross-feature-only` empty. Case study still uses port via same seam |
| AP-02 | Presentation imports another feature's `data` | UI layer reaches across persistence | Repository interface in `domain`; DI only in `core/di` | Open — audit per PR |
| AP-03 | Cubit outside `presentation/cubit/` | Inconsistent feature contract | Move cubit + fix barrel/router/tests | **Fixed (graphql_demo)** |
| AP-04 | Parallel failure mappers per transport | Drift in user-facing errors | Single public seam re-exporting transport mappers | **Fixed (chat)** — `chat_remote_failure_mapper.dart` |
| AP-05 | Mutation success after `RequestIdGuard` supersession | False failure UI after successful write | `RequestIdGuard` + `check_mutation_success_after_guard.sh` | **Guard shipped** — fixtures prove bad/good/suppressed |
| AP-06 | `emit` after `close` / stale `mounted` UI | Crashes, flaky widget tests | `CubitGuard`, `mounted` checks, cancel subscriptions in `close` | Ongoing — see [`bloc_standards.md`](bloc_standards.md) |
| AP-07 | Router policy doc ≠ `AppRoutePolicies` | Wrong mental model for gated routes | Audit policy table vs tests; doc-only unless bug | **Audited** — settings is `publicRoute` by design |
| AP-08 | Multiple auth repos without role table | Agents wire wrong token for HTTP vs router | Table in [`authentication.md`](authentication.md) | **Documented** |
| AP-09 | Goldens without spine reference | Interview showcase drifts silently | Named spine golden (`spine_counter_reference`) | **Added** — `test/counter_page_golden_test.dart` |
| AP-10 | Duplicate long-form judgement in `ai/reports/` | Doc drift vs `docs/` | Canonical under `docs/`; stub in `ai/reports/` | **This file** |
| AP-11 | Domain `fromJson`/`toJson` for wire/sync shape | Wire format leaks into domain | DTO + mapper in `data/` | **Fixed** — todo sync, ai_decision, graphql (2026-06 program) |
| AP-12 | SDK/transport enum in domain contract | Vendor coupling in domain | Data adapter; neutral domain codes | **Fixed** — chat `ChatRemotePath` (2026-06 program) |
| AP-13 | `ViewStatus.success` + nullable payload | Invalid ready-without-data | Sealed union; data only in `ready` variant | **Fixed** — profile (2026-06 program) |
| AP-14 | Parallel bool + `ViewStatus` loading | Dual status channels | Single status channel (sealed union) | **Fixed** — chat (2026-06 program) |
| AP-15 | `e.toString()` / `Object? error` in cubit state | Unstable user errors | Feature enum, `AppError`, sealed failure | **Fixed** — profile, scapes, todo_list (2026-06 program) |
| AP-16 | Merge/eligibility policy in `data/` as business rule | Domain logic in wrong layer | Move to `domain/` pure function | **Fixed** — todo merge policy (2026-06 program) |
| AP-17 | Copying legacy demo for new feature | Semantic drift | `reference_features` semantic grade + reduce_surprise guide | **Documented** — [`reduce_surprise_patterns.md`](architecture/reduce_surprise_patterns.md) |

## Enforcement

| ID | Script / test |
| --- | --- |
| AP-01, AP-02 | `tool/modular_metrics.sh`, `tool/check_feature_modularity_leaks.sh`, `tool/check_clean_architecture_imports.sh` |
| AP-03 | `tool/check_clean_architecture_imports.sh` |
| AP-04 | Code review + `test/features/chat/data/` |
| AP-05 | `tool/check_mutation_success_after_guard.sh` |
| AP-07 | `test/app/router/app_route_auth_gate_test.dart` |
| AP-09 | `flutter test test/counter_page_golden_test.dart --tags golden` |
| AP-11 | `tool/check_domain_wire_leaks.sh` (warn); review |
| AP-12 | `tool/check_feature_modularity_leaks.sh`; review |
| AP-13, AP-14 | Review + `tool/check_freezed_preferred.sh` where applicable |
| AP-15 | PR grep checklist in [`reduce_surprise_patterns.md`](architecture/reduce_surprise_patterns.md) |
| AP-16 | Review; `todo_list/domain/todo_merge_policy.dart` unit tests |
| AP-17 | [`reference_features.md`](architecture/reference_features.md); agent guide |

## Related

- [`failure-notebook.md`](failure-notebook.md) — incident-style entries
- [`engineering-decisions.md`](engineering-decisions.md) — ADR index
- [`review/bloc_checklist.md`](review/bloc_checklist.md)
