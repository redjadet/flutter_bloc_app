# Hive schema migrations — implementation

Continued from [`hive_schema_migrations.md`](hive_schema_migrations.md).

## Migrator design

For durable data, prefer two-phase writes:

1. Delete stale temp key.
2. Decode old value.
3. Salvage per item/field.
4. Write migrated value to a temp key.
5. Validate temp payload by reparsing through the production DTO parser.
6. Swap temp into the real key.
7. Delete temp key.
8. Let schema coordinator write fingerprint.

If validation fails, clean temp where possible and throw. The schema coordinator
will keep the old fingerprint.

For list data, drop only invalid items when safe. Do not drop the entire list
because one item is malformed unless no item-level salvage contract exists.

For queue data, prefer quarantine:

- Copy invalid entry to `dead_letter:<originalKey>` or another agreed
  quarantine location.
- Include original payload and error metadata.
- Delete the original only after the quarantine write succeeds.
- Make reruns idempotent.

`pending_sync_operations:v1` uses `dead_letter:<originalKey>` with payload:

```text
{
  schema: "dead_letter:v1",
  quarantinedAt: ISO-8601 UTC string,
  originalKey: string,
  fromFingerprint: previous fingerprint or null,
  error: validation code,
  originalValue: original primitive/map/list payload
}
```

Existing dead-letter entries are preserved on rerun; migration deletes the
original key only after the dead-letter write succeeds or already exists.

## Watch and metadata safety

Schema metadata and temp/dead-letter keys can trigger `box.watch()` events.

Before wiring a schema to a watched box:

- Confirm schema ensure runs before watch subscription starts.
- Filter metadata/temp keys in watchers or read codecs.
- Add tests that metadata/temp/dead-letter keys do not produce UI/state noise
  or data deletion.

Current pending-sync reads ignore `__meta__schema_fingerprints` and
`dead_letter:*` so future quarantine entries are preserved.

## Current implemented namespaces

- `search_cache:query_*`: cleanup malformed cached result payloads.
- `settings:preferred_locale_code`: validate/delete invalid setting value.
- `settings:theme_mode`: validate/delete invalid setting value.
- `todo_list:todos`: full migrate with `__tmp__todos_migrated`, per-item
  salvage, DTO validation, and idempotent temp cleanup.
- `counter:v1`: full migrate with count/timestamp/bool/string coercions and
  invalid-value cleanup.
- `pending_sync_operations:v1`: full migrate that quarantines malformed legacy
  queue entries to `dead_letter:<originalKey>`, preserves valid operations,
  deletes originals only after quarantine, and preserves schema meta/dead-letter
  keys during read/prune scans.

Historical state and validation proof:
[`../changes/2026-05-04_hive_schema_migrations_full_migrate_todo_counter.md`](../changes/2026-05-04_hive_schema_migrations_full_migrate_todo_counter.md).

## Test expectations

Add focused tests for:

- first adoption and fingerprint write;
- fingerprint not written when migrator throws;
- idempotent rerun;
- stale temp cleanup;
- malformed legacy payloads;
- per-item salvage versus whole-key deletion;
- metadata/temp/dead-letter key filtering for watched or scanned boxes.

Use existing examples:

- `test/shared/storage/hive_schema_migration_test.dart`
- `test/features/search/data/search_cache_repository_test.dart`
- `test/hive_locale_repository_test.dart`
- `test/hive_theme_repository_test.dart`
- `test/features/todo_list/data/hive_todo_repository_test.dart`
- `test/hive_counter_repository_test.dart`
- `test/shared/sync/pending_sync_repository_test.dart`

## Validation route

For any Hive schema migration change, run at least:

```sh
dart run tool/generate_hive_schema_fingerprints.dart --check-generated
bash tool/check_hive_schema_fingerprints.sh
HIVE_SCHEMA_ENFORCE_INPUTS=true bash tool/check_hive_schema_fingerprints.sh
git diff --check
```

Also run focused analyze/tests for changed repositories and migration tests.
Because Hive schema work touches shared storage and can affect offline sync,
finish with `./bin/checklist` unless the user explicitly asks to skip it.
