# 2026-08-24 — upgrade validate (go_router / freezed / FCM)

## Why

Major `flutter pub upgrade` after merging green Renovate PRs. Firebase
Messaging 16.6 adds `AuthorizationStatus.deniedPermanently`, which broke an
exhaustive switch in the FCM demo repository.

## Scope

- Constraints: `freezed` ^4 (mobile + shared packages). `go_router` stays on
  `^17.5.0` — major 18 fails integration with `InheritedGoRouter` deactivate
  assertions (`_dependents.isEmpty`) and cascading missing route providers.
- Lockfile refresh for Firebase and transitive updates.
- Map `deniedPermanently` → `FcmPermissionState.denied`; skip OS re-prompt
  (Android 13+ permanent denial). Same gate in staff demo push-token register.
- Regression test for permanent-denial skip-prompt path.
- Integration harness: adaptive page-back for social feed; todo batch-complete
  avoids ambiguous `more_vert` / duplicate "Complete selected" targets.

## Out of scope

- Domain enum expansion for a distinct permanent-denial state.
- `go_router` 18 adoption (needs dedicated router/shell dispose investigation).
  Re-confirmed blocked 2026-08-31 — see
  [2026-08-31 pub upgrade defer](2026-08-31_pub_upgrade_flex_color_picker_go_router_defer.md).
- Unrelated Renovate Android Gradle plugin PRs opened after triage.

## Proof

- `flutter test test/features/fcm_demo/data/firebase_messaging_repository_test.dart`
- Unit coverage via checklist Step 5: 2907 passed (85.3%)
- `./bin/integration_tests` green after:
  - pin `go_router` ^17.5.0 (18 dispose assertions)
  - social-feed `pageBack` → adaptive `_pageBack`
  - todo batch-complete prefers in-body bar / disambiguates overflow
- `SKIP_PUB_UPGRADE=1 SYNC_AGENT_ASSETS=skip ./bin/upgrade_validate_all`
  (checklist + coverage + integration path)
