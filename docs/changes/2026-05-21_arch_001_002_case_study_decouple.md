# ARCH-001 / ARCH-002 — case study decouple and cubit split

**Date:** 2026-05-21  
**Shipped:** [PR #240](https://github.com/redjadet/flutter_bloc_app/pull/240) squash-merged to `main` (`c703b9b5`)  
**Plan:** [`docs/plans/2026-05-21_ai_first_engineering_plan.md`](../plans/2026-05-21_ai_first_engineering_plan.md) post-merge follow-up

## Goal

Close audit items ARCH-001 and ARCH-002 for `case_study_demo` without changing user-visible behavior.

## ARCH-001

- Move media pick types to `apps/mobile/lib/shared/media/`.
- Introduce `RemoteBackendAuthPort` in `apps/mobile/lib/core/auth/`; wire `SupabaseAuthRepository` + DI.
- Remove cross-feature domain imports from `case_study_demo`.

## ARCH-002

- Delete `case_study_session_cubit_actions.part.dart`.
- Add wizard / lifecycle / history / submit mixins; submit mixin `on` history for local persist helper.

## Verify

```bash
flutter test test/features/case_study_demo test/features/camera_gallery
bash tool/modular_metrics.sh --cross-feature-only
dart analyze apps/mobile/lib/features/case_study_demo/presentation/cubit/
```

Report: [`ai/reports/FINAL_OPTIMIZATION_REPORT.md`](../../ai/reports/FINAL_OPTIMIZATION_REPORT.md).

Delivery automation notes: [`2026-05-21_agent_automated_delivery_loop.md`](2026-05-21_agent_automated_delivery_loop.md).
