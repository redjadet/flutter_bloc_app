# Failure notebook

> **Do not duplicate** — short, durable entries for bugs and near-misses agents should not re-learn. Link to tests/fixtures, not prose-only.

Format: **Symptom → Cause → Fix → Proof**

---

## FN-01 — Therapy booking "failed" after successful create

**Symptom:** `ClientBookingCubit` showed error after slot booking succeeded.
**Cause:** Post-create reload superseded by `RequestIdGuard`; cubit treated superseded fetch as failure.
**Fix:** Success path when guard reports supersession; static guard `check_mutation_success_after_guard.sh`.
**Proof:** `tool/fixtures/mutation_success_after_guard/`; [`docs/changes/2026-06-15_therapy-booking-reload-supersession.md`](changes/2026-06-15_therapy-booking-reload-supersession.md)

---

## FN-02 — Mutation success guard false negatives

**Symptom:** CI or pre-commit blocks valid cubit patterns.
**Cause:** Guard regex too broad or missing suppression comment.
**Fix:** `// mutation-success-guard: intentional` on documented exceptions; good/bad fixtures in `tool/fixtures/`.
**Proof:** `bash tool/check_mutation_success_after_guard.sh` (bad fails, good + suppressed pass)

---

## FN-03 — Chat → Supabase domain import (AP-01)

**Symptom:** `modular_metrics --cross-feature-only` showed chat importing `supabase_auth/domain`.
**Cause:** `ChatAuthSessionPortAdapter` depended on concrete `SupabaseAuthRepository`.
**Fix:** `RemoteBackendAuthPort` in `apps/mobile/lib/core/auth/`; adapter depends on port; DI binds Supabase repo as port.
**Proof:** Empty cross-feature report; `check_feature_modularity_leaks.sh` pass

---

## FN-04 — Three chat failure mappers (AP-04)

**Symptom:** Inconsistent error copy and duplicate mapping logic across Render/Supabase/direct paths.
**Cause:** Each repository owned a separate mapper file without a shared entry.
**Fix:** `chat_remote_failure_mapper.dart` re-exports transport-specific mappers; repos import one seam.
**Proof:** `flutter test test/features/chat/`

---

## FN-05 — GraphQL cubit wrong folder (AP-03)

**Symptom:** `graphql_demo_cubit.dart` under `presentation/` not `presentation/cubit/`.
**Cause:** Early feature scaffold before contract hardened.
**Fix:** Moved cubit; updated barrel, `routes_core.dart`, tests.
**Proof:** `flutter test test/features/graphql_demo/`; clean-architecture import check

---

## FN-06 — Therapy cubits missing success-path tests

**Symptom:** R1 audit: error-only coverage for admin/client_booking; no cubit tests for messaging.
**Cause:** Shared `cubit_error_handling_test.dart` without happy-path assertions.
**Fix:** Dedicated `admin_cubit_test.dart`, `messaging_cubit_test.dart`, `client_booking_cubit_test.dart` with success flows.
**Proof:** `flutter test test/features/online_therapy_demo/presentation/cubit/`

---

## FN-07 — Messaging refresh test expected messages

**Symptom:** `messaging_cubit_test` failed on `refresh()` — `messages` empty.
**Cause:** `createAppointment` seeds conversations, not message list.
**Fix:** Assert `messages` empty after refresh; cover send in separate test.
**Proof:** Same test directory green (170 tests in therapy+chat pass)

---

## FN-08 — Settings route auth documentation drift (AP-07)

**Symptom:** [`authentication.md`](authentication.md) claimed settings behind `AppRouteAuthGate`.
**Cause:** Policy intentionally `publicRoute`; page uses biometric gate.
**Fix:** Doc aligned with `AppRoutePolicies.settings`; audit recorded no router code change.
**Proof:** `test/app/router/app_route_auth_gate_test.dart`; [`route_auth_policy.dart`](../apps/mobile/lib/app/router/route_auth_policy.dart)

---

## FN-09 — Dual auth confusion for agents

**Symptom:** Agents injected `SupabaseAuthRepository` into router or HTTP paths.
**Cause:** No single comparison table for auth types.
**Fix:** Repository roles table at top of [`authentication.md`](authentication.md).
**Proof:** Doc review in staff audit 2026-06-15

---

## FN-10 — iOS simulator Keychain guest fallback

**Symptom:** Firebase Auth fails on simulator; app stuck on auth screen.
**Cause:** Keychain entitlement errors (`keychain-error`).
**Fix:** Local-only guest session in debug; omit RTDB remotes until real Firebase user.
**Proof:** [`docs/changes/2026-06-06_guest-sign-in-ios-simulator.md`](changes/2026-06-06_guest-sign-in-ios-simulator.md); integration journey J1

---

## FN-11 — Spine golden missing for interview showcase

**Symptom:** Counter UI could drift without a named reference asset.
**Cause:** Many counter goldens but no explicit "spine reference" label.
**Fix:** `spine_counter_reference` golden in `counter_page_golden_test.dart`.
**Proof:** `flutter test test/counter_page_golden_test.dart --tags golden`

---

## FN-12 — Agent doc duplication (`ai/reports` vs `docs/`)

**Symptom:** [`ai/reports/anti_patterns.md`](../ai/reports/anti_patterns.md) and dependency maps duplicated canonical docs.
**Cause:** Historical agent report location before `docs/` hubs.
**Fix:** Canonical [`flutter-anti-patterns.md`](flutter-anti-patterns.md); stub stays in [`ai/reports/anti_patterns.md`](../ai/reports/anti_patterns.md).
**Proof:** Staff production review 2026-06-15

---

## FN-13 — Deep link bypasses auth redirect

**Symptom:** User lands on sensitive route without passing `/auth` redirect.
**Cause:** By design — only listed policies get `AppRouteAuthGate`.
**Fix:** Expand `AppRoutePolicies` when adding sensitive routes; defensive cubit handling.
**Proof:** Documented gap in [`authentication.md`](authentication.md) § Notable Gaps

---

## FN-14 — Pre-commit without mutation guard

**Symptom:** AP-05 regressions merged before CI.
**Cause:** Guard existed but not in default pre-commit path for all contributors.
**Fix:** `githooks/pre-commit` + `bin/install-git-hooks`; regression in `check_regression_guards.sh`.
**Proof:** [`docs/changes/2026-06-15_mutation-success-guard.md`](changes/2026-06-15_mutation-success-guard.md)

---

## FN-15 — `system_design_showcase` scope creep

**Symptom:** Risk of merging long showcase body into architecture hub.
**Cause:** Interview doc grew independently of thin entry hubs.
**Fix:** **Link-only** from [`architecture.md`](architecture.md) and audit evidence table.
**Proof:** Wave 1 hub policy; ADR-0005 frozen spine
