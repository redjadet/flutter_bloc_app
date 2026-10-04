# Change note: bump `ilkersevim_retry` to `0.1.7` (web dart2js)

## Why

`ilkersevim_retry` `0.1.6` broke dart2js web compile / Deploy web with:

`Error: The integer literal 0x7FFFFFFFFFFFFFFF can't be represented exactly in JavaScript`

in `retry_policy.dart`. Tip briefly pinned `0.1.5` via #979 as a stopgap.

## What landed

- `apps/mobile` + `packages/networking`: `ilkersevim_retry: ^0.1.7`
- Lockfile resolves `0.1.7` (JS-safe fix for the `0.1.6` literal)
- No Renovate hold for retry (upstream fix published)

## Verification

```bash
REPO_NAME=flutter_bloc_app bash tool/build_web_github_pages.sh
```
