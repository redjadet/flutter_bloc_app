# Therapy cubit guards + Hive counter watch restart

**Date:** 2026-06-11

## Summary

- **`HiveCounterRepository` watch**: On box watch stream error, schedule delayed restart when listeners remain; clear restart flag on cancel/dispose (`hive_counter_repository_watch_helper.dart`, `hive_counter_repository_watch_state.dart`).
- **`ClientBookingCubit`**: `RequestIdGuard` stale-request handling; empty-id guards for `selectTherapist`, `loadAvailability`, `cancelAppointment`; loaders moved to `client_booking_cubit_loaders.part.dart` (file-length lint).
- **`MessagingCubit`**: Stale-request handling; `selectConversation('')` clears without busy; empty-id no-op on retry.
- **UI**: Confirm page and shell client part aligned with cubit guard behavior.
- **Tests**: `edge_cases_test.dart`, `cubit_error_handling_test.dart`, `online_therapy_demo_client_booking_confirm_page_test.dart`, `hive_counter_repository_test.dart`.

## Verification

```bash
./tool/analyze.sh
flutter test test/features/online_therapy_demo/
flutter test test/hive_counter_repository_test.dart
bash tool/check_feature_brief_linked.sh --base origin/main
```
