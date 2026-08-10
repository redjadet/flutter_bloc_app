# Clear search Hive cache on Firebase session cleanup

## Feature: SEARCH-01 (auth/sync lifecycle remeasure)

### Problem

`clearFirebaseLocalSessionData` cleared todo/counter Hive, chat history,
pending sync rows, and profile cache on Firebase sign-out / account switch, but
left `SearchCacheRepository` (recent queries + result cache) intact. The next
session could read the previous user's search history.

### Scope

- In: session cleanup call + regression test + change note
- Out: Profile/Search don't-overwrite guard expansion; Chat remote watch

### Layers touched

- [x] app auth session cleanup
- [x] tests
- [ ] domain API change (uses existing `SearchCacheRepository.clearCache`)

### Tests

- [x] `firebase_local_session_cleanup_test.dart` verifies `clearCache`

### Proof command

```bash
(cd apps/mobile && flutter test test/app/auth/firebase_local_session_cleanup_test.dart)
./bin/format
```
