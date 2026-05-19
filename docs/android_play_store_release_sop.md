# Android Play Store Release SOP

This runbook documents the required commands, environment, and manual Play Console
steps for releasing **BlocFlutter** to Google Play.

Canonical Fastlane config: [`fastlane/Fastfile`](../fastlane/Fastfile) at the repo root
(invoke via [`tool/fastlane.sh`](../tool/fastlane.sh) or the wrappers below). Legacy
`android/fastlane/` is a stub only.

## 1) Local prerequisites

- Android emulator running and reachable as `emulator-5554`.
- Release keystore exists and is wired via `android/key.properties`.
- Local release env file exists as `.env.android.release` (copy from tracked
  [`.env.android.release.example`](../.env.android.release.example); gitignored
  real file must not be committed).
- Ruby Bundler + Fastlane via repo [`Gemfile`](../Gemfile): `bundle install` from repo root.
- Optional: `fastlane --version` (system install not required when using `bundle exec` through `tool/fastlane.sh`).

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

For **both stores** in one release, use the same checklist/integration gates, then:

```bash
./tool/release_both_stores.sh preflight
```

(`deploy_all_preflight` in Fastlane checks Android + iOS env.)

## 3) Build and upload

Android-only:

```bash
./tool/release_android_play.sh upload_internal
```

Both stores (shared `pubspec.yaml` build number bump once, then iOS TestFlight + Play internal):

```bash
./tool/release_both_stores.sh deploy
```

See [Deployment – Both stores](deployment.md#both-stores-ios--android).

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

### Fastlane actions (Android-only wrapper)

| `./tool/release_android_play.sh` action | Fastlane lane |
| --- | --- |
| `preflight` | `android play_preflight` |
| `build_release` | `android play_build_release` |
| `metadata_sync` | `android play_metadata_sync` |
| `upload_internal` | `android play_upload_internal` |
| `upload_track` | `android play_upload_track` (pass `track:…` if needed) |
| `promote_track` | `android play_promote_track` |

Direct lane access: `./tool/fastlane.sh android <lane>`. See [Deployment](deployment.md) and [`fastlane/README.md`](../fastlane/README.md).

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
