# Extend offline-first remote-merge guard to chat + profile

## What landed

- Guarded regressions:
  - Chat: `pullRemote does not overwrite local when remote load fails`
    (documents intentional no-op pull; local history must survive)
  - Profile: `pullRemote does not overwrite local when remote load fails`
    (remote load failure must keep cache)
- `tool/check_offline_first_remote_merge.sh` inventories + auto-path selection
  include chat and profile test files
- Contract docs updated ([`offline_first/chat.md`](../offline_first/chat.md),
  [`offline_first/profile.md`](../offline_first/profile.md))

## Intentional exceptions (search / chart)

Search and chart-demo are **query/cache refresh** surfaces without timestamped
entity merge like counter/todo. They stay out of the remote-merge guard until
they gain a `_shouldApplyRemote`-style merge. Do not invent empty TOCTOU tests
for LWW cache refresh alone.

## Verification

```bash
CHECK_OFFLINE_FIRST_REMOTE_MERGE_MODE=always bash tool/check_offline_first_remote_merge.sh
```
