# DRY Principles in flutter_bloc_app

This app actively applies **DRY (Don't Repeat Yourself)** principles to reduce code duplication and improve maintainability. This document outlines the consolidations implemented, patterns used, and guidelines for future development.

> **Related Documentation:**
>
> - [Code Quality](CODE_QUALITY.md) - Comprehensive DRY principles analysis with verification results
> - [Architecture Details](architecture_details.md) - Architecture patterns and principles
> - [Flutter Best Practices Review](flutter_best_practices_review.md) - DRY principles review section

## Overview

DRY principles are applied throughout the codebase to:

- Reduce maintenance burden by centralizing common logic
- Ensure consistency across similar implementations
- Make it easier to extend and modify shared behavior
- Improve code quality and readability

## Consolidations Implemented

The table below summarizes every DRY consolidation applied so far. For each
entry, the **Pattern** column names the base class, helper, or widget that
replaced the duplicated code.

<!-- markdownlint-disable MD013 -->
| # | Area | Pattern / Location | Lines saved | Key benefit |
| --- | ------ | -------------------- | ----------- | ----------- |
| 1 | Skeleton widgets | `SkeletonBase` (`shared/widgets/skeletons/skeleton_base.dart`) | ~60 | Single shimmer + a11y + repaint boundary |
| 2 | HTTP client | Shared Dio + interceptors (`shared/http/app_dio.dart`, `NetworkGuard`) | — | One auth/retry/telemetry pipeline |
| 3 | Settings repos | `HiveSettingsRepository<T>` (`shared/storage/hive_settings_repository.dart`) | ~120 | Generic load/save/validate with converters |
| 4 | Status views | `CommonStatusView` (`shared/widgets/common_status_view.dart`) | — | Shared error/empty layout structure |
| 5 | Input decoration | `buildCommonInputDecoration` / `buildFilledInputDecoration` (`shared/widgets/common_input_decoration_helpers.dart`) | ~50 | Consistent form field styling |
| 6 | Max-width layout | `CommonMaxWidth` (`shared/widgets/common_max_width.dart`) | — | Single constrained-width wrapper |
| 7 | Centered messages | Reuse of `CommonStatusView` with optional padding | — | Consistent empty states |
| 8 | Profile buttons | `profile_button_styles.dart` | — | Shared outlined-button styling |
| 9 | Profile layout | Local layout variables in `profile_page.dart` | — | No repeated spacing calculations |
| 10 | Page padding | `pageHorizontalPaddingInsets` extension | — | Eliminates `EdgeInsets.symmetric` boilerplate |
| 11 | H+V padding | `pageHorizontalPaddingWithVertical()` extension | — | Combined horizontal + vertical padding |
| 12 | Filled inputs | `buildFilledInputDecoration` | ~50 | Consistent registration-form styling |
| 13 | Status branching | `ViewStatusSwitcher` (Profile page) | — | Declarative loading/error/success |
| 14 | Status branching | `ViewStatusSwitcher` (Chart page) | — | Same pattern, additional page |
| 15 | DI organization | Feature-specific `register_*_services.dart` files | — | SRP per feature, smaller files |
| 16 | Repo factories | `createRemoteRepositoryOrNull<T>()` (`core/di/injector_helpers.dart`) | ~50 | Shared Firebase null-check + error log |
| 17 | Typography | `AppTypography` (`shared/ui/typography.dart`) | — | Theme-aware text style helpers |
| 18 | Feature inputs | Chat input → `buildCommonInputDecoration` | — | More widgets using shared helpers |
| 19 | Status branching | `ViewStatusSwitcher` (Scapes page) | — | Additional page consolidated |
| 20 | EdgeInsets.all | `allGapS/M/L/allCardPadding` extensions | ~15 instances | Concise padding getters |
<!-- markdownlint-enable MD013 -->

## Open Consolidation Opportunities

Implement incrementally when a pattern repeats across 3+ locations.

<!-- markdownlint-disable MD013 -->
| Pattern | Where to look | Suggested action |
| ------- | ------------- | ---------------- |
| Custom `InputDecoration` | `search_text_field.dart`, `graphql_filter_bar.dart` | Reuse `buildCommonInputDecoration` or `CommonFormField` |
| Manual loading/error branching | Any new page that doesn't use `ViewStatusSwitcher` | Prefer `ViewStatusSwitcher` + `CommonStatusView` |
| Max-width layout wrappers | `profile_page.dart`, `chat_message_list.dart`, `chart_page.dart` | Expand `CommonMaxWidth` / `CommonPageLayout` usage |
<!-- markdownlint-enable MD013 -->

## DRY Patterns Used

The codebase uses several patterns to achieve DRY:

### Base Classes

For repositories, widgets, or services with shared lifecycle:

- **`HiveRepositoryBase`**: Common Hive box management and safe key deletion
- **`HiveSettingsRepository<T>`**: Generic settings repository with
  validation and error handling
- **`SkeletonBase`**: Common skeleton widget behavior (shimmer,
  accessibility, repaint boundary)

**When to use**: When multiple classes share >50% of their
implementation and have similar lifecycle.

### Mixins

For cross-cutting concerns that can be applied to multiple classes:

- **`CubitErrorHandler`**: Standardized error handling in cubits
- **`CubitSubscriptionMixin`**: Subscription lifecycle management
- **`StateRestorationMixin`**: State restoration from snapshots

**When to use**: When functionality needs to be shared across
unrelated classes that can't use inheritance.

### Extensions

For utility methods on existing types:

- **Dio + interceptors / `NetworkGuard`**: Shared HTTP client with
  centralized error mapping and timeouts
- **`CubitContextHelpers`**: Convenient cubit access from `BuildContext`
- **Responsive extensions**: Spacing, typography, and layout utilities

**When to use**: When adding convenience methods to existing types
without modifying their source.

### Helper Classes

For stateless utilities that don't fit into a class hierarchy:

- **`CubitHelpers`**: Safe cubit operations from context
- **`ErrorHandling`**: UI error handling (snackbars, dialogs)
- **`CubitExceptionHandler`**: Async operation exception handling

**When to use**: When functionality is stateless and doesn't belong to
a specific class hierarchy.

### Helper Functions

For stateless utility functions that provide shared behavior:

- **`buildFilledInputDecoration`**: Filled input decoration styling for
  registration forms
- **`buildCommonInputDecoration`**: Common input decoration styling for
  form fields

**When to use**: When functionality is a simple function that doesn't
require class state or complex behavior.

## When to Apply DRY

### Consolidation Thresholds

- **Repeated patterns**: Extract when the same logic appears **3+ times**
- **Similar implementations**: Consolidate when **>50% of code is shared**
- **Common error handling**: Use shared utilities instead of
  duplicating try-catch blocks
- **Shared UI patterns**: Extract common widget structures

### Before Creating New Code

1. **Search existing codebase**: Check `lib/shared/` for existing
   utilities before implementing new logic
2. **Identify patterns**: Look for similar code in the same feature or
   across features
3. **Extract incrementally**: Refactor duplication after identifying
   2-3 instances, not on first occurrence
4. **Maintain contracts**: Ensure consolidated code maintains existing
   interfaces and behavior

### Good vs. Bad Examples

✅ **Good Practices**:

- `HiveLocaleRepository` and `HiveThemeRepository` extend
  `HiveSettingsRepository<T>`
- All skeleton widgets use `SkeletonBase` for common shimmer/accessibility logic
- HTTP extensions use `_sendMappedRequest` for shared request/response handling
- Cubits use `CubitExceptionHandler` instead of duplicating try-catch blocks
- Registration forms use `buildFilledInputDecoration` for consistent
  filled input styling
- Pages use `ViewStatusSwitcher` for consistent loading/error/success
  state handling
- Widgets use `context.allGapL` instead of
  `EdgeInsets.all(context.responsiveGapL)`

❌ **Bad Practices**:

- Duplicating error handling logic in each cubit method
- Copy-pasting repository load/save patterns without base class
- Creating new skeleton widgets without using `SkeletonBase`
- Reimplementing HTTP request logic instead of using extensions
- Duplicating input decoration styling across form fields; use
  `buildCommonInputDecoration` or `buildFilledInputDecoration` instead
- Manual status branching when `ViewStatusSwitcher` can be used

## Storage DRY Rule (Hive)

- New Hive-backed repositories must extend `HiveRepositoryBase` or
  `HiveSettingsRepository<T>` and use `HiveService.openBox`.
- Direct `Hive.openBox` calls should live only in shared storage utilities.

Quick check:

```bash
rg "Hive\\.openBox" lib/features lib/core lib/shared | rg -v "lib/shared/storage"
```

## Validation After DRY Refactoring

All DRY consolidations must be validated through:

1. **Full test suite**: `flutter test` - Ensure all tests pass
2. **Code quality checks**: `./bin/checklist` - Format, analyze, and coverage
3. **Lint analysis**: `flutter analyze` - No new warnings or errors
4. **No breaking changes**: All existing functionality preserved
5. **Check for unused code**: Remove old duplicated implementations
   after consolidation

## Future Opportunities

Areas where DRY could be further applied:

- **Error handling in repositories**: If more repositories follow
  similar error handling patterns
- **State management patterns**: If cubits start duplicating similar
  state transition logic
- **Widget composition**: If similar widget structures appear across
  features
- **API client patterns**: If more API clients need similar
  request/response handling

## See Also

- [SOLID Principles](solid_principles.md) — related design principles
- [Shared Utilities](SHARED_UTILITIES.md) — full catalog of shared
  code
