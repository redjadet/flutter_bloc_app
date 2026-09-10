# Keychain delete clears legacy store; serialize Hive notes writes

## Why

Two high-severity gaps from recent work:

1. **Keychain delete resurrection (security):** After legacy-first peek (#817),
   `FlutterSecureSecretStorage.delete` only removed the hardened Keychain item.
   A leftover legacy `unlocked` item could be re-migrated on the next
   `readResult`, resurrecting credentials the user explicitly cleared.
2. **Hive notes lost-update race (data loss):** `HiveNotesRepository` used
   `getBox()` then read-modify-write outside the per-box mutex. Concurrent
   `save`/`delete` could drop a mutation. `getBox()` is
   `runWithBox((box) async => box)` — the lock ends when the box is returned.

## What changed

- Apple platforms with legacy migration: `delete` also removes the legacy item.
- `HiveNotesRepository.fetchAll` / `save` / `delete` wrap RMW in `runWithBox`
  (same pattern as `HiveSettingsRepository`).
- Regression tests for both paths.

## Related

- #817 (legacy Keychain priority), #830 (notes demo), #834
