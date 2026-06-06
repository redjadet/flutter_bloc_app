# CommonPageLayout custom app bar widening

**Date:** 2026-06-06

## Summary

- **`CommonPageLayout`**: Optional `PreferredSizeWidget? appBar` (custom bar bypasses default `CommonAppBar` + title params). Added `backgroundColor`, `centerTitle`, `floatingActionButtonLocation`. Debug assert requires non-empty `title` or custom `appBar`.
- **Migrations** (`useResponsiveBody: false` where page owns layout): search (custom `_SearchPageAppBar` + surface background), counter (`CounterPageAppBar`), chat list (themed `CommonAppBar` params), calculator.
- **Tests**: `test/shared/widgets/common_page_layout_test.dart` — custom `appBar` case.
- **Durable prefs**: responsive shell guardrail in `docs/agent_kb/operator_preferences_durable.md`.

## Verification

```bash
flutter test test/shared/widgets/common_page_layout_test.dart \
  test/features/search/presentation/pages/search_page_test.dart \
  test/features/calculator/presentation/pages/calculator_page_test.dart \
  test/features/chat/presentation/pages/chat_list_page_test.dart \
  test/features/counter/presentation/widgets/counter_page_app_bar_test.dart
./bin/checklist
CHECKLIST_INTEGRATION_DEVICE=77ECE67D-12D9-4605-889C-A715DE7F9F13 \
  INTEGRATION_TESTS_RUN_COVERAGE=false ./bin/integration_tests
```

Integration (iPhone 17e, 2026-06-06): **24/24 passed** (`all_flows_test.dart`).
