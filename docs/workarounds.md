# Known Workarounds and Temporary Fixes

This document lists **temporary workarounds** used in this project when upstream packages or tooling have known issues. These are not ideal long-term solutions.

**For maintainers and AI agents:** Prefer finding or contributing **upstream fixes** (package updates, Flutter/Xcode fixes, or alternative approaches). When a better fix exists, remove the workaround from this doc and from the codebase (e.g. `dependency_overrides` in `pubspec.yaml`), and add a short note in the relevant section below.

---

## 1. [Updated 2026-03] path_provider_foundation on iOS 26.x Simulator (`objective_c` FFI crash)

**Symptom:** App startup crashes on iOS 26.4 simulator while resolving
documents/support directories through `path_provider_foundation`, with
`Couldn't resolve native function 'DOBJC_initializeApi'` and
`Failed to load dynamic library 'objective_c.framework/objective_c'`.

**Root cause:** `path_provider_foundation 2.6.0` uses the `objective_c` FFI
path. On current iOS 26.4 simulator runtimes in this workspace, that native
asset load can fail during `Hive.initFlutter()`.

**Current workaround:** Pin `path_provider_foundation` to **2.5.1**, which uses
the non-FFI implementation and avoids the simulator startup crash. Revisit when
upstream packages ship a stable FFI fix for current iOS 26 simulator runtimes.

---

## 2. [Partial] Firebase RTDB: FlutterFire String/Map TypeError on write failure

**Symptom:** When `RealtimeDatabaseTodoRepository.save` fails (e.g. permission denied, rules mismatch), the FlutterFire SDK throws `type 'String' is not a subtype of type 'Map<dynamic, dynamic>'` because native error `details` are sometimes a `String` while `platformExceptionToFirebaseException` expects a `Map`.

**Root cause:** `_flutterfire_internals` assumes `PlatformException.details` is a `Map`; native Firebase can return a string message.

**Current workaround:** RTDB write code (`RealtimeDatabaseTodoRepository.save`, `RealtimeDatabaseCounterRepository.save`) uses `Map<String, Object?>` for `.set()` and wraps writes with a TypeError guard. If FlutterFire throws the known details-cast error, we rethrow a clearer `FirebaseException` (`database-platform-error-details`) so repository-level fallbacks and logs remain actionable.

To fix the underlying write failure itself, verify: (1) Firebase Realtime Database rules are deployed and allow writes for the auth path (see [`todo_list_firebase_security_rules.md`](todo_list_firebase_security_rules.md)), (2) user is authenticated, (3) paths `todos/{userId}/{todoId}` and `counter/{userId}` are valid.

---

## 3. Other workarounds (template)

Add new workarounds below (between ## 2 and ## 3) in the same format:

- **Title:** Short name of the issue.
- **Symptom:** What fails (error message, platform, version).
- **Root cause:** Why it happens (package/tool version, known bug).
- **Current workaround:** What we did (override, config change, code patch).
- **Where to look for a better fix:** Links or keywords for upstream fix.

When the workaround is no longer needed, replace the section with a one-line note and date, e.g.:

```text
### 2. [Resolved YYYY-MM] Some issue – fixed in package X.Y.Z / Flutter 3.x.
```

---

## References

- **pubspec.yaml** `dependency_overrides`: current overrides and short comments.
- **Flutter issues:** [flutter/flutter](https://github.com/flutter/flutter/issues) (e.g. labels `p: path_provider`, `platform-ios`).
- **Package changelogs:** Always check pub.dev changelog before removing a workaround.
