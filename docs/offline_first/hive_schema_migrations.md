# Hive schema migrations

Use this when a Hive-backed repository changes the stored DTO/map/json shape.
This repo does not use Hive `TypeAdapter`/`typeId` models for app payloads, so
these migrations protect primitive, map, and JSON-like storage.

## When migrations run automatically

Runtime does **not** infer schema changes from Dart diffs. It only compares
stored metadata to the **generated fingerprint** for the repository’s declared
namespace. Migrations run **on box open**, not on a timer or background job.

### Trigger path

1. Repository extends `HiveRepositoryBase` and overrides `schema` with a
   non-null [`HiveBoxSchema`](../../lib/shared/storage/hive_schema_migration.dart)
   (fingerprint from `lib/shared/storage/hive_schema_fingerprints.g.dart`).
2. Any normal read/write path calls `getBox()` → `HiveService.openBoxAndRun`
   (per-box lock) → `HiveSchemaMigratorService.ensureSchema` on that open.

### What `ensureSchema` does

- If migrations are disabled (`HiveSchemaMigratorService.isEnabled` is false,
  e.g. `--dart-define=HIVE_SCHEMA_MIGRATIONS=false`), it returns immediately.
- Reads `__meta__schema_fingerprints` inside the box; compares the namespace
  entry to `schema.fingerprint`.
- **First adoption** (no stored fingerprint for that namespace): runs
  `migrate` / `cleanup` when provided; if **neither** is provided, writes the
  new fingerprint only (metadata-only adoption).
- **Mismatch** (stored fingerprint ≠ current codegen fingerprint): runs
  **`migrate` if set, otherwise `cleanup`** (`migrate ?? cleanup` — only one
  body runs per call). On **success**, updates the stored fingerprint. On
  **failure** (exception) or **no migrator while fingerprints differ**, logs
  and **keeps the old fingerprint** so the next `getBox()` can retry after you
  ship a fix.

### What stays manual (agent/human work)

When stored shape or migration semantics change, you still must: bump
`tool/hive_schema_manifest.json` `spec`, refresh `inputs`, regenerate
fingerprints, implement or extend the migrator, and add tests. Without that,
runtime either never sees a new target fingerprint or has no code path to
rewrite legacy payloads.

## Rule of thumb

When changing code that reads or writes a Hive box:

1. Identify the exact box and key/namespace affected.
2. Decide whether existing stored values can still parse safely.
3. If not, add or update a `HiveBoxSchema` on the owning repository.
4. Update `tool/hive_schema_manifest.json`.
5. Regenerate fingerprints.
6. Add focused migration tests.
7. Run fingerprint checks and the validation route for storage/runtime changes.

Do not call this automatic semantic inference. It is **manifest-driven**:
runtime fingerprints change only when the manifest `spec` changes. Input digest
checks warn or fail when related source files changed and the manifest was not
reviewed.

## Runtime contract

See [When migrations run automatically](#when-migrations-run-automatically) for
the `getBox()` / `ensureSchema` trigger summary.

Schema metadata is stored in each Hive box under:

```text
__meta__schema_fingerprints
```

The value is a map of `{namespace: fingerprint}`.

Rules:

- Use `HiveRepositoryBase.getBox()` / `HiveService.openBoxAndRun`; never open
  boxes directly.
- Run migration before watches subscribe. Repository `getBox()` is the normal
  path.
- Fingerprint is written only after migrator/cleanup success.
- Migrators must be idempotent and monotonic.
- Use per-box locking through `HiveService`; do not add parallel box writes
  outside that path.
- Leave the old fingerprint unchanged when migration fails.
- Keep the kill switch working:

```sh
--dart-define=HIVE_SCHEMA_MIGRATIONS=false
```

## Choosing migration type

Use the smallest safe migration:

- **Metadata only**: first adoption when existing data already parses.
- **Cleanup only**: rebuildable caches or settings where invalid values can be
  deleted safely.
- **Full migrate**: user data or durable state where values should be salvaged.
- **Defer + safety filter**: high-blast-radius queues where quarantine and
  runtime contracts are not ready.

Never delete durable queued/user data on "unknown" unless the owning feature's
acceptance rules explicitly allow it.

## Namespace and manifest rules

Manifest entries live in `tool/hive_schema_manifest.json`.

Each entry needs:

- `name`: namespace, usually `box:key` or `box:prefix_*`.
- `spec`: human-readable schema contract. Bump it when stored shape,
  coercion rules, temp keys, or migration semantics change.
- `inputs`: every source file that changes stored shape or migration behavior,
  including repository files, DTO/domain files, and migration part files.

Generated fingerprints live in
`lib/shared/storage/hive_schema_fingerprints.g.dart`.

Regenerate:

```sh
dart run tool/generate_hive_schema_fingerprints.dart
```

Check:

```sh
dart run tool/generate_hive_schema_fingerprints.dart --check-generated
bash tool/check_hive_schema_fingerprints.sh
HIVE_SCHEMA_ENFORCE_INPUTS=true bash tool/check_hive_schema_fingerprints.sh
```

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
