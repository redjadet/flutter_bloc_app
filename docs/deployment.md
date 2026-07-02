# Deployment and release

This repo prefers **script-first** deployment workflows. Most “how do I ship?”
questions should be answerable by running a repo script, and the docs should
point you to the smallest correct runbook instead of duplicating platform
vendor docs.

For the complete docs index, see [docs index](README.md).

## Canonical routes

| Goal | Primary doc | Primary commands |
| --- | --- | --- |
| **Both stores (one command)** | This doc | `./tool/release_both_stores.sh deploy` |
| iOS App Store / TestFlight | This doc | `./tool/fastlane.sh ios upload_testflight` / `./tool/fastlane.sh ios upload_appstore` |
| Android Google Play | [Android Play Store Release SOP](android_play_store_release_sop.md) | `./tool/release_android_play.sh ...` |
| Pre-release tester distribution | [Firebase App Distribution](firebase_app_distribution.md) | `./tool/fastlane.sh android firebase_distribute` / `./tool/fastlane.sh ios firebase_distribute` |

Fastlane configuration lives in [`fastlane/Fastfile`](../fastlane/Fastfile) at the repo root.
Run lanes through [`tool/fastlane.sh`](../tool/fastlane.sh) (Bundler-pinned) — not the legacy
`ios/fastlane` or `android/fastlane` copies.

### Release scripts

| Script | Use when |
| --- | --- |
| [`tool/release_both_stores.sh`](../tool/release_both_stores.sh) | One command for TestFlight + Play internal (`preflight`, `deploy`, or single-platform `ios` / `android`) |
| [`tool/release_android_play.sh`](../tool/release_android_play.sh) | Android-only Play lanes (sources `.env.android.release`) |
| [`tool/fastlane.sh`](../tool/fastlane.sh) | Direct Fastlane access (`ios …`, `android …`, `deploy_all`, lane index in [`fastlane/README.md`](../fastlane/README.md)) |

Env templates (copy to gitignored files):

| Template | Loaded by |
| --- | --- |
| [`.env.ios.release.example`](../.env.ios.release.example) | `release_both_stores.sh`, manual iOS lanes |
| [`.env.android.release.example`](../.env.android.release.example) | `release_both_stores.sh`, `release_android_play.sh` |

Ruby deps: `bundle install` (see root [`Gemfile`](../Gemfile), Fastlane 2.234.0).

## Both stores (iOS + Android)

Use this when you want **one scripted flow** for TestFlight and Play internal testing
(inspired by [this Fastlane + Flutter walkthrough](https://medium.com/easy-flutter/how-i-set-up-fastlane-for-flutter-to-deploy-to-both-stores-without-touching-a-button-a2dece187483)).

### Setup (one time)

1. Copy env templates (gitignored real files):
   - [`.env.ios.release.example`](../.env.ios.release.example) → `.env.ios.release`
   - [`.env.android.release.example`](../.env.android.release.example) → `.env.android.release`
2. Optional iOS signing with **match**: set `MATCH_GIT_URL` in `.env.ios.release` and copy
   [`fastlane/Matchfile.example`](../fastlane/Matchfile.example) → `fastlane/Matchfile`.
   Use `MATCH_READONLY=true` on CI so machines only sync existing certificates.
3. Play Console: service account JSON at `ANDROID_JSON_KEY` with **Release manager** access.

### Deploy

```bash
bundle install
./tool/release_both_stores.sh preflight
./tool/release_both_stores.sh deploy
```

What `deploy` does:

1. Bumps `pubspec.yaml` build number **once** (shared by both platforms).
2. Runs `ios upload_testflight` (Flutter IPA build + TestFlight upload; optional match sync).
3. Runs `android play_upload_internal` (Flutter AAB + Play **internal** track as **draft**).

Override lanes or tracks via env (`IOS_DEPLOY_LANE`, `ANDROID_DEPLOY_LANE`, `ANDROID_PLAY_TRACK`)
or Fastlane options, for example:

```bash
./tool/fastlane.sh deploy_all ios_lane:upload_appstore android_lane:play_upload_track track:alpha
```

Version numbers always come from `pubspec.yaml` (`x.y.z+N`); Android uploads pass
`version_name` / `version_code` to Play automatically.

### Dual-store validation (recommended)

Before `deploy`, run the same quality gates as the Android SOP, then both-store preflight:

```bash
CHECKLIST_INTEGRATION_DEVICE=emulator-5554 ./bin/checklist
CHECKLIST_INTEGRATION_DEVICE=emulator-5554 ./bin/integration_tests
./tool/release_both_stores.sh preflight
```

Android-only uploads can stop after `./tool/release_android_play.sh preflight` instead.

## iOS (TestFlight and App Store)

### Prerequisites (high level)

- Paid Apple Developer Program membership for distribution.
- Xcode configured with signing.
- Firebase iOS config when using Firebase-dependent features (see
  [Firebase setup](firebase_setup.md)).
- Secrets injected via `--dart-define` / CI (see [Security and secrets](security_and_secrets.md)).

### Recommended: Fastlane (repo wrapper)

Load [`.env.ios.release`](../.env.ios.release.example) (copy from example) or export the same
variables in your shell. For dual-store runs, `release_both_stores.sh` loads both iOS and Android env files.

Run from the repo root:

```bash
bundle install
./tool/fastlane.sh ios preflight
./tool/fastlane.sh ios upload_testflight
./tool/fastlane.sh ios upload_appstore
```

Common iOS lanes (full list: [`fastlane/README.md`](../fastlane/README.md)):

| Lane | Purpose |
| --- | --- |
| `ios preflight` | Validates `FASTLANE_APP_IDENTIFIER` (and Apple ID when required) |
| `ios adhoc` | Build Ad Hoc IPA only (no upload) |
| `ios upload_testflight` | Build IPA + upload to TestFlight |
| `ios upload_appstore` | Build IPA + upload to App Store Connect (no auto-submit for review) |
| `ios firebase_distribute` | Build/upload via Firebase App Distribution |

Notes:

- `./tool/fastlane.sh` is the canonical entrypoint in this repo. It avoids
  Bundler/Ruby drift and keeps CI and local usage aligned.
- [`fastlane/README.md`](../fastlane/README.md) is auto-generated when Fastlane runs. Treat it as a lane index,
  not the primary “how to ship” documentation.
- iOS release notes: set `IOS_RELEASE_NOTES`, or let Fastlane derive them from recent git commits.
- `upload_appstore` uploads to App Store Connect with `submit_for_review: false` by default
  (review in App Store Connect before submitting).
- Optional **match** signing: set `MATCH_GIT_URL` in `.env.ios.release`; copy
  [`fastlane/Matchfile.example`](../fastlane/Matchfile.example) → `fastlane/Matchfile`.
  Use `MATCH_READONLY=true` on CI.

## Android (Google Play)

Follow the runbook:

- [Android Play Store Release SOP](android_play_store_release_sop.md)

That SOP encodes the validation gates and uses `./tool/release_android_play.sh`
to prevent version-code drift and to keep the Play flow repeatable.

Common Android lanes (via `./tool/fastlane.sh android …` or `release_android_play.sh`):

| Lane / script action | Purpose |
| --- | --- |
| `play_preflight` / `preflight` | Service account + required dart-define env |
| `play_build_release` / `build_release` | Flutter AAB only |
| `play_upload_internal` / `upload_internal` | Build + upload to internal track (draft by default) |
| `play_upload_track` / `upload_track` | Build + upload to `ANDROID_PLAY_TRACK` |
| `play_metadata_sync` / `metadata_sync` | Listing metadata from `fastlane/metadata/android/` |
| `play_promote_track` / `promote_track` | Promote between Play tracks |

Listing copy and changelogs: `fastlane/metadata/android/en-US/` (per-build changelog files optional as `changelogs/<build_number>.txt`).

## Firebase App Distribution (pre-release testers)

Use this when you want testers on real devices **before** store submission:

- [Firebase App Distribution](firebase_app_distribution.md)

The doc includes CLI usage, Fastlane lanes, and the iOS upload script (`tool/upload_ios_to_firebase_app_distribution.sh`), which runs `firebase_preflight.sh` and maps tester emails to `--testers` (and group aliases to `--groups`).

## Web (GitHub Pages)

This repo supports deploying Flutter Web to GitHub Pages:

- **Project site** URL shape: `https://<user>.github.io/<repo>/`
- **Evaluated environment URL**: `https://redjadet.github.io/flutter_bloc_app/`
- **Root/custom-domain** hosting: set Flutter `--base-href` to `/`
- **Hash routing** is assumed (URLs like `/#/settings`), so Pages does not need SPA rewrite workarounds.

### One-time GitHub settings (out-of-band)

In GitHub repo settings:

- **Settings → Pages → Build and deployment → Source**: set to **GitHub Actions**.

The workflow now performs a preflight API check before building. If Pages is
not enabled yet, it fails early with this exact setup instruction instead of
continuing to a later deploy failure.

This repo intentionally does **not** try to auto-enable Pages from the workflow.
GitHub's `actions/configure-pages` only supports auto-enable via
`enablement: true` when using a non-`GITHUB_TOKEN` credential with additional
repo/pages administration rights.

### Build locally (deterministic)

Use the repo script (required for correct `--base-href` and consistent dart-defines):

```bash
REPO_NAME="<repo>" bash tool/build_web_github_pages.sh
```

This produces `build/web`.

### Deploy via GitHub Actions (auto on `main`)

Once GitHub Pages is set to **GitHub Actions**, the workflow in
`.github/workflows/deploy_web.yml` runs automatically on **every** `push` to
`main`.

You can still run it manually:

- GitHub → **Actions** → **Deploy web (GitHub Pages)** → **Run workflow**

The workflow uses `cancel-in-progress: false` so a newer `main` push does not
cancel an in-flight Pages deployment. Cancelling after `deploy-pages` submits
can orphan a deployment in `deployment_queued` and block later runs until the
action's 10-minute poll timeout. Before each deploy, the workflow runs
`tool/drain_stale_github_pages_deployments.py` to cancel recent non-terminal
Pages deployments for **other** SHAs (including blank-status queue blockers).
It skips the current commit SHA so a pre-deploy cancel does not block an
immediate redeploy of the same commit. The drain cancels every other recent
Pages deployment that is not `succeed` (including `deployment_cancelled`
entries that still block the queue), paginates through recent environment
deployments, and nudges each blocker once. On retry after a failed deploy, the
script includes the current SHA, waits for a terminal Pages status, then
retries `deploy-pages`. Push deploys also skip when the workflow commit is no
longer the branch tip, so stale queued runs do not fight newer `main` pushes.

#### `base_href` input

- Leave `base_href` empty for project-site deploys (script derives `/${REPO_NAME}/`).
- Set `base_href` to `/` for root/custom-domain hosting.

#### Auto-deploy root/custom-domain

For automatic deploys on `main`, set a GitHub Actions **repository variable**
named `BASE_HREF`:

- `BASE_HREF="/<repo>/"` (project site)
- `BASE_HREF="/"` (root/custom domain)

Workflow uses `inputs.base_href` only for manual runs; for `push` events it
reads `vars.BASE_HREF`.

#### GitHub Actions Node.js runtime deprecation (Node 20 → 24)

GitHub may show annotations about **Node.js 20** deprecation for some JavaScript
actions. This does not fail the workflow today, but the default runtime will
move to **Node.js 24** later (per GitHub’s runner change notices).

Options:

- Do nothing until forced (default).
- Opt-in early (to catch breakage sooner): set workflow env
  `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24=true`.
- If you must temporarily opt-out later: set
  `ACTIONS_ALLOW_USE_UNSECURE_NODE_VERSION=true` (last resort).

### Post-deploy smoke checks

1. Open `https://<user>.github.io/<repo>/`
2. Confirm there are no 404s for `main.dart.js` or assets
3. Navigate to a non-root route (e.g. `/#/settings`) and hard refresh

## iOS entitlements (development vs distribution)

Personal Apple IDs do **not** support **Associated Domains** (universal links).
Switch entitlements via:

```bash
./tool/ios_entitlements.sh development   # local runs on your device (personal Apple ID)
./tool/ios_entitlements.sh distribution  # Ad Hoc/App Store builds (paid account)
```

Templates live under `ios/Runner/`:

- `Runner.entitlements.development`
- `Runner.entitlements.distribution`

## Release preparation (shared)

Before packaging releases, scrub local secrets from any developer-only assets:

```bash
dart run tool/prepare_release.dart
```

## Entry points

- Development: `lib/main_dev.dart`
- Staging: `lib/main_staging.dart`
- Production: `lib/main_prod.dart`

## Related docs

- [Security and secrets](security_and_secrets.md) — release env files and dart-defines
- [Firebase setup](firebase_setup.md)
- [Android Play Store Release SOP](android_play_store_release_sop.md)
- [Firebase App Distribution](firebase_app_distribution.md)
- [Fastlane lane index](../fastlane/README.md) — `deploy_all`, `deploy_all_preflight`, per-platform lanes
