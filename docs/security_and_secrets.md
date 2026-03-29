# Security & Secrets

This document describes the security architecture and secrets management approach used in this application.

## Secrets Management

The app uses a secure, layered approach to secrets:

1. **Secure Storage** (Primary) - Keychain/Keystore via `flutter_secure_storage`
2. **Environment Variables** - `--dart-define` flags (persisted to secure storage)

**Note:** `assets/config/secrets.json` is **not bundled** into the app by default (to keep CI and releases from depending on a local dev-only file). Prefer `--dart-define`, secure storage, or `direnv`-backed build scripts.

## Setup for Development

```bash
# Option A: One-off (explicit dart-defines)
flutter run \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=HUGGINGFACE_API_KEY=...

# Option B: Recommended local dev (direnv)
direnv allow

# shellcheck disable=SC2046
flutter run $(./tool/flutter_dart_defines_from_env.sh)
```

## Production Setup

```bash
# Use environment variables (recommended)
flutter run \
  --dart-define=HUGGINGFACE_API_KEY=your_key \
  --dart-define=HUGGINGFACE_MODEL=openai/gpt-oss-20b \
  --dart-define=GEMINI_API_KEY=your_gemini_key

# Or inject via CI/CD secrets
```

## iOS builds with `direnv` (automatic secrets injection)

If you keep local secrets in `.envrc` (gitignored) and use `direnv`, you can build iOS with the same values without manually copying/pasting `--dart-define` flags:

```bash
direnv allow

./tool/build_ios_with_direnv.sh
```

## Optional: `flutter run` / `flutter build` without typing flags

Copy **[`docs/envrc.example`](envrc.example)** to the repo root as `.envrc`, fill in placeholders, then `direnv allow`.

The example prepends `tool/direnv/bin` to `PATH`, which provides a lightweight `flutter` wrapper that injects `--dart-define=...` **after the Flutter subcommand** (e.g. `flutter run --dart-define=...`). This is required because `--dart-define` is not a global Flutter flag.

If you prefer not to wrap `flutter`, use:

```bash
flutter run $(./tool/flutter_dart_defines_from_env.sh) -t lib/main_dev.dart
```

## Firebase configuration (separate from secrets)

Firebase config files (`google-services.json`, `GoogleService-Info.plist`, `lib/firebase_options.dart`) are **gitignored** and are **not** managed via `secrets.json`. To run the app with Firebase (Auth, Remote Config, Realtime Database, etc.), follow **[Firebase Setup](firebase_setup.md)**. The app runs without them; Firebase-dependent features are then disabled or fall back gracefully.

## Required API Keys

The following API keys are required for specific features:

- **Hugging Face API Key** (`HUGGINGFACE_API_KEY`): Required for the Chat feature
- **Google Gemini API Key** (`GEMINI_API_KEY`): Required for the GenUI Demo feature
  - Get your API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
  - Can also be provided via `GOOGLE_API_KEY` as a fallback
- **Google Maps API Keys**: Required for Maps feature (Android/iOS platform-specific)
- **Supabase**: `SUPABASE_URL` and `SUPABASE_ANON_KEY` for Supabase-backed features (IoT demo backend) and the optional Supabase Auth page (Settings → Integrations → Supabase Auth). When set, the app initializes the Supabase client at bootstrap. When missing, the auth page shows "not configured"; the IoT demo runs in local-only mode (no remote sync). See `secrets.sample.json` for keys; [Supabase migrations](../supabase/README.md) for schema setup; [Authentication](authentication.md#supabase-auth-optional-separate-page) for auth behavior.

**Important**: Never commit `.envrc` or any secret file. The repo includes only `assets/config/secrets.sample.json`.

## Encryption

- **Storage**: AES-256 encryption for all Hive boxes
- **Key Management**: Keys stored in platform keychain/keystore
- **Migration**: Automatic migration from SharedPreferences with data validation

## Related Documentation

- Authentication flow: `docs/authentication.md`
- Hive storage: `docs/REPOSITORY_LIFECYCLE.md`
- Clean architecture: `docs/clean_architecture.md`
