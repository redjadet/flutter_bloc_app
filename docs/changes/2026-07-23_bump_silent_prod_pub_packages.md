# Change note: bump silent-prod Pub packages

**Date:** 2026-07-23
**Branch:** `chore/bump-silent-prod-pub-packages`

## Follow-up (0.1.4)

`ilkersevim_safe_parse` **0.1.4** restores lenient `parseMapOfMaps` skip of `FormatException` from `parseItem` (0.1.3 always rethrew). App call sites stay on default `failOnPartial: false`. Websocket connect release always `completeErrorAndReset` for `ilkersevim_async_lifecycle` 0.1.4.

## Why

Silent-production-failure hardenings published on Pub.dev. Raise workspace
caret floors to the new patches.

## Versions

| Package | Released | App floor |
| --- | --- | --- |
| `ilkersevim_retry` | `0.1.3` | `^0.1.3` |
| `ilkersevim_safe_parse` | `0.1.4` | `^0.1.4` |
| `ilkersevim_async_lifecycle` | `0.1.4` | `^0.1.4` |
| `ilkersevim_relative_time` | `0.1.3` | `^0.1.3` |

## What changed

- `apps/mobile`, `packages/networking`, `packages/storage` pubspec carets
- `docs/engineering/SHARED_UTILITIES.md` owner table
- Workspace lock refresh to hosted versions

## External proof

- Retry: <https://pub.dev/packages/ilkersevim_retry/versions/0.1.3> · Actions <https://github.com/redjadet/ilkersevim_retry/actions/runs/30045669467>
- Safe parse: <https://pub.dev/packages/ilkersevim_safe_parse/versions/0.1.4> · Actions <https://github.com/redjadet/ilkersevim_safe_parse/actions/runs/30047605649>
- Async lifecycle: <https://pub.dev/packages/ilkersevim_async_lifecycle/versions/0.1.4> · Actions <https://github.com/redjadet/ilkersevim_async_lifecycle/actions/runs/30045674463>
- Relative time: <https://pub.dev/packages/ilkersevim_relative_time/versions/0.1.3> · Actions <https://github.com/redjadet/ilkersevim_relative_time/actions/runs/30045677609>
