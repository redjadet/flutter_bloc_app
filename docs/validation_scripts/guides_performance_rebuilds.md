# Validation scripts — performance rebuilds

Router: [`../validation_scripts.md`](../validation_scripts.md).

## Rebuild and concurrency

### `check_perf_unnecessary_rebuilds.sh`

**Purpose**: Heuristic check for potential unnecessary rebuilds that might cause blinking or performance issues.

**What it checks**:

- `setState()` calls triggered by `hasAnyChange` patterns near camera/position-related code
- State handlers that might rebuild on camera/position updates

**Why it matters**:

- Camera/position updates from user interaction shouldn't trigger widget rebuilds
- Unnecessary rebuilds cause visual blinking and performance degradation
- State handlers should only rebuild for meaningful changes (markers, map type, etc.), not camera position

**Example violation**:

```dart
Future<void> _applyStateUpdate(final MapSampleState state) async {
  final MapStateChanges changes = _stateManager.applyStateUpdate(state);
  if (changes.hasAnyChange) {  // ❌ Includes camera changes
    setState(() {});
  }
}
```

**Correct pattern**:

```dart
Future<void> _applyStateUpdate(final MapSampleState state) async {
  final MapStateChanges changes = _stateManager.applyStateUpdate(state);
  // Camera changes are handled by moveCamera() and don't need setState
  if (changes.mapTypeChanged ||
      changes.markersChanged ||
      changes.trafficChanged) {  // ✅ Excludes camera changes
    setState(() {});
  }
}
```

**Suppression**: Add `// check-ignore: reason` on same line or line above

**Note**: This is heuristic check - it warns but doesn't fail. Review manually to confirm.

---

### `check_concurrent_modification.sh`

**Purpose**: Detects potential concurrent modification errors when iterating over collections.

**What it checks**:

- `for-in` loops iterating over collection properties/getters (e.g., `registry.repositories`, `.values`, `.keys`, `.entries`)
- Missing snapshot creation before iteration

**Why it matters**:

- Iterating over collections from getters/properties can throw `ConcurrentModificationError` if underlying collection is modified during iteration
- Collections should be snapshot with `List.from()`, `.toList()`, or similar before iteration
- Common in registry/collection patterns where multiple threads or async operations might modify collection

**Example violation**:

```dart
final List<SyncableRepository> syncables = registry.repositories;  // ❌ Returns view
for (final SyncableRepository repo in syncables) {  // May throw ConcurrentModificationError
  await repo.pullRemote();
}
```

**Correct pattern**:

```dart
// Create a snapshot copy to avoid concurrent modification during iteration
final List<SyncableRepository> syncables =
    List<SyncableRepository>.from(registry.repositories);  // ✅ Creates snapshot
for (final SyncableRepository repo in syncables) {
  await repo.pullRemote();
}
```

**Suppression**: Add `// check-ignore: reason` on same line or line above

---
