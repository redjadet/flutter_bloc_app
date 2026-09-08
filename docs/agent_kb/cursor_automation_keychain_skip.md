# Cursor automation: Keychain dual-store skip

Paste the block below into the instructions for the security/cloud
automation that opened Keychain migration PRs
([automation `76c5cf4e…`](https://cursor.com/automations/76c5cf4e-e1dd-4b93-a59d-25c8ee41bd9e)),
or into any similar “find Keychain / Hive secret data-loss” prompt.

Canon in-repo: [`security/storage_rules.md`](../security/storage_rules.md),
[`changes/2026-09-08_keychain_legacy_priority.md`](../changes/2026-09-08_keychain_legacy_priority.md),
PR [#817](https://github.com/redjadet/flutter_bloc_app/pull/817).

## Prompt addendum (copy as-is)

```text
## Settled: Apple Keychain legacy ↔ hardened dual-store (do not reopen)

The dual-accessibility Keychain data-loss class is CLOSED on main as of
PR #817 (after #788 ThisDeviceOnly, #791 migrate-when-hardened-empty,
#796 delete-legacy-only-after-verify).

Invariant already implemented in
`packages/app_shared_flutter/lib/src/platform/secure_secret_storage.dart`:
when legacy Keychain migration is enabled on Apple platforms, `readResult`
MUST peek the legacy `unlocked` item first; if present, that value wins and
is migrated. Only read hardened storage when no legacy item remains.

Do NOT open another PR, draft, or “prefer legacy / migrate Keychain /
Hive wipe” fix for this class unless ALL of the following are true:

1. You have a NEW failing automated test or a concrete device repro that is
   NOT already covered by
   `legacy Keychain value wins when hardened store holds interim rotated secret`
   in `apps/mobile/test/secure_secret_storage_test.dart`.
2. You read `docs/security/storage_rules.md` (Legacy Apple Keychain migration)
   and confirmed the proposed gap is outside #789/#791/#796/#817.
3. The change is not a reorder/variant of “check legacy before hardened” or
   “keep legacy until verify”.

If the only finding is hardened-first reads while a legacy item exists, or
any restatement of that dual-store story: do nothing. Do not open a PR.
Cite #817 and move on.
```

## After pasting

1. Save / activate the automation.
2. Optional: add an automation Memory note with the same “settled #817” one-liner
   so future runs retain the skip even if the prompt drifts.
