# Security and secrets

This document explains how the app receives secrets in development and CI, and
how local persistence is protected (encrypted Hive + platform secure storage).

For the complete docs index, see [`README.md`](README.md).

If you are reporting a vulnerability, use [`SECURITY.md`](SECURITY.md) (GitHub security
advisories / responsible disclosure). This file is about **configuration and
secret injection**, not vulnerability triage.

## Principles

- **Do not commit secrets**: `.envrc`, API keys, and local secret files must be
  gitignored.
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

`assets/config/secrets.json` is **gitignored** and is intentionally **not
bundled by default**. It exists as a local escape hatch for development and for
scripts that you may want to run without exporting env vars. The repo only ships
`assets/config/secrets.sample.json` as a placeholder reference.

## Local development

### Option A: one-off `--dart-define` flags

```bash
flutter run -t lib/main_dev.dart \
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
flutter run -t lib/main_dev.dart $(./tool/flutter_dart_defines_from_env.sh)
```

If you want iOS builds to use the same values without re-typing flags:

```bash
direnv allow
./tool/build_ios_with_direnv.sh
```

## CI / release builds

CI should inject secrets via the CI system (GitHub Actions secrets, etc.) and
then pass them as `--dart-define` values (or use the same helper script used for
local development). Avoid “production flutter run” guidance: for release builds,
focus on how the build environment supplies keys.

## Firebase configuration is separate

Firebase platform config files are **gitignored** and are not managed through
the secrets system:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`

To enable Firebase-dependent features (Auth, Remote Config, Realtime Database,
etc.), follow [Firebase Setup](firebase_setup.md). The app should still run when
Firebase is not configured; the relevant surfaces disable themselves or degrade
gracefully.

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
- **The encryption key is stored in secure storage** (Keychain/Keystore).
- **Migrations are defensive**: when migrating legacy storage, data is validated
  before it is treated as trusted app state.

## Related docs

- [Authentication](authentication.md)
- [Repository lifecycle](REPOSITORY_LIFECYCLE.md)
- [Clean architecture](clean_architecture.md)
