# Production readiness consent hardening (2026-07-31)

## Summary

Follow-up to the production-readiness walkthrough: close the Firebase Analytics
collection window before consent DI, sync Settings ↔ demo consent toggles,
surface FCM stream errors, skip redundant OS permission prompts, and move the
12-minute ownership walk into `docs/interview_showcase.md` §3b (README pointer
only).

## Touched areas

- `apps/mobile/lib/app/analytics/` — consent `changes` stream + gateway logging
- `apps/mobile/lib/app/bootstrap/` — disable Analytics after Firebase init
- Android / iOS manifests — collection default off
- `apps/mobile/lib/features/production_readiness/` — consent sync part, error banner
- `apps/mobile/lib/features/fcm_demo/data/firebase_messaging_repository.dart` —
  skip re-prompt when OS already decided
- `apps/mobile/lib/features/settings/.../analytics_consent_section.dart`
- Docs: ADR 0005/0006, observability, interview showcase §3b

## Related

- Feature brief: [2026-07-31_production_readiness_feature_brief.md](2026-07-31_production_readiness_feature_brief.md)
- Case study: [2026-07-31_production_readiness_case_study.md](2026-07-31_production_readiness_case_study.md)
- PR: consent hardening / review follow-up
