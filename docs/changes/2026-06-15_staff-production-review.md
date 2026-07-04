# Staff+ production review (2026-06-15)

Point-in-time note for the seven-item remediation pass and judgement docs. Full audit (git-tracked): [`docs/audits/staff_production_review_2026-06-15.md`](../audits/staff_production_review_2026-06-15.md) — scores, evidence table, follow-ups.

## Why

Interview/portfolio repo needed a bounded staff review: modular monolith proof, spine test signal, agent doc hubs, and durable failure/anti-pattern judgement—without scope creep (no DI split, no demo removal).

## What changed

### Code / tests

- **R1:** Success-path cubit tests for `AdminCubit`, `MessagingCubit`, `ClientBookingCubit`
- **R2:** `chat_remote_failure_mapper.dart` barrel re-export seam (AP-04)
- **R3:** `graphql_demo` cubit moved to `presentation/cubit/`
- **R6:** `RemoteBackendAuthPort` — chat no longer imports `supabase_auth/domain`
- **R7:** `spine_counter_reference` golden

### Docs

- Thin hubs: [`architecture.md`](../architecture.md), [`testing.md`](../testing.md), [`engineering-decisions.md`](../engineering-decisions.md), [`ai-workflow.md`](../ai-workflow.md)
- Canonical [`flutter-anti-patterns.md`](../flutter-anti-patterns.md), [`failure-notebook.md`](../failure-notebook.md)
- Stub [`ai/reports/anti_patterns.md`](../../ai/reports/anti_patterns.md)
- Auth roles table + settings `publicRoute` correction in [`authentication.md`](../authentication.md)

### Audits

- **R5:** Route auth audit — no router code change; settings public by policy

## Proof

```bash
# Structure / guards
bash tool/modular_metrics.sh --cross-feature-only   # no cross-feature edges
bash tool/check_mutation_success_after_guard.sh     # pass
bash tool/check_feature_modularity_leaks.sh         # pass
bash tool/check_clean_architecture_imports.sh       # pass

# Behavior (R1–R7)
flutter test test/features/online_therapy_demo/presentation/cubit/ test/features/chat/ \
  test/app/router/app_route_auth_gate_test.dart test/features/graphql_demo/ \
  test/graphql_demo_page_test.dart test/counter_page_golden_test.dart
# 240 passed (includes spine golden)

# Static analysis (touched paths)
flutter analyze --fatal-infos apps/mobile/lib/features/chat apps/mobile/lib/features/graphql_demo apps/mobile/lib/core/auth \
  apps/mobile/lib/features/supabase_auth/domain/supabase_auth_repository.dart \
  test/features/online_therapy_demo/presentation/cubit test/features/chat \
  test/features/graphql_demo test/counter_page_golden_test.dart
# No issues found

# Full analyzer wrapper
bash tool/analyze.sh
# flutter analyze + mix_lint + file_length_lint complete

# Delivery lane
./bin/checklist
# All steps passed; full test suite 2377 passed / 4 skipped; coverage 72.12%
```

## Showcase

[`system_design_showcase.md`](../system_design_showcase.md) remains **link-only** from architecture hub and audit evidence—not merged into hub body.
