# Notes Demo – Local-Only Storage Contract

**Offline-first adoption:** Intentional exception — local-only. No remote,
no `SyncableRepository`, no pending-sync queue. Trade-off is explicit per
[ADR 0002](../adr/0002-offline-first-data.md).

## Goals

- Credential-free Hive CRUD under `/notes-demo` (Example hub; not interview spine).
- Demonstrate `HiveRepositoryBase`, schema fingerprint, and list-in-box persistence.
- Stay usable with zero auth or network configuration.

## Storage Plan

- Box: `notes_demo`
- Key: `notes` → `List<Map<String, dynamic>>` via `NoteDto`
- Schema namespace: `notes_demo:notes` (manifest + fingerprint)
- Encryption: `HiveService` / `HiveRepositoryBase`; never open boxes directly.
- Mutations: read-modify-write inside `runWithBox` (see [storage_rules.md](../security/storage_rules.md)).

## Repository Wiring

- `HiveNotesRepository` implements `NotesRepository` directly.
- DI: `register_notes_demo_services.dart` → `HiveNotesRepository(hiveService)`.
- **Not registered** in `SyncableRepositoryRegistry`.
- **No** `OfflineFirstNotesRepository`, remote adapter, or sync metadata on `Note`.

## Sync / UI Status

- No sync banner, no Settings sync diagnostics surface for this feature.
- Offline behavior: fully local; no network dependency.

## Data Retention

- Notes persist until user deletes them or app data is cleared.
- No automatic eviction.

## Testing

- `test/features/notes_demo/data/hive_notes_repository_test.dart`
- `test/features/notes_demo/presentation/notes_cubit_test.dart`

## Implementation Status

- ✅ Local-only contract (by design).
- ❌ Not a candidate for `tool/check_offline_first_remote_merge.sh` (no `pullRemote`).
