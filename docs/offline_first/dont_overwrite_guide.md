# Offline-First: Don’t Overwrite Newer Local with Older Remote

This guide describes the **don’t overwrite** rule for offline-first repositories that merge a remote watch stream into local state. Use it in this repo and in other codebases when you add or review offline-first sync.

## The rule

**When local has unsynced changes, never apply a remote snapshot over local unless the remote is strictly newer (e.g. by timestamp).**

If you apply remote whenever “remote ≠ local” (e.g. `remote.count != local.count`) without checking sync status and timestamps, a stale remote event can overwrite newer user changes and cause UI flicker (e.g. counter up → down → up).

## Correct pattern: `_shouldApplyRemote`-style check

Before writing remote data over local, gate it with a predicate that:

1. If **local is not synchronized** (has pending changes): apply remote **only if** remote is strictly newer than local (e.g. `remote.lastChanged.isAfter(local.lastChanged)`).
2. If **local is synchronized**: you can apply remote when it’s equal or newer, or when it carries different data you want to merge (depending on your conflict policy).

### Single-entity (e.g. counter)

```dart
bool _shouldApplyRemote(
  final LocalSnapshot local,
  final RemoteSnapshot remote,
) {
  if (!local.synchronized) {
    final remoteTs = remote.lastChanged;
    final localTs = local.lastChanged;
    if (localTs == null) return true;
    if (remoteTs == null) return false;
    return remoteTs.isAfter(localTs);
  }
  // Local synced: accept remote if different or newer (policy-dependent).
  if (remote.value != local.value) return true;
  final remoteTs = remote.lastChanged;
  final localTs = local.lastChanged;
  if (remoteTs == null) return true;
  if (localTs == null) return true;
  return remoteTs.isAfter(localTs);
}
```

When merging the remote watch stream:

```dart
remoteSub = _remoteRepository.watch().listen((final remote) async {
  final local = await _localRepository.load();
  if (_shouldApplyRemote(local, remote)) {
    await _localRepository.save(remote.copyWith(
      lastSyncedAt: DateTime.now().toUtc(),
      synchronized: true,
    ));
  }
});
```

### List-entity (e.g. todos)

For lists, run the same idea per item: **do not overwrite a local item with a remote item when local is newer or when local is unsynced and remote isn’t clearly newer.**

- If `localItem.updatedAt.isAfter(remoteItem.updatedAt)` → skip (don’t apply remote).
- If `localItem` exists and `!localItem.synchronized` → only apply remote when it’s the same change (e.g. same `changeId`) or when `remoteItem.updatedAt.isAfter(localItem.updatedAt)`.
- Otherwise apply remote and mark synced.

See `lib/features/todo_list/data/offline_first_todo_repository_helpers.dart` (`_shouldApplyRemote` and `_mergeRemoteIntoLocal`) in this repo for a full example.

## Regression test (for use in any repo)

Add a test that:

1. Puts the app in a state where **local has unsynced data** (newer timestamp).
2. Injects a **stale remote snapshot** (older timestamp, different value).
3. Asserts **local value is unchanged** after the remote event is delivered.

Example (counter-style):

```dart
test('remote watch does not overwrite newer unsynced local count', () async {
  // 1. Setup: offline-first repo with a fake remote that you can push events to.
  final remote = _StreamRemoteRepository();
  addTearDown(remote.controller.close);

  final repository = OfflineFirstCounterRepository(
    localRepository: localRepository,
    remoteRepository: remote,
    pendingSyncRepository: pendingRepository,
    registry: registry,
  );

  // 2. Local unsynced state (newer time).
  final DateTime localChanged = DateTime(2024, 1, 2, 12);
  await repository.save(CounterSnapshot(count: 5, lastChanged: localChanged));

  final sub = repository.watch().listen((_) {});
  addTearDown(sub.cancel);

  // 3. Emit stale remote (older time, different count).
  remote.controller.add(
    CounterSnapshot(count: 4, lastChanged: DateTime(2024, 1, 1, 12)),
  );
  await Future<void>.delayed(const Duration(milliseconds: 10));

  // 4. Local must still be the user's value.
  final local = await localRepository.load();
  expect(local.count, 5);

  await sub.cancel();
});
```

Run this test (and any other “don’t overwrite” tests) in CI. In this repo, `tool/check_offline_first_remote_merge.sh` runs the relevant tests; you can add a similar script in other repos that runs the same kind of test.

## References in this repo

- **Counter (single-entity):** `lib/features/counter/data/offline_first_counter_repository.dart` — `_shouldApplyRemote`, and `watch()` merging remote stream.
- **Todo (list-entity):** `lib/features/todo_list/data/offline_first_todo_repository_helpers.dart` — `_shouldApplyRemote`, `_mergeRemoteIntoLocal`.
- **Regression test:** `test/features/counter/data/offline_first_counter_repository_test.dart` — `remote watch does not overwrite newer unsynced local count`.
- **Validation script:** `tool/check_offline_first_remote_merge.sh` (run via `./bin/checklist` or directly).
- **Docs:** [`validation_scripts.md`](../validation_scripts.md) § “check_offline_first_remote_merge.sh”.

## Checklist for other repos

When adding or reviewing offline-first “remote watch → merge into local”:

- [ ] Before applying remote over local, use a `_shouldApplyRemote`-style check.
- [ ] When local is not synchronized, apply remote only if remote is strictly newer (timestamp).
- [ ] Add a regression test: older remote must not overwrite newer unsynced local.
- [ ] Run that test in CI (e.g. a small script like `check_offline_first_remote_merge.sh`).

---

## Applying in another repo

Use these steps to adopt the don't-overwrite rule in a different codebase.

### 1. Copy or adapt the guide

- Copy this file into the other repo, e.g. [`offline_first/dont_overwrite_guide.md`](dont_overwrite_guide.md) or `sync/dont_overwrite_guide.md`.
- Adjust "References in this repo" to point to that repo's equivalent paths (or remove that section and keep the pattern + checklist).

### 2. Implement `_shouldApplyRemote` when merging remote watch into local

- **Single-entity (e.g. one counter/settings blob):** Before applying a remote snapshot over local, call a predicate. If local is not synchronized, return true only when remote is strictly newer (e.g. `remote.lastChanged.isAfter(local.lastChanged)`). If local is synchronized, apply your policy (e.g. accept when remote is equal or newer). Use the "Single-entity" code sketch in this guide.
- **List-entity (e.g. todos/items):** In your merge loop, for each remote item skip when `localItem.updatedAt.isAfter(remoteItem.updatedAt)`. When local item is unsynced, apply remote only if same `changeId` or `remoteItem.updatedAt.isAfter(localItem.updatedAt)`. Use the "List-entity" bullets and, for a full example, the Todo helpers in this repo (`lib/features/todo_list/data/offline_first_todo_repository_helpers.dart`).

### 3. Add the regression test

- Add a test that: (1) builds an offline-first repo with a fake/injectable remote, (2) saves local state with a **newer** timestamp (unsynced), (3) emits a **stale** remote snapshot (older timestamp, different value), (4) after a short delay, asserts that local state is **unchanged** (e.g. still the user's value). Use the "Regression test" example in this guide and name the test e.g. `remote watch does not overwrite newer unsynced local …`.

### 4. Run the test in CI (optional script)

Add a small script so CI can run the don't-overwrite test(s) explicitly. Example (save as `tool/check_offline_first_remote_merge.sh` or similar):

```bash
#!/usr/bin/env bash
set -e
# Run tests that assert: older remote must not overwrite newer unsynced local.
# Add your test files to the array below.
tests=(
  "test/features/counter/data/offline_first_counter_repository_test.dart"
  # e.g. "test/features/your_feature/data/offline_first_whatever_repository_test.dart"
)
for f in "${tests[@]}"; do
  if [ -f "$f" ]; then
    flutter test "$f" --name "remote watch does not overwrite"
  fi
done
```

- Make the script executable (`chmod +x tool/check_offline_first_remote_merge.sh`).
- In CI, run this script (or run the same `flutter test` invocations). In this repo it is also run via `./bin/checklist`.
