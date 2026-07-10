# Maintainability follow-up B — scapes toggleFavorite domain

**Date:** 2026-07-10  
**Seam:** Rank 6 / scapes P5

## Change

Extract pure `toggleScapeFavorite` into `features/scapes/domain/`. `ScapesCubit.toggleFavorite` delegates; behavior unchanged.

## Proof

```bash
flutter test test/features/scapes/domain/toggle_scape_favorite_test.dart
flutter test test/features/scapes/
```
