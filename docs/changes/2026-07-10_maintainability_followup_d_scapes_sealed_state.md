# Maintainability follow-up D — sealed ScapesState

**Date:** 2026-07-10  
**Seam:** Rank 6 / scapes P4

## Change

Replace bool/`lastError` bag with sealed `initial | loading | ready | error`. Page uses `switch`; cubit only mutates favorites/viewMode on `ready`.

## Proof

```bash
flutter test test/features/scapes/
```
