# Security & Secrets

This document describes the security architecture and secrets management approach used in this application.

## Secrets Management

The app uses a secure, layered approach to secrets:

1. **Secure Storage** (Primary) - Keychain/Keystore via `flutter_secure_storage`
2. **Environment Variables** - `--dart-define` flags (persisted to secure storage)
3. **Asset Fallback** (Dev Only) - `assets/config/secrets.json` (opt-in, never in release)

## Setup for Development

```bash
# Copy sample secrets file
cp assets/config/secrets.sample.json assets/config/secrets.json

# Fill in your credentials, then run with asset fallback enabled
flutter run --dart-define=ENABLE_ASSET_SECRETS=true
```

## Production Setup

```bash
# Use environment variables (recommended)
flutter run \
  --dart-define=HUGGINGFACE_API_KEY=your_key \
  --dart-define=HUGGINGFACE_MODEL=openai/gpt-oss-20b

# Or inject via CI/CD secrets
```

**Important**: Never commit `assets/config/secrets.json`. The repo includes only `secrets.sample.json`.

## Encryption

- **Storage**: AES-256 encryption for all Hive boxes
- **Key Management**: Keys stored in platform keychain/keystore
- **Migration**: Automatic migration from SharedPreferences with data validation

## Related Documentation

- Authentication flow: `docs/authentication.md`
- Hive storage: `docs/REPOSITORY_LIFECYCLE.md`
- Clean architecture: `docs/clean_architecture.md`

