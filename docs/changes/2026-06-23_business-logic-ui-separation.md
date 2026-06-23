# Business Logic / UI Separation

**Date:** 2026-06-23

## Summary

- Moved derived presentation logic out of widgets/pages and into state getters:
  IAP product groups, therapy therapist lookup/filtering, staff flagged entries,
  and todo counts.
- Moved staff shift-assignment repository/default-window work behind
  `StaffDemoMessagesCubit`; default schedule math now lives in pure domain
  helpers.
- Extracted reusable relative-time formatting from the chat contact tile and
  added small helper tests.
- Added agent-facing guidance so future reviews flag business filtering,
  aggregation, lookup-by-id, default workflow windows, and repository calls in
  UI surfaces.

## Verification

```bash
flutter test test/features/staff_app_demo/domain/staff_demo_schedule_helpers_test.dart test/shared/utils/relative_time_formatting_test.dart
flutter test test/features/staff_app_demo/presentation/pages/staff_app_demo_happy_path_widget_test.dart
bash tool/check_clean_architecture_imports.sh
bash tool/check_solid_presentation_data_imports.sh
bash tool/check_direct_getit.sh
bash tool/check_feature_folder_contract.sh
bash tool/analyze.sh
./bin/checklist
```
