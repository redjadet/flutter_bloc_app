# Offline-First: Don’t Overwrite Newer Local with Older Remote

This guide describes the **don’t overwrite** rule for offline-first repositories that merge a remote watch stream into local state or replay queued local operations to remote. Use it in this repo and in other codebases when you add or review offline-first sync.

## The rule

**Never apply a remote snapshot over local when local is strictly newer (e.g. by timestamp)—whether local is synchronized or still pending upload. Never push a queued local snapshot over remote when remote is strictly newer.**

When local is **not** synchronized, also require remote to be strictly newer before applying. If you apply remote whenever “remote ≠ local” (e.g. `remote.count != local.count`) without that timestamp gate, a stale remote event can overwrite newer user changes and cause UI flicker (e.g. counter up → down → up), including after a successful sync when an old RTDB snapshot arrives late.

When replaying a pending queue item, load the current remote snapshot before the remote write. If remote has a strictly newer timestamp than the queued snapshot, skip the push and pull/apply the newer remote locally instead. This prevents an old offline operation from another device/session overwriting a newer remote value.

## Correct pattern: `_shouldApplyRemote`-style check

Before writing remote data over local, gate it with a predicate that:

1. **Always:** if both timestamps exist and `local.lastChanged` is after `remote.lastChanged`, reject remote (do not apply).
2. If **local is not synchronized** (has pending changes): apply remote **only if** remote is strictly newer than local.
3. If **local is synchronized**: apply remote when values differ or when remote is equal or newer (policy-dependent); step 1 still blocks stale remotes.

### Single-entity (e.g. counter)

```dart
bool _shouldApplyRemote(
  final LocalSnapshot local,
  final RemoteSnapshot remote,
) {
  final remoteTs = remote.lastChanged;
  final localTs = local.lastChanged;

  // Never apply an older remote over a newer local (unsynced or synced).
  if (localTs != null && remoteTs != null && localTs.isAfter(remoteTs)) {
    return false;
  }

  if (!local.synchronized) {
    if (localTs == null) return true;
    if (remoteTs == null) return false;
    return remoteTs.isAfter(localTs);
  }

  // Local synced: accept remote if different or newer (policy-dependent).
  if (remote.value != local.value) return true;
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

See `lib/features/todo_list/data/offline_first_todo_repository_helpers.dart` (`_shouldMergeRemoteItem` and `_mergeRemoteIntoLocal`) in this repo for a full example.

### TOCTOU: re-read before each local mutation

Timestamp gates alone are not enough when merge loads local once and then writes per item. A user edit can land **after** the initial `fetchAll`/`load` but **before** `save`/`delete`, so the merge decision uses a stale snapshot.

**Rule:** after the initial local read, **re-read immediately before each `save` or `delete`** and re-run the same merge predicate on the fresh row.

Single-entity (counter-style):

```dart
final local = await _localRepository.load();
if (!shouldApplyRemote(local, remote)) return;

final freshLocal = await _localRepository.load();
if (!shouldApplyRemote(freshLocal, remote)) return;

await _localRepository.save(remote.copyWith(synchronized: true, ...));
```

List-entity (todo-style): same pattern inside the per-item loop for remote saves and for deletes of rows absent from remote (re-check `synchronized` before delete).

## Regression test (for use in any repo)

Add tests that:

1. Put local in **unsynced** state with a **newer** timestamp; inject **stale** remote; assert local unchanged.
2. Put local in **synchronized** state with a **newer** timestamp; inject **stale** remote; assert local unchanged (catches late RTDB snapshots after sync).
3. Put a pending operation in the queue with an **older** timestamp than remote; process the operation; assert remote unchanged and local reconciled to remote.
4. **TOCTOU:** intercept the **second** local read during merge (`fetchAll`/`load`), inject a concurrent local write that makes the row unsynced or newer, then assert local is **unchanged** by the remote apply. Cover both `pullRemote` and remote **watch** paths when both exist. For list merges, also cover delete of rows missing from remote.

Example (counter-style, unsynced local):

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

Run these tests (and any other “don’t overwrite” tests) in CI. In this repo, `tool/check_offline_first_remote_merge.sh` runs the relevant test files; you can add a similar script in other repos.

## References in this repo

- **Counter (single-entity):** `lib/features/counter/data/offline_first_counter_repository_helpers.dart` — `shouldApplyRemote`; `offline_first_counter_repository.dart` — `watch()` / `pullRemote()` merge.
- **Todo (list-entity):** `lib/features/todo_list/data/offline_first_todo_repository_helpers.dart` — `_shouldMergeRemoteItem`, `_mergeRemoteIntoLocal`; policy in `TodoMergePolicy.shouldApplyRemote`.
- **Regression tests:** `test/features/counter/data/offline_first_counter_repository_test.dart` — `remote watch does not overwrite newer unsynced local count`; `remote watch does not overwrite newer synchronized local count`; `pullRemote does not overwrite newer synchronized local count`; `pullRemote re-checks local before save when local advances`; `remote watch re-checks local before save when local advances`; `processOperation does not push stale pending over newer remote`. `test/features/todo_list/data/offline_first_todo_repository_test.dart` — `pullRemote re-checks local before save when local advances`; `pullRemote re-checks local before deleting a missing remote item`; `remote watch re-checks local before save when local advances`; `remote watch re-checks local before deleting a missing remote item`; `remote watch does not overwrite newer synchronized local item`; `remote watch does not overwrite newer unsynced local item`; `processOperation does not push stale pending over newer remote`.
- **Validation script:** `tool/check_offline_first_remote_merge.sh` (run via `./bin/checklist` or directly).
- **Docs:** [`validation_scripts.md`](../validation_scripts.md) § “check_offline_first_remote_merge.sh”.

### Coverage parity (counter vs todo)

| Scenario | Counter | Todo (list-entity) |
| --- | --- | --- |
| Stale remote on `pullRemote` (synced local newer) | `pullRemote does not overwrite newer synchronized local count` | `pullRemote does not apply remote when local item is newer` |
| Stale remote on watch (synced) | `remote watch does not overwrite newer synchronized local count` | `remote watch does not overwrite newer synchronized local item` |
| Stale remote on watch (unsynced) | `remote watch does not overwrite newer unsynced local count` | `remote watch does not overwrite newer unsynced local item` |
| TOCTOU save on `pullRemote` | `pullRemote re-checks local before save when local advances` | `pullRemote re-checks local before save when local advances` |
| TOCTOU save on watch | `remote watch re-checks local before save when local advances` | `remote watch re-checks local before save when local advances` |
| TOCTOU delete on `pullRemote` | N/A (single-entity) | `pullRemote re-checks local before deleting a missing remote item` |
| TOCTOU delete on watch | N/A (single-entity) | `remote watch re-checks local before deleting a missing remote item` |
| Stale pending queue replay | `processOperation does not push stale pending over newer remote` | `processOperation does not push stale pending over newer remote` |

## Checklist for other repos

When adding or reviewing offline-first “remote watch → merge into local”:

- [ ] Before applying remote over local, use a `_shouldApplyRemote`-style check.
- [ ] Reject remote when `local.lastChanged` is strictly after `remote.lastChanged` (all sync states).
- [ ] When local is not synchronized, apply remote only if remote is strictly newer (timestamp).
- [ ] **Re-read local immediately before each merge `save`/`delete` and re-run the predicate (TOCTOU).**
- [ ] Before pushing queued local to remote, reject the push when `remote.lastChanged` is strictly after queued local `lastChanged`.
- [ ] Add regression tests: older remote must not overwrite newer **unsynced** or **synchronized** local.
- [ ] Add regression tests: older queued local must not overwrite newer **remote** during pending replay.
- [ ] Add TOCTOU regression tests: intercept second local read during merge; assert concurrent local edit wins (`re-checks local before save` / `… before deleting`).
- [ ] Run those tests in CI (e.g. a small script like `check_offline_first_remote_merge.sh`).

---

## Applying in another repo

Use these steps to adopt the don't-overwrite rule in a different codebase.

### 1. Copy or adapt the guide

- Copy this file into the other repo, e.g. [`offline_first/dont_overwrite_guide.md`](dont_overwrite_guide.md) or `sync/dont_overwrite_guide.md`.
- Adjust "References in this repo" to point to that repo's equivalent paths (or remove that section and keep the pattern + checklist).

### 2. Implement `_shouldApplyRemote` when merging remote watch into local

- **Single-entity (e.g. one counter/settings blob):** Before applying a remote snapshot over local, call a predicate. First reject when both timestamps exist and local is strictly newer. If local is not synchronized, return true only when remote is strictly newer. If local is synchronized, apply your policy (e.g. accept when remote differs or is equal/newer). Use the "Single-entity" code sketch in this guide.
- **List-entity (e.g. todos/items):** In your merge loop, for each remote item skip when `localItem.updatedAt.isAfter(remoteItem.updatedAt)`. When local item is unsynced, apply remote only if same `changeId` or `remoteItem.updatedAt.isAfter(localItem.updatedAt)`. Re-read local before each `save` and before each delete of rows missing from remote; re-run the same checks on the fresh row. Use the "List-entity" bullets and, for a full example, the Todo helpers in this repo (`lib/features/todo_list/data/offline_first_todo_repository_helpers.dart`).

### 3. Add the regression test

- Add tests that: (1) build an offline-first repo with a fake/injectable remote, (2) save local with a **newer** timestamp (unsynced and synchronized cases), (3) emit a **stale** remote snapshot (older timestamp, different value), (4) assert local state is **unchanged**. Use the "Regression test" example in this guide; name tests e.g. `remote watch does not overwrite newer unsynced local …` and `… synchronized local …`.
- Add TOCTOU tests that hook the **second** `fetchAll`/`load` during merge, inject a concurrent local write, and assert local wins. Name tests e.g. `pullRemote re-checks local before save when local advances` and `remote watch re-checks local before save when local advances`. For list merges, add `… before deleting a missing remote item` when remote absence triggers deletes.

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
