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
- **Apple Keychain accessibility (required):** do not rely on
  `flutter_secure_storage` defaults. `IOSOptions` /
  `MacOsOptions` default to `KeychainAccessibility.unlocked`, which can
  **migrate via encrypted backups** to another device. This repo sets
  `accessibility: KeychainAccessibility.first_unlock_this_device` and
  `synchronizable: false` in
  `FlutterSecureSecretStorage.createDefaultFlutterSecureStorage()` so
  session tokens and Hive encryption keys stay **device-bound** and off
  iCloud Keychain sync. Prefer another `…_this_device` / `passcode` value
  only when the secret’s access window requires it.
- **Legacy Apple Keychain migration (complete as of #817/#834):** accessibility
  is fixed at write time. On iOS/macOS, `readResult` peeks the legacy `unlocked`
  envelope first when migration is enabled. If a legacy item exists, that value
  wins and is rewritten under hardened options; legacy is deleted only after
  hardened verify (#791, #796, #817). Do **not** prefer a non-empty hardened
  value while a legacy item remains — devices that rotated a Hive key into
  hardened storage after #788 and before migration (#791) can hold both, and
  hardened-first reads wipe encrypted local data.
- **Delete clears both envelopes:** when legacy migration is enabled,
  `FlutterSecureSecretStorage.delete` must remove the hardened item **and** the
  legacy Keychain item. Clears attempt both stores **independently** so a
  hardened-delete failure cannot leave a resurrectable legacy item (#834).
  Guard: `tool/check_keychain_dual_store_symmetry.sh`.
- **Do not reopen Keychain migration PRs** for the same dual-store class
  (#789/#791/#796/#817/#834) unless a **new failing test** or device repro
  proves a remaining gap beyond the coexistence + delete-resurrection tests in
  `apps/mobile/test/secure_secret_storage_test.dart`.
- **Tests:** mock `SecretStorage` or exercise `readResult`/`delete` with injected
  storage (see `test/secure_secret_storage_test.dart`).

## Hive

- Register adapters in bootstrap before opening boxes.
- Migrations: follow [offline_first/hive_schema_migrations.md](../offline_first/hive_schema_migrations.md).
- Corruption / open failures → map to `StorageFailure` at repository boundary where `Result` is adopted.
- **Encryption key (secure storage):** `HiveKeyManager` is **fail-closed** on read or post-generate persist/verify failure (`HiveKeyReadException`, `HiveKeyPersistenceException`). Encrypted box open then fails fast instead of silently using an in-memory fallback key. Unencrypted boxes and non-Hive features may still degrade per feature policy.
- **Per-box mutex / RMW:** `HiveRepositoryBase.getBox()` is
  `runWithBox((box) async => box)` — the lock ends when the box is returned.
  Mutations that read-modify-write a list (or any shared key) **must** wrap the
  full operation in `runWithBox` (pattern: `HiveSettingsRepository`,
  `HiveNotesRepository`, `HiveTodoRepository`, `PendingSyncRepository`). Do not
  `await getBox()` then `put`/`_save*`/`_deleteKeys` outside the callback —
  concurrent save/delete can silently drop updates (#834). Guard:
  `tool/check_hive_getbox_rmw.sh` (per-method allowlisted debt until migrated).

### Known limitations (Hive getBox RMW)

- **Remaining allowlist debt** (shrink-only; see
  `tool/fixtures/hive_getbox_rmw/allowlist.txt`): demo caches (chart, GraphQL,
  search, remote config, profile, realtime market), chat local DS, counter,
  iGaming balance, staff timeclock, **IoT demo storage** (`_save*` helpers).
  High-traffic **todo** + **pending_sync** migrated off the list (2026-09-10).
- **Out of detector scope:** long-lived `watch*` streams that `await getBox()`
  once then hold the box for `box.watch()` (read/listen only; mutations must
  still use `runWithBox`).
- **Keychain dual-store:** if hardened `delete` fails, a later `read` may still
  return the hardened value — that is not legacy resurrection. Legacy envelope
  must still clear independently
  (`tool/check_keychain_dual_store_symmetry.sh`).

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
