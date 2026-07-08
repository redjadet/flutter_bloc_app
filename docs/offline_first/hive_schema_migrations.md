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
   non-null [`HiveBoxSchema`](../../packages/storage/lib/src/hive/hive_schema_migration.dart)
   (fingerprint from `packages/storage/lib/src/hive/hive_schema_fingerprints.g.dart`).
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
`packages/storage/lib/src/hive/hive_schema_fingerprints.g.dart`.

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

**Apple debug (iOS simulator / macOS)**: `Recovering corrupted box.` at startup is
often encryption-key / path drift, not a schema migration bug — see
[`engineering/apple_debug_hive_storage.md`](../engineering/apple_debug_hive_storage.md).

Continued in [`hive_schema_migrations_implementation.md`](hive_schema_migrations_implementation.md).
