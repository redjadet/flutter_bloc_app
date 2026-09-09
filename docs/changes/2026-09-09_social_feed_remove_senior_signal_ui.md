# Social Feed: remove senior signal UI

## Why

The social feed demo side rail showed a “Senior signal” teaching panel that is
not part of the product demo surface. Keep scenario controls; drop the panel and
its unused copy.

## Change

- Delete `SocialFeedSeniorSignalPanel` and remove it from
  `SocialFeedDemoBody` wide/tablet side rail.
- Drop `socialFeedDemoSeniorSignalTitle` and `socialFeedDemoSignalStep1–5` from
  all `app_*.arb` locales; regenerate `AppLocalizations`.
- Update responsive layout widget tests to assert scenario controls only.

## Layers touched

- presentation (widgets)
- l10n
- tests

## Validation

```bash
./bin/format --changed
flutter test test/features/social_feed_demo/presentation/widgets/social_feed_responsive_layout_test.dart
INTEGRATION_PREFLIGHT_WEB_DEVICE=chrome ./bin/integration_preflight
CHECKLIST_INTEGRATION_DEVICE=<iphone-sim-udid> \
  INTEGRATION_TESTS_RUN_COVERAGE=0 \
  INTEGRATION_TESTS_RUN_PREFLIGHT=0 \
  ./bin/integration_tests integration_test/social_feed_demo_flow_test.dart
./bin/checklist
```
