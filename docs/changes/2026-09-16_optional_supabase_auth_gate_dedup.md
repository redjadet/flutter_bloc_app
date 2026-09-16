# Optional Supabase auth gate dedup — 2026-09-16

## Summary

Merged near-identical IoT demo and case study Supabase optional-auth gates into
one shared widget under `app/auth/`. Feature wrappers keep existing class names
and public params (`counterPath` / `fallbackPath`). **No auth, routing, or UI
behavior change.**

## Changes

- Added `apps/mobile/lib/app/auth/optional_supabase_auth_gate.dart`
- Thinned `IotDemoAuthGate` and `CaseStudySupabaseAuthGate` to thin wrappers

## Tests

- Existing widget tests:
  - `test/features/iot_demo/presentation/widgets/iot_demo_auth_gate_test.dart`
  - `test/features/case_study_demo/presentation/widgets/case_study_supabase_auth_gate_test.dart`

## Validation

```bash
./bin/format
cd apps/mobile && flutter test \
  test/features/iot_demo/presentation/widgets/iot_demo_auth_gate_test.dart \
  test/features/case_study_demo/presentation/widgets/case_study_supabase_auth_gate_test.dart
./bin/router_feature_validate
bash tool/check_clean_architecture_imports.sh
bash tool/modular_metrics.sh --cross-feature-only
bash tool/check_feature_brief_linked.sh
```
