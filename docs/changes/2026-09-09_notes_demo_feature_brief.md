# Feature: Notes Demo

Local Hive notes CRUD under `/notes-demo`, edited via `AlertDialog` on the same
page (no second route).

## Problem

Need a credential-free local-storage demo that follows `HiveRepositoryBase` /
schema fingerprint rules and stays list-in-box like `todo_list`.

## Scope

- In: Hive box `notes_demo` key `notes`; `NotesRepository` watch/save/delete;
  Cubit + list/empty UI; AlertDialog create/edit; DI + GoRouter + Example hub;
  l10n; hive manifest + fingerprints
- Out: sync/auth; Freezed; bottom sheet; second GoRoute; Firebase

## Layers Touched

- [x] domain
- [x] data
- [x] presentation
- [x] DI
- [x] routes / l10n

## Contracts

- Repository: `NotesRepository` (`fetchAll`, `watchAll`, `save`, `delete`)
- State: `NotesState` (loading, notes, errorMessage)
- DTO / mapper: `NoteDto` ↔ `Note` (ms epoch timestamps)

## Tests

### Behaviour

- [x] Scenario: watch stream load; blank title validation error
- [x] Files: `apps/mobile/test/features/notes_demo/presentation/notes_cubit_test.dart`

### State

- [x] Scenario: loading → notes; validation error path
- [x] Files: same Cubit test

### Unit

- [x] Scenario: covered indirectly via Cubit + fake repo (no Hive harness in unit lane)
- [x] Files: Cubit test fake repository

### Integration

- [x] Journey: N/A unless Example hub walkthrough includes tile

### Proof Command

- [x] `cd apps/mobile && flutter test test/features/notes_demo`

## Docs

- [x] [`feature_overview.md`](../feature_overview.md), [`changes/2026-09-09_weather_notes_demos.md`](2026-09-09_weather_notes_demos.md)

## Risks

- Fingerprint regen required after manifest change; format whole-repo can touch unrelated files — prefer scoped `dart format`.
