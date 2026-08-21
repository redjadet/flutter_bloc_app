# Change: Modal sheet BlocProvider.value guard

## Summary

Social feed scenario sheet crashed with `ProviderNotFoundException` for
`SocialFeedCubit` because `showModalBottomSheet` builds above the page-scoped
provider. Same class also hit the comment composer submit path.

## Bug class

Modal / adaptive bottom sheet builders that `context.read`/`watch` a Cubit (or
mount widgets that do) without wrapping `BlocProvider.value`.

## Capture

- Fix: re-provide cubit in scenario sheet + comment composer
- Static: `tool/check_modal_bloc_provider.sh` (+ fixtures self-test)
- Tests: `social_feed_demo_page_test` opens scenario sheet; comment composer
  verifies submit reaches cubit; integration flow opens scenario controls
- Wired: `delivery_checklist.sh`, `check_regression_guards.sh`,
  `docs/testing_overview.md` anchors, validation guides

## Verify

```bash
bash tool/check_modal_bloc_provider_fixtures.sh
bash tool/check_modal_bloc_provider.sh
cd apps/mobile && flutter test \
  test/features/social_feed_demo/presentation/pages/social_feed_demo_page_test.dart \
  test/features/social_feed_demo/presentation/widgets/social_feed_comment_composer_test.dart
```
