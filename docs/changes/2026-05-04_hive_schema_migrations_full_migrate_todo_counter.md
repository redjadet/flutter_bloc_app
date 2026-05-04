# Hive schema migrations: current state and remaining work

Date: 2026-05-04

## Purpose

Hive storage in this app uses primitives, maps, and JSON-like payloads rather
than Hive `TypeAdapter`/`typeId` models. The migration work protects current
Hive boxes from DTO/map/json schema drift.

This is **manifest-driven schema migration**, not automatic semantic detection.
Runtime fingerprints change only when `tool/hive_schema_manifest.json` changes.
The generator and checks make stale fingerprints visible when manifest or input
files drift.

## Current state

### Shared infrastructure

- Manifest: `tool/hive_schema_manifest.json`
- Generator: `tool/generate_hive_schema_fingerprints.dart`
- Wrapper check: `tool/check_hive_schema_fingerprints.sh`
- Generated output: `lib/shared/storage/hive_schema_fingerprints.g.dart`
- Runtime coordinator: `lib/shared/storage/hive_schema_migration.dart`
- Repository hook: `lib/shared/storage/hive_repository_base.dart`
- Per-box locking/open coordination: `lib/shared/storage/hive_service.dart`

Runtime metadata is stored inside each Hive box at
`__meta__schema_fingerprints` as `{namespace: fingerprint}`. Fingerprints are
written only after a migrator or cleanup completes successfully. If no migrator
exists for a mismatch, the old fingerprint is left unchanged and a warning is
logged.

Global kill switch:

```sh
--dart-define=HIVE_SCHEMA_MIGRATIONS=false
```

### Tooling behavior

- `dart run tool/generate_hive_schema_fingerprints.dart --check-generated`
  hard-fails when generated output is stale.
- `bash tool/check_hive_schema_fingerprints.sh` hard-checks generated output
  and soft-checks input drift.
- `HIVE_SCHEMA_ENFORCE_INPUTS=true bash tool/check_hive_schema_fingerprints.sh`
  enforces input digests for release/strict checks.

Important: migration implementation files are included as manifest inputs, so
future migration logic changes are visible to the input-drift check.

## What is implemented

### Search cache: `search_cache:query_*`

Implemented as cleanup-only migration.

- Drops malformed cached search result payloads.
- Keeps parseable entries.
- Handles parser exceptions without aborting the whole cleanup.
- Uses namespace fingerprinting for `search_cache:query_*`.

Files:

- `lib/features/search/data/hive_search_cache_repository.dart`
- `test/features/search/data/search_cache_repository_test.dart`

### Settings: `settings:preferred_locale_code`, `settings:theme_mode`

Implemented as narrow validation cleanup.

- Deletes invalid owned values.
- Catches parser failures and treats them as invalid stored values.
- Leaves unrelated settings box keys alone.

Files:

- `lib/shared/storage/hive_settings_repository.dart`
- `test/hive_locale_repository_test.dart`
- `test/hive_theme_repository_test.dart`

### Todo: `todo_list:todos`

Implemented as full migrate with two-phase write.

- Accepts legacy `String` JSON list and current `List<Map>` payloads.
- Drops only invalid items when possible.
- Required per item: `id`, `title`, `createdAt`, `updatedAt`.
- Coerces parseable date values to UTC ISO strings.
- Handles pathological/non-finite numeric dates by dropping that item, not by
  failing the whole migration.
- Writes migrated payload to `__tmp__todos_migrated`.
- Validates temp payload by reparsing with `TodoItemDto.fromMap`.
- Swaps into `todos`, deletes temp key, then allows fingerprint write.
- Clears stale temp key before each migration run for idempotency.

Files:

- `lib/features/todo_list/data/hive_todo_repository.dart`
- `lib/features/todo_list/data/hive_todo_repository_migration.dart`
- `test/features/todo_list/data/hive_todo_repository_test.dart`

Covered tests:

- Legacy JSON list salvage.
- Per-item invalid date salvage.
- Stale temp cleanup and idempotency.
- Fingerprint is not written when migrator throws.

### Counter: `counter:v1`

Implemented as full migrate.

- `count`: accepts `int`, finite `num`, and trimmed integer strings; clamps
  negative values to zero; deletes invalid/non-finite values.
- `last_changed` and `last_synced_at`: accepts valid milliseconds,
  numeric strings, ISO strings, and `DateTime`; deletes invalid, negative, far
  future, and non-finite values using existing timestamp plausibility rules.
- `synchronized`: accepts `bool`, `0`/`1`, and trimmed case-insensitive
  `"true"`/`"false"`.
- `user_id` and `change_id`: keeps trimmed non-empty strings only.
- Migration runs through `getBox()` before `box.watch()` subscription starts.
- Counter watch remains filtered to relevant data keys.
- Migration helpers live in a part file to keep repository file size below the
  repo lint limit.

Files:

- `lib/features/counter/data/hive_counter_repository.dart`
- `lib/features/counter/data/hive_counter_repository_migration.dart`
- `lib/features/counter/data/hive_counter_repository_watch_helper.dart`
- `test/hive_counter_repository_test.dart`

Covered tests:

- Legacy primitive coercions.
- Invalid timestamp cleanup and string trimming.
- Fingerprint is not written when migrator throws.

### Pending sync: read-safety only

Full migrate is intentionally deferred. The shipped safety fix prevents normal
pending-sync reads from treating migration metadata or future quarantine entries
as malformed sync operations.

Ignored keys:

- `__meta__schema_fingerprints`
- `dead_letter:*`

Files:

- `lib/shared/sync/pending_sync_repository_codec.dart`
- `test/shared/sync/pending_sync_repository_test.dart`

Covered tests:

- Metadata and `dead_letter:*` entries are ignored and preserved by
  `getPendingOperations`.

## What is left

### Pending sync full migrate

Still deferred because it has the highest data-loss risk and needs runtime sync
contract knowledge.

Open requirements:

- Define dead-letter payload format for `dead_letter:<originalKey>`.
- Copy invalid operation to quarantine with original payload and error metadata
  before deleting the original key.
- Make quarantine idempotent if migration is rerun.
- Validate `SyncOperation.fromJson` success.
- Enforce required fields.
- Enforce known `entityType` using runtime registry/contracts.
- Enforce `idempotencyKey` rules using existing sync contracts.
- Confirm same-box dead-letter keys do not create watch/read noise. If they do,
  reassess separate quarantine box versus same-box keys.

### Optional future hardening

- Add support for single-map todo legacy payload only if evidence shows that
  shape existed in production.
- Add migration telemetry if production diagnosis needs counts for migrated,
  dropped, and quarantined records.
- Consider a stable public constant for `__meta__schema_fingerprints` consumers
  if more boxes need to filter schema metadata.

## Validation proof

Latest verified commands for this slice:

```sh
dart analyze lib/features/counter/data/hive_counter_repository.dart lib/features/counter/data/hive_counter_repository_migration.dart lib/features/todo_list/data/hive_todo_repository.dart lib/features/todo_list/data/hive_todo_repository_migration.dart lib/shared/sync/pending_sync_repository_codec.dart test/features/todo_list/data/hive_todo_repository_test.dart test/hive_counter_repository_test.dart test/shared/sync/pending_sync_repository_test.dart
flutter test test/features/todo_list/data/hive_todo_repository_test.dart test/hive_counter_repository_test.dart test/shared/sync/pending_sync_repository_test.dart
dart run tool/generate_hive_schema_fingerprints.dart --check-generated
bash tool/check_hive_schema_fingerprints.sh
HIVE_SCHEMA_ENFORCE_INPUTS=true bash tool/check_hive_schema_fingerprints.sh
git diff --check
./bin/checklist
```

All passed. `./bin/checklist` updated coverage docs/badge to 70.82%.
