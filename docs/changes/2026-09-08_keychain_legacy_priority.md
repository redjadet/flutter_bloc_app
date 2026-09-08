# Prefer legacy Keychain item while migration pending

## Why

#788 hardened Apple Keychain accessibility. #791/#796 added read-time migration
from legacy `unlocked` items, but `readResult` still returned a non-empty
hardened value first. Devices that upgraded through #788 before #791 could hold
an interim rotated Hive key in hardened storage while the original key remained
in the legacy envelope — hardened-first reads used the wrong key and wiped
encrypted local data.

## What changed

- `FlutterSecureSecretStorage.readResult` peeks legacy storage first when
  migration is enabled; only reads hardened storage when no legacy item remains.
- Regression:
  `legacy Keychain value wins when hardened store holds interim rotated secret`.
- Docs: [`security/storage_rules.md`](../security/storage_rules.md) documents the
  dual-store invariant and **do not reopen** guidance for this PR class.

## Related

- #788 (ThisDeviceOnly), #789 (closed duplicate), #791, #796, #817
