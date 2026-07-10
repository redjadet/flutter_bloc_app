# QG-D04: context.read/watch in presentation build (warn)

**Date:** 2026-07-09

## Summary

Promoted **QG-D04** to checklist **warn** mode with demo-feature exclusions and
fixture trio under `tool/fixtures/context_read_watch/`.

## Changes

- Added `tool/check_context_read_watch.sh` (`CHECK_CONTEXT_READ_WATCH_MODE=warn` default)
- Wired into `tool/delivery_checklist.sh` (rebuild theme)
- Updated deferred backlog decisions for QG-D01/D03/D04/D06/D08 per portfolio quality plan

## Verification

```bash
bash tool/check_context_read_watch.sh --paths tool/fixtures/context_read_watch/presentation/good.dart
bash tool/check_context_read_watch.sh --paths tool/fixtures/context_read_watch/presentation/bad.dart
CHECK_CONTEXT_READ_WATCH_MODE=fail bash tool/check_context_read_watch.sh --paths tool/fixtures/context_read_watch/presentation/bad.dart
```
