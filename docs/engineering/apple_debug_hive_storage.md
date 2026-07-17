# Apple debug Hive and secret storage

Quick triage for iOS simulator and macOS **debug** runs when local persistence
logs look suspicious. Release builds are unchanged (Keychain + default Hive paths).

Related: [`security_and_secrets.md`](../security_and_secrets.md) (encryption
principles), [`offline_first/hive_schema_migrations.md`](../offline_first/hive_schema_migrations.md),
[`engineering/apple_debug_hive_storage.md`](../engineering/apple_debug_hive_storage.md).

## Symptom → cause → fix

| Log / symptom | Likely cause | Fix |
| --- | --- | --- |
| `FlutterSecureSecretStorage.* failed` + Keychain **-34018** | iOS simulator / debug lacks Keychain entitlements; `flutter_secure_storage` cannot persist | Confirm `useInMemorySecretStorageInDebug()` covers iOS; **full restart** (not hot reload). Run `bash tool/check_apple_debug_hive_storage.sh`. |
| `Secure storage unavailable; using non-persisted Hive encryption key` | Ephemeral key each launch when secure storage write fails | Same as above + stable `_appleDebugFallbackKey` in `HiveKeyManager` for Apple debug. |
| `Recovering corrupted box.` (Hive, multiple times at startup) | Old on-disk boxes encrypted with a **previous** key or default `Hive.initFlutter()` path | iOS debug must use **`hive_ios_debug`** dir (not legacy path). Erase app on simulator once if noise persists after code fix. |
| `Hive initialized in hive_ios_debug (...)` once, no recovery spam | Healthy Apple debug path | No action. |
| macOS Safari/Chrome inherits desktop debug behavior | macOS-only gate missing `!kIsWeb` | Run `bash tool/check_macos_debug_web_guard.sh`. |

Expected **benign** dev logs (not bugs): missing Firebase/Supabase secrets,
`CHAT_RENDER_DEMO_ENABLED=false`, Remote Config fetch success.

## Design (three guards)

1. **Secrets** — `packages/app_shared_flutter/lib/src/platform/secure_secret_storage.dart`
   `useInMemorySecretStorageInDebug()` → `InMemorySecretStorage` on **iOS and
   macOS** when `!kReleaseMode && !kIsWeb`. Avoids Keychain on simulator.

2. **Encryption key** — `packages/storage/lib/src/hive/hive_key_manager.dart`
   Same helper → deterministic `_appleDebugFallbackKey` (32 bytes) so encrypted
   boxes stay readable across debug restarts.

3. **Hive directory** — `packages/storage/lib/src/hive/hive_initializer_io.dart`
   - iOS debug → `Application Support/hive_ios_debug`  
   - macOS debug → `Application Support/hive_macos_debug` (existing)  
   Isolates debug data from release paths and from pre-fix corrupted files.

Release: `FlutterSecureSecretStorage` + persisted key + `Hive.initFlutter()` /
desktop `hive` (non-debug macOS).

**Profile builds:** gates use `!kReleaseMode`, so iOS/macOS **Profile** on a device
also uses in-memory secrets, stable debug key, and `hive_*_debug` directories —
same as Debug, not production-like Keychain persistence. Use **Release** to
validate real secure-storage behavior before shipping.

## Key files

| File | Role |
| --- | --- |
| `packages/app_shared_flutter/lib/src/platform/secure_secret_storage.dart` | Platform secret backend |
| `packages/storage/lib/src/hive/hive_key_manager.dart` | AES key source |
| `packages/storage/lib/src/hive/hive_initializer_io.dart` | Hive root path |
| `packages/storage/lib/src/hive/hive_service.dart` | Encrypted box open/close |
| `test/secure_secret_storage_test.dart` | iOS/macOS debug storage tests |
| `test/shared/storage/hive_key_manager_test.dart` | Stable debug key tests |

## Verify (agents / local)

```bash
# Regression guard (checklist + CI via ./bin/checklist)
bash tool/check_apple_debug_hive_storage.sh

# Related guards
bash tool/check_macos_debug_web_guard.sh
bash tool/check_no_hive_openbox.sh

# Unit tests
flutter test test/secure_secret_storage_test.dart test/shared/storage/hive_key_manager_test.dart test/shared/storage/hive_service_test.dart
```

After changing init/DI/storage paths: **hot restart** or cold `flutter run` on
simulator. Dart-defines and Hive roots are compile-time / process-start.

## Simulator still noisy?

1. Delete app from simulator (long-press → Delete App) or `xcrun simctl uninstall booted <bundleId>`.
2. Re-run app; confirm `Hive initialized in hive_ios_debug` in console.
3. Second cold start should not print `Recovering corrupted box.`

Bundle ID: `com.example.flutterBlocApp` (see `ios/Runner` / Xcode).

## Prevent regressions

- **Do not** use `FlutterSecureSecretStorage` directly for Hive keys in Apple
  debug without going through `createDefaultSecretStorage()`.
- **Do not** call `Hive.openBox` outside `HiveService` (`check_no_hive_openbox.sh`).
- **Do not** remove `hive_ios_debug` / `hive_macos_debug` without updating this
  doc and `tool/check_apple_debug_hive_storage.sh`.
- Touching these files → run narrow validation in
  [`validation_routing_fast_vs_full.md`](validation_routing_fast_vs_full.md)
  (Apple debug storage row).

## Routing

| Changed paths | Minimum proof |
| --- | --- |
| `packages/app_shared_flutter/lib/src/platform/secure_secret_storage.dart`, `packages/storage/lib/src/hive/hive_*.dart` | `bash tool/check_apple_debug_hive_storage.sh` + focused storage tests + simulator smoke if behavior changed |
| `docs/**` only | `bash tool/check_apple_debug_hive_storage.sh` if guard script or anchors changed |
