# Therapy booking: success when reload superseded

**Date:** 2026-06-15

## Summary

- **`ClientBookingCubit.createAppointmentFromSlot`**: After a successful `createAppointment`, return `true` when `RequestIdGuard` is superseded during post-create availability/appointments reload — not only during the write (fixed in PR #328).
- Avoids confirm screen staying open after a persisted booking and duplicate booking attempts.

## Verification

```bash
flutter test test/features/online_therapy_demo/edge_cases_test.dart --name "createAppointmentFromSlot reports success when superseded"
```
