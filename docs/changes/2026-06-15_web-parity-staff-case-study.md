# Web parity — staff app demo + case study demo

## Feature: staff_app_demo, case_study_demo (web)

### Problem

Staff proof upload and case-study clip playback were iOS/Android-only stubs on web;
example hub hid profile/wallet on web.

### Scope

- In: Full DI on web, clip/proof file stores (io/web), video blob playback, transient
  submit errors, GoRouter web shell routing (`rootNavigatorKey`, shell routes at end of
  route list), example hub + WebSocket demo web parity, clean-arch layer fixes, tests.
- Out: FCM/isolates/native FFI, demo barrel split, `AppRoutePolicies` expansion.

### Layers touched

- [x] domain (`case_study_video_mime`, `case_study_clip_bytes_memory`, proof exceptions)
- [x] data (conditional clip/proof stores, Supabase MIME)
- [x] presentation (video tile lifecycle, hub visibility)
- [x] DI (removed web stub registrars)
- [x] routes (removed web-only route shims; `app_navigator_keys.dart`)

### Tests

- Staff/case-study unit + widget tests; `web_bootstrap_smoke_test`; transient error web test.

### Proof

```bash
bash tool/check_feature_brief_linked.sh          # pass
bash tool/check_clean_architecture_imports.sh    # pass
flutter test test/features/staff_app_demo test/features/case_study_demo
# 101 passed
flutter test -d chrome test/integration_preflight/web_bootstrap_smoke_test.dart
# 4 passed (home, native showcase, staff shell, case study home)
./bin/router_feature_validate                    # pass (141 tests)
flutter build web                                # pass (~82s, 2026-06-15)
bash tool/analyze.sh                             # pass (2026-06-15)
```

MIME util test: `test/features/case_study_demo/domain/case_study_video_mime_test.dart` (4 passed).
