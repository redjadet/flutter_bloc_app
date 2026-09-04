# Social Feed persistence early gate

## Why

PR #785 showed that successful remote mutation application is insufficient when
the matching Hive write fails. Queued replay must retain intent and back off;
direct online like/comment mutations must re-enter the durable queue.

The repository tests covered those paths, but the focused checklist regression
router selected a Social Feed page test instead. A similar regression could
therefore wait for later coverage to fail.

## Change

- Route Social Feed data changes through
  `offline_first_social_feed_repository_test.dart` before coverage.
- Require four explicit Hive-failure regressions in the existing
  `check_offline_first_remote_merge.sh` inventory: queued/direct like and
  queued/direct comment.
- Keep the existing offline-first guard and checklist wiring; no parallel
  script or CI workflow was added.

## Verification

```bash
CHECK_REGRESSION_GUARDS_MODE=auto \
  bash tool/check_regression_guards.sh --paths \
  apps/mobile/lib/features/social_feed_demo/data/offline_first_social_feed_repository_sync.part.dart
bash tool/check_offline_first_remote_merge.sh
bash tool/validate_validation_docs.sh
```
