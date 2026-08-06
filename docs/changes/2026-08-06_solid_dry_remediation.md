# SOLID/DRY remediation — 2026-08-06

## Summary

Focused B-then-D wave: remove `staff_app_demo` domain `Map<String, dynamic>`
contracts, correct DRY inventory (one real `ViewStatusSwitcher` adoption), then
add a warn-only domain Map-bag checker with a reviewed three-symbol baseline.

## Scope

- **B1:** Typed `StaffDemoInboxMessage`; `loadMessage` no longer returns a Map.
- **B2:** Drop `payload` from `StaffDemoOpenEntrySnapshot` and Hive open-entry
  records; keep punch evidence on queued `SyncOperation` only.
- **B3:** Document search/todo decoration exceptions; close stale DRY rows.
- **B4:** Todo list body uses `ViewStatusSwitcher` with custom retry `errorBuilder`.
- **D1:** `tool/check_domain_map_bags.sh` (warn-only) + fixtures + checklist wiring.
- **D2:** AP-18, senior audit P3→G for staff_app_demo, architecture checklist,
  `reference_features` Do-not-copy update.

## Non-goals

- Sealed-state migrations for therapy / `ai_decision_demo` presentation state.
- Forced `buildCommonInputDecoration` on search/todo fields.
- Fail-flipping the new Map-bag gate.

## Locked behavior

- Inbox mapper: null document → null message; malformed optional fields → null
  field (Cubit still defaults body/type to `''`).
- Open-entry: clock-out uses identity/metadata only; sync payload unchanged.
- Map allowlist after B2: `RemoteConfigSnapshot.values`,
  `AiDecisionProof.inputSnapshot`, `AiDecisionProof.extras`.

## Rollback

`git revert` of this wave. No Hive destructive migration; historical `payload`
keys remain unread after B2.

## Validation

Proof captured 2026-08-06:

- `./bin/format`
- `bash tool/check_clean_architecture_imports.sh --paths apps/mobile/lib/features/staff_app_demo`
- `bash tool/check_feature_folder_contract.sh --paths apps/mobile/lib/features/staff_app_demo`
- `bash tool/check_domain_map_bags.sh` → `violations=0`
- `bash tool/run_harness_fixtures.sh` (domain Map good/bad/baseline/malformed)
- `./bin/checklist` (full; coverage 85.16%; app-shell 75.52%)
- `INTEGRATION_TESTS_RUN_COVERAGE=0 ./bin/integration_tests`
  (log-filter + Chrome web bootstrap + iPhone 17 Pro `all_flows_test` 29 passed)
- `./bin/agent-maintain closeout`

Targeted tests (also covered by checklist):

```bash
cd apps/mobile && flutter test \
  test/features/staff_app_demo/data/staff_demo_inbox_firestore_map_test.dart \
  test/features/staff_app_demo/presentation/cubit/staff_demo_messages_cubit_test.dart \
  test/features/staff_app_demo/data/offline_first_staff_demo_timeclock_repository_test.dart \
  test/features/staff_app_demo/presentation/cubit/staff_demo_timeclock_cubit_test.dart \
  test/features/todo_list/presentation/pages/todo_list_page_test.dart \
  test/app/composition/register_remaining_demo_services_test.dart
```
