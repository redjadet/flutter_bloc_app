# Security and secrets

This document explains how the app receives secrets in development and CI, and
how local persistence is protected (encrypted Hive + platform secure storage).

For the complete docs index, see [docs index](README.md).

If you are reporting a vulnerability, use [`SECURITY.md`](SECURITY.md) (GitHub security
advisories / responsible disclosure). This file is about **configuration and
secret injection**, not vulnerability triage.

## Principles

- **Do not commit secrets**: `.envrc`, API keys, and local secret files must be
  gitignored.
- **Do not commit real Firebase config**: keep committed Firebase options and
  CI plist/json files as placeholders. If GitHub secret scanning flags a
  Google API key, rotate or restrict that key in Google Cloud/Firebase, replace
  the committed value with a placeholder, then run
  [`tool/check_tracked_secret_literals.sh`](../tool/check_tracked_secret_literals.sh).
- **Prefer runtime injection**: use `--dart-define` (or a wrapper that produces
  those flags) rather than hardcoding secrets in the repo.
- **Fail safe**: when a key is missing, the owning feature should be disabled
  or fall back to a safe local-only mode.

## Sources (in order)

The app supports layered secret loading:

1. **Secure storage (primary)**: Keychain/Keystore via `flutter_secure_storage`.
2. **Runtime defines**: `--dart-define=KEY=value` values (optionally persisted
   into secure storage by the app’s secret bootstrap).
3. **Local-only asset file (optional)**: `assets/config/secrets.json`.

## Supabase config via Firebase Remote Config

This repo supports obtaining Supabase client configuration from **Firebase Remote Config**
after **Firebase Auth sign-in**, then persisting it into secure storage.

- **Remote Config keys**:
  - `SUPABASE_URL` (string)
  - `SUPABASE_ANON_KEY` (string)
  - `SUPABASE_CONFIG_VERSION` (number, default `1`)
  - `SUPABASE_CONFIG_ENABLED` (bool, default `true`)
- **Important**: Remote Config is **not** a secret store. Treat these as client
  configuration; security must come from Supabase RLS and server-side trust boundaries.
- **Local overrides**: If you inject `SUPABASE_URL` / `SUPABASE_ANON_KEY` via
  `--dart-define`/`.envrc`, Supabase may initialize from those values before the
  Remote Config refresh runs. Disable local injection when validating the Remote
  Config path.

`assets/config/secrets.json` is **gitignored** and is intentionally **not
bundled by default**. It exists as a local escape hatch for development and for
scripts that you may want to run without exporting env vars. The repo only ships
`assets/config/secrets.sample.json` as a placeholder reference.

## Local development

### Option A: one-off `--dart-define` flags

```bash
cd apps/mobile && flutter run -t apps/mobile/lib/main_dev.dart \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=HUGGINGFACE_API_KEY=...
```

### Option B (recommended): `direnv` + `.envrc`

1. Install [`direnv`](https://direnv.net/).
2. Copy [`docs/envrc.example`](envrc.example) to `.envrc` in the repo root.
3. Fill in values and run:

```bash
direnv allow
cd apps/mobile && flutter run -t apps/mobile/lib/main_dev.dart $(../../tool/flutter_dart_defines_from_env.sh)
```

When `.envrc` follows [`docs/envrc.example`](envrc.example) and prepends `tool/direnv/bin` to `PATH`, plain `flutter run` / `flutter build` from the repo root is routed to `apps/mobile` and still receives the same flags: the wrapper calls [`tool/flutter_dart_defines_from_env.sh`](../tool/flutter_dart_defines_from_env.sh), which emits `--dart-define=...` only for **named** environment variables (for example `HUGGINGFACE_API_KEY`, `SUPABASE_*`, and optional orchestration demo keys `CHAT_FASTAPICLOUD_*` (preferred) / legacy `CHAT_RENDER_*`). **New** compile-time keys must be added to that script or they will not reach the app even if exported in `.envrc`. Orchestration demo wiring is summarized in [`docs/integrations/render_fastapi_chat_demo.md`](integrations/render_fastapi_chat_demo.md). **`RENDER_API_KEY`** stays shell-only (for example `.envrc`); use it for Render REST, Cursor MCP, or [`tool/trigger_render_chat_api_deploy.sh`](../tool/trigger_render_chat_api_deploy.sh)—never as a Flutter `dart-define` or Remote Config parameter.

If you want iOS builds to use the same values without re-typing flags:

```bash
direnv allow
./tool/build_ios_with_direnv.sh
```

### Before local debug

When VS Code/Cursor automatic tasks are allowed, `.vscode/tasks.json` runs
`tool/local_ide_open_preflight.sh` on folder open. It loads approved `direnv`
values into that task process, refreshes packages only when needed, lists
forwarded key names without values, and runs the tracked-secret guard. It cannot
approve `.envrc`; run `direnv allow` once after editing local secrets.

Use this pre-debug checklist when a feature depends on local secrets:

1. Run `direnv allow` from the repo root after editing `.envrc`; use
   `direnv reload` or open a new terminal if the current shell did not refresh.
2. List forwarded `--dart-define` key names without values:
   `./tool/flutter_dart_defines_from_env.sh | tr ' ' '\n' | sed -n 's/^--dart-define=\([^=]*\)=.*/\1/p'`.
3. If a needed key is missing from that list, add it to
   [`tool/flutter_dart_defines_from_env.sh`](../tool/flutter_dart_defines_from_env.sh)
   and [`envrc.example`](envrc.example) before relying on `.envrc`.
4. Run [`tool/check_tracked_secret_literals.sh`](../tool/check_tracked_secret_literals.sh)
   before committing or pushing. It checks that local `secrets.json` paths stay
   gitignored and scans tracked files for secret-looking literals.
5. Never paste real values into issue comments, logs, screenshots, or docs;
   refer to env var names only.

## CI / release builds

CI should inject secrets via the CI system (GitHub Actions secrets, etc.) and
then pass them as `--dart-define` values (or use the same helper script used for
local development). Avoid “production flutter run” guidance: for release builds,
focus on how the build environment supplies keys.

For **store release** uploads from a maintainer machine:

| Env file (gitignored) | Template | Used by |
| --- | --- | --- |
| `.env.android.release` | [`.env.android.release.example`](../.env.android.release.example) | [`tool/release_android_play.sh`](../tool/release_android_play.sh), [`tool/release_both_stores.sh`](../tool/release_both_stores.sh) |
| `.env.ios.release` | [`.env.ios.release.example`](../.env.ios.release.example) | [`tool/release_both_stores.sh`](../tool/release_both_stores.sh), manual `./tool/fastlane.sh ios …` |

Both wrappers source the env files before Fastlane. Android (and dual-store) builds use the same
[`tool/flutter_dart_defines_from_env.sh`](../tool/flutter_dart_defines_from_env.sh)
as Option B, so optional `CHAT_FASTAPICLOUD_*` / `CHAT_RENDER_*` compile-time
keys work the same way as in `.envrc`.

- Android-only: [`tool/release_android_play.sh`](../tool/release_android_play.sh) — see [Android Play Store release SOP](android_play_store_release_sop.md).
- iOS + Android: [`tool/release_both_stores.sh`](../tool/release_both_stores.sh) — see [Deployment](deployment.md#both-stores-ios--android).

Keep Play service account JSON (`ANDROID_JSON_KEY`) and match certificate repos
out of git. Optional match config: [`fastlane/Matchfile.example`](../fastlane/Matchfile.example).

## Firebase configuration is separate

Firebase config is split between **gitignored platform files** and a
**committed Dart placeholder**:

| Artifact | In git | Template | Real values |
| --- | --- | --- | --- |
| `apps/mobile/android/app/google-services.json` | gitignored | [`android/app/google-services.json.sample`](../apps/mobile/android/app/google-services.json.sample) | Local / CI secret injection |
| `apps/mobile/ios/Runner/GoogleService-Info.plist` | gitignored | [`ios/Runner/GoogleService-Info.plist.sample`](../apps/mobile/ios/Runner/GoogleService-Info.plist.sample) | Local / CI secret injection |
| `apps/other_platforms/macos/Runner/GoogleService-Info.plist` | gitignored | [`apps/other_platforms/macos/Runner/GoogleService-Info.plist.sample`](../apps/other_platforms/macos/Runner/GoogleService-Info.plist.sample) | Local / CI secret injection |
| `firebase.json` | gitignored | [`firebase.json.example`](../firebase.json.example) | Local / CI project selection |
| [`apps/mobile/lib/firebase_options.dart`](../apps/mobile/lib/firebase_options.dart) | committed placeholder | n/a | `FIREBASE_*` via `--dart-define` (`.envrc` + direnv) |
| `.envrc` | gitignored | [`docs/envrc.example`](envrc.example) | Maintainer machine only |
| `assets/config/secrets.json` | gitignored | [`assets/config/secrets.sample.json`](../assets/config/secrets.sample.json) | Optional local asset fallback |

To enable Firebase-dependent features (Auth, Remote Config, Realtime Database,
etc.), follow [Firebase Setup](firebase_setup.md). The app should still run when
Firebase is not configured; the relevant surfaces disable themselves or degrade
gracefully.

Fresh checkouts should build without copying any gitignored Firebase files. If a
platform build starts requiring one of those local files, either make that build
step optional or add a tracked placeholder template before relying on the local
file.

Tracked placeholder files such as [`apps/mobile/lib/firebase_options.dart`](../apps/mobile/lib/firebase_options.dart)
and `ios/ci` / `macos/ci` plist files must not contain real API keys. CI uses
them only as build placeholders; maintainer machines and deployment pipelines
should supply real Firebase config through gitignored platform files or
`FIREBASE_*` injection. For local development, add `FIREBASE_*` values to
`.envrc`; the direnv Flutter wrapper forwards them through
[`tool/flutter_dart_defines_from_env.sh`](../tool/flutter_dart_defines_from_env.sh).
When those values are missing or still placeholders, Firebase initialization
skips safely and logs only field names, not secret values.

After `flutterfire configure`, restore the committed Dart placeholder (`git
checkout HEAD -- apps/mobile/lib/firebase_options.dart`) and copy keys into `.envrc` — do
not commit hardcoded API keys from the CLI output.

### Git history and secret scanning

[`tool/check_tracked_secret_literals.sh`](../tool/check_tracked_secret_literals.sh)
guards the **current** tree. GitHub [secret scanning](https://github.com/redjadet/flutter_bloc_app/security/secret-scanning)
can still flag keys in **old commits**. If keys were ever pushed:

1. Rotate restricted keys in Google Cloud/Firebase.
2. Confirm `main` has no `AIzaSy…` literals (`./tool/check_tracked_secret_literals.sh`).
3. Optionally rewrite history with
   [`tool/firebase_secret_history_replacements.txt`](../tool/firebase_secret_history_replacements.txt)
   and `git filter-repo` (see [Secret scanning alerts](firebase_setup.md#secret-scanning-alerts) in Firebase Setup).
4. Force-push all branches and have collaborators re-clone.

## Key inventory (feature-scoped)

| Key | Used by | Notes |
| --- | --- | --- |
| `HUGGINGFACE_API_KEY` | Chat (optional in proxy-first setups) | **Direct path:** `HuggingfaceChatRepository` calls Hugging Face from the app when this key is set and the composite allows direct inference. **Proxy path:** completions run on Supabase Edge `chat-complete`, which holds the server-side HF secret (`HUGGINGFACE_API_KEY` / router access for the function); the app sends the user JWT + anon key only. A client key is still useful for **online fallback** when Edge returns retryable transport errors and for **offline-only** sends when there is no session. Proxy-only product builds may omit the client key; see [`docs/plans/supabase_proxy_huggingface_chat_plan.md`](plans/supabase_proxy_huggingface_chat_plan.md). |
| `GEMINI_API_KEY` (or `GOOGLE_API_KEY`) | GenUI demo | Key creation: [Google AI Studio](https://makersuite.google.com/app/apikey). |
| `SUPABASE_URL`, `SUPABASE_ANON_KEY` | Supabase-backed demos | Enables Supabase client bootstrap; some demos fall back to local-only mode when missing. See [Supabase README](../supabase/README.md). |
| Google Maps keys | Maps demos | Platform-specific; keep in each platform’s secure configuration. |

## Local persistence encryption

- **Hive boxes are encrypted** using `HiveAesCipher` with a 32-byte (256-bit)
  key.
- **The encryption key is stored in secure storage** (Keychain/Keystore) in
  **release** builds.
- **Apple debug (iOS simulator + macOS desktop, non-web)**: Keychain is not
  reliable without entitlements; the app uses in-memory secret storage and a
  stable debug-only encryption key, with Hive roots under `hive_ios_debug` /
  `hive_macos_debug`. Symptom triage and verification:
  [`engineering/apple_debug_hive_storage.md`](engineering/apple_debug_hive_storage.md).
  Regression guard: `bash tool/check_apple_debug_hive_storage.sh`.
- **Migrations are defensive**: when migrating legacy storage, data is validated
  before it is treated as trusted app state.

## Related docs

- [Authentication](authentication.md)
- [Repository lifecycle](REPOSITORY_LIFECYCLE.md)
- [Clean architecture](clean_architecture.md)
- [Apple debug Hive and secret storage](engineering/apple_debug_hive_storage.md)
