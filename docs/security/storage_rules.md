# Storage rules

<!-- markdownlint-disable MD060 -->

Where persistent data lives and how plugin-backed storage failures are handled.

## Decision matrix

| Data | Mechanism | Location / notes |
|------|-----------|----------------|
| Non-sensitive preferences | `SharedPreferences` via app prefs abstractions | Theme, flags, lightweight settings |
| Secrets (tokens, API keys) | `flutter_secure_storage` via `FlutterSecureSecretStorage` | `packages/app_shared_flutter/lib/src/platform/secure_secret_storage.dart` |
| Structured offline / feature cache | Hive boxes with registered adapters | Feature-specific repositories; see offline-first guides |
| Staff demo proof artifacts | Local files via `StaffDemoProofFileStore` | Photos/signatures copied into app sandbox before upload |
| Remote authoritative state | Supabase / HTTP APIs | Repositories; network errors use `AppError` / `NetworkError` |

## Secure storage

- **Read path:** prefer `readResult(key)` → `Result<String?>` with `StorageFailure` / `PlatformFailure` on errors.
- **Legacy `read()`:** delegates to `readResult().getOrNull()` for gradual migration.
- **Never** store secrets in `SharedPreferences` or plain Hive fields.
- **Tests:** mock `SecretStorage` or exercise `readResult` with injected storage (see `test/secure_secret_storage_test.dart`).

## Hive

- Register adapters in bootstrap before opening boxes.
- Migrations: follow [offline_first/hive_schema_migrations.md](../offline_first/hive_schema_migrations.md).
- Corruption / open failures → map to `StorageFailure` at repository boundary where `Result` is adopted.
- **Encryption key (secure storage):** `HiveKeyManager` is **fail-closed** on read or post-generate persist/verify failure (`HiveKeyReadException`, `HiveKeyPersistenceException`). Encrypted box open then fails fast instead of silently using an in-memory fallback key. Unencrypted boxes and non-Hive features may still degrade per feature policy.

## Files & media

- User-selected images: pick in **data layer** (`ImagePickerStaffDemoProofPhotoPicker`, domain port `StaffDemoProofPhotoPicker`), persist via domain file store, then reference paths in state.
- Do not keep `XFile` or plugin handles in Cubit state—only durable paths.

## Failure surfacing

| Storage type | Typical failure | Mapping |
|--------------|-------------------|---------|
| Secure storage | `PlatformException`, `MissingPluginException` | `StorageFailure` / `PlatformFailure` → `appErrorFromFailure` |
| Hive | Open/write errors | Repository logs; user message via `AppError` where exposed |
| Hive encryption key | Secure storage read/persist failure | Fail-closed: `HiveKeyReadException` / `HiveKeyPersistenceException`; encrypted `openBox` does not proceed |
| Missing local file (proof) | Validation at submit | Cubit error string (file missing locally) |

See [plugin_failure_mode_strategy.md](../engineering/plugin_failure_mode_strategy.md) for wrapper and `Result` conventions.

## Related

- [offline_first/adoption_guide.md](../offline_first/adoption_guide.md)
- [clean_architecture.md](../clean_architecture.md) — data layer owns I/O
