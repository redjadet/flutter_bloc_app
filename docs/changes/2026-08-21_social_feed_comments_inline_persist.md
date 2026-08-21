# Change: Social feed comments — inline thread + Hive persist

## Summary

Follow-on to the social feed demo: expand/collapse comment threads on the post
card, keep badge counts aligned with visible stored+pending comments, persist
threads in Hive across restart, and replace filler seed copy with natural demo
text.

## What changed

- **Presentation:** `SocialFeedCommentThread` / `SocialFeedVisibleComments`;
  post card badge uses visible thread length; l10n expand/collapse strings
- **Cubit:** project `commentCount` from stored+pending; align after load /
  refresh / loadMore
- **Data:** Hive `comments:v1` round-trip; remote export/replace threads;
  refresh merge prefers current remote page; natural seed authors/copy
- **Checklist:** missing `CHECK_MESSAGES` entry for
  `check_modal_bloc_provider.sh` (unblocked `./bin/checklist`)

## Verify

```bash
cd apps/mobile && flutter test test/features/social_feed_demo
./tool/run_file_length_lint.sh
bash tool/check_navigation_outside_presentation.sh
bash tool/check_feature_brief_linked.sh
```
