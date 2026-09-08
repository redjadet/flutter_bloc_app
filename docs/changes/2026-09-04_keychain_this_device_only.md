# Apple Keychain: device-bound accessibility for secure storage

## Why

`flutter_secure_storage` defaults Apple `accessibility` to
`KeychainAccessibility.unlocked` (`kSecAttrAccessibleWhenUnlocked`). That
value can be included in encrypted backups and **migrate to a new device** on
restore. Auth tokens and Hive encryption keys should die with the device
unless product intent says otherwise.

## What changed

- `FlutterSecureSecretStorage` now constructs storage with
  `KeychainAccessibility.first_unlock_this_device` and `synchronizable: false`
  for iOS and macOS (`createDefaultFlutterSecureStorage()`).
- Docs: [`security/storage_rules.md`](../security/storage_rules.md),
  [`security_and_secrets.md`](../security_and_secrets.md),
  [`review/security_checklist.md`](../review/security_checklist.md).
- Tests assert the hardened defaults and that the plugin default remains
  migrate-capable (so we keep overriding it).

## Upgrade note

Existing Keychain items keep the accessibility set at write time. Follow-up
read-time migration lands in #791 / #796 / #817: legacy `unlocked` items are
preferred until rewritten and verified under
`first_unlock_this_device` (see [`storage_rules.md`](../security/storage_rules.md)).
Do not regenerate Hive keys solely to upgrade accessibility.
