# Android Play Store Release SOP

This runbook documents the required commands, environment, and manual Play Console
steps for releasing **BlocFlutter** to Google Play.

## 1) Local prerequisites

- Android emulator running and reachable as `emulator-5554`.
- Release keystore exists and is wired via `android/key.properties`.
- Local release env file exists as `.env.android.release` (copy from tracked
  [`.env.android.release.example`](../.env.android.release.example); gitignored
  real file must not be committed).
- Fastlane is installed (`fastlane --version`).

`./tool/release_android_play.sh` sources `.env.android.release` before Fastlane;
the Android build uses [`tool/flutter_dart_defines_from_env.sh`](../tool/flutter_dart_defines_from_env.sh),
so the same optional compile-time keys as local dev (for example
`CHAT_FASTAPICLOUD_*` / legacy `CHAT_RENDER_*`) can be set there—see
[`docs/integrations/render_fastapi_chat_demo.md`](integrations/render_fastapi_chat_demo.md).

## 2) Mandatory validation gates

Run these in order:

```bash
CHECKLIST_INTEGRATION_DEVICE=emulator-5554 ./bin/checklist
CHECKLIST_INTEGRATION_DEVICE=emulator-5554 ./bin/integration_tests
./tool/release_android_play.sh preflight
```

Do not proceed to upload until all three are green.

## 3) Build and upload

```bash
./tool/release_android_play.sh upload_internal
```

Notes:

- `./tool/release_android_play.sh` runs Fastlane lanes. Build number bumping is
  handled **once** inside Fastlane (so uploads don’t double-increment).

If metadata is updated in this release:

```bash
./tool/release_android_play.sh metadata_sync
```

## 4) Promotion flow

Promote only after internal validation is successful:

```bash
./tool/release_android_play.sh promote_track
```

Default promotion env values are controlled by `.env.android.release`.

## 5) Play Console manual steps (required)

- Create/verify app record for package id in `ANDROID_PACKAGE_NAME`.
- Complete store listing text/images/screenshots.
- Complete Data safety, content rating, app access, ads declaration, and privacy
  policy URL.
- Add internal testers and validate install/update path.

## 6) Versioning notes

- This repo uses Flutter's standard `pubspec.yaml` version format `x.y.z+N`.
- **Play Store / iOS marketing version** is `x.y.z` (e.g. `1.0.0`).
- **Build number** is `N` (Android `versionCode`, iOS `CFBundleVersion`) and must
  monotonically increase for each upload.

## 7) Go/No-Go criteria

- Checklist pass.
- Integration test pass on the target Android emulator.
- Upload preflight pass.
- Internal upload pass and release visible on Play Internal track.
- No critical/high blockers from tester feedback.

## 8) Rollback

- Keep the previous known-good production release in Play.
- For production issues, halt rollout in Play Console immediately.
- Prepare a hotfix with incremented build number and re-run full gates.
