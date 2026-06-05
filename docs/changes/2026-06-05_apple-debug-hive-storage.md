# Apple debug Hive + secret storage fix

**Date:** 2026-06-05

## Summary

- **Runtime**: iOS/macOS debug uses in-memory secret storage (avoids Keychain
  -34018 on simulator), stable debug Hive encryption key, and isolated
  `hive_ios_debug` / `hive_macos_debug` directories.
- **Docs**: [`engineering/apple_debug_hive_storage.md`](../engineering/apple_debug_hive_storage.md)
  — symptom → cause → fix table and verification commands.
- **Guard**: `tool/check_apple_debug_hive_storage.sh` wired into
  `./bin/checklist` (theme: `memory`).

## Verification

```bash
bash tool/check_apple_debug_hive_storage.sh
bash tool/check_macos_debug_web_guard.sh
flutter test test/secure_secret_storage_test.dart test/shared/storage/hive_key_manager_test.dart
```

Simulator: cold `flutter run` on iOS — no -34018, no `Recovering corrupted box.` spam.
