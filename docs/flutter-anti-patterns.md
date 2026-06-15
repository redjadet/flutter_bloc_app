# Flutter anti-patterns (canonical)

> **Do not duplicate** — [`ai/reports/anti_patterns.md`](../ai/reports/anti_patterns.md) is a stub pointer for agents. Edit this file only.

Static gates and review checklists reference these IDs. Status reflects the **2026-06-15** staff production review remediation pass.

| ID | Pattern | Why it hurts | Preferred fix | Status (2026-06-15) |
| --- | --- | --- | --- | --- |
| AP-01 | Feature `data` imports another feature's `domain` | Hidden coupling; breaks modular monolith | Narrow port in `lib/core/` (or owning feature `domain` port); wire in DI | **Fixed (chat)** — `RemoteBackendAuthPort`; `modular_metrics --cross-feature-only` empty. Case study still uses port via same seam |
| AP-02 | Presentation imports another feature's `data` | UI layer reaches across persistence | Repository interface in `domain`; DI only in `core/di` | Open — audit per PR |
| AP-03 | Cubit outside `presentation/cubit/` | Inconsistent feature contract | Move cubit + fix barrel/router/tests | **Fixed (graphql_demo)** |
| AP-04 | Parallel failure mappers per transport | Drift in user-facing errors | Single public seam re-exporting transport mappers | **Fixed (chat)** — `chat_remote_failure_mapper.dart` |
| AP-05 | Mutation success after `RequestIdGuard` supersession | False failure UI after successful write | `RequestIdGuard` + `check_mutation_success_after_guard.sh` | **Guard shipped** — fixtures prove bad/good/suppressed |
| AP-06 | `emit` after `close` / stale `mounted` UI | Crashes, flaky widget tests | `CubitGuard`, `mounted` checks, cancel subscriptions in `close` | Ongoing — see [`bloc_standards.md`](bloc_standards.md) |
| AP-07 | Router policy doc ≠ `AppRoutePolicies` | Wrong mental model for gated routes | Audit policy table vs tests; doc-only unless bug | **Audited** — settings is `publicRoute` by design |
| AP-08 | Multiple auth repos without role table | Agents wire wrong token for HTTP vs router | Table in [`authentication.md`](authentication.md) | **Documented** |
| AP-09 | Goldens without spine reference | Interview showcase drifts silently | Named spine golden (`spine_counter_reference`) | **Added** — `test/counter_page_golden_test.dart` |
| AP-10 | Duplicate long-form judgement in `ai/reports/` | Doc drift vs `docs/` | Canonical under `docs/`; stub in `ai/reports/` | **This file** |

## Enforcement

| ID | Script / test |
| --- | --- |
| AP-01, AP-02 | `tool/modular_metrics.sh`, `tool/check_feature_modularity_leaks.sh`, `tool/check_clean_architecture_imports.sh` |
| AP-03 | `tool/check_clean_architecture_imports.sh` |
| AP-04 | Code review + `test/features/chat/data/` |
| AP-05 | `tool/check_mutation_success_after_guard.sh` |
| AP-07 | `test/app/router/app_route_auth_gate_test.dart` |
| AP-09 | `flutter test test/counter_page_golden_test.dart --tags golden` |

## Related

- [`failure-notebook.md`](failure-notebook.md) — incident-style entries
- [`engineering-decisions.md`](engineering-decisions.md) — ADR index
- [`review/bloc_checklist.md`](review/bloc_checklist.md)
