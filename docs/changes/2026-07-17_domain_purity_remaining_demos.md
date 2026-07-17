# Domain purity — remaining demo slices (2026-07-17)

## Scope

Cleared remaining domain wire `fromJson`/`toJson` (and case_study encode/decode) after Wave B:

| Feature | Domain change | Data DTO / notes |
| --- | --- | --- |
| case_study_demo | Stripped JSON + encode/decode from draft/record | `case_study_draft_dto.dart`, `case_study_record_dto.dart` |
| chart | Removed Freezed JSON + `fromApi` | `chart_point_dto.dart` |
| igaming_demo | Removed unused Freezed JSON | No DTO (no call sites) |
| iot_demo | Removed Freezed JSON | `iot_device_dto.dart` |
| search | Removed Freezed JSON | `search_result_dto.dart` |
| staff_app_demo | Removed `toJson`; UI uses `asMap` | `staff_demo_time_entry_flags_dto.dart` |

## Evidence

- `bash tool/check_domain_wire_leaks.sh` — **31 → 0**
- Focused tests (case_study codec/hive, chart, search, iot, igaming, staff domain) — **186 passed**
- Feature folder contract — pass
- `./bin/format --changed`

## Follow-up

Domain wire-leak warn backlog closed. Presentation splits (Wave C) still deferred.
