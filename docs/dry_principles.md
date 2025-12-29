# DRY Principles in flutter_bloc_app

This app actively applies **DRY (Don't Repeat Yourself)** principles to reduce code duplication and improve maintainability. This document outlines the consolidations implemented, patterns used, and guidelines for future development.

> **Related:** See [`README.md`](../README.md) for a quick overview.

## Overview

DRY principles are applied throughout the codebase to:

- Reduce maintenance burden by centralizing common logic
- Ensure consistency across similar implementations
- Make it easier to extend and modify shared behavior
- Improve code quality and readability

## Implemented Consolidations

### 1. Skeleton Widgets Consolidation

**Problem**: Multiple skeleton widgets (`SkeletonListTile`, `SkeletonCard`, `SkeletonGridItem`) duplicated common patterns:

- `RepaintBoundary` wrapper for performance
- `Semantics` widget for accessibility
- `Skeletonizer` with `ShimmerEffect` configuration
- Theme-based color scheme setup

**Solution**: Created `SkeletonBase` widget that encapsulates all common skeleton behavior.

**Location**: `lib/shared/widgets/skeletons/skeleton_base.dart`

**Impact**:

- ~60 lines of duplicate code removed across 3 files
- Consistent shimmer effects and accessibility labels
- Easier to maintain and extend skeleton widgets
- Single point of change for skeleton styling

**Usage Example**:

```dart
// Before: Each skeleton widget duplicated the same setup
class SkeletonListTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Semantics(
        label: 'Loading content',
        child: Skeletonizer(
          effect: ShimmerEffect(/* ... */),
          child: Container(/* ... */),
        ),
      ),
    );
  }
}

// After: Use SkeletonBase
class SkeletonListTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SkeletonBase(
      child: Container(/* specific list tile content */),
    );
  }
}
```

### 2. HTTP Client Extensions Consolidation

**Problem**: `getMapped()` and `postMapped()` methods in `ResilientHttpClientExtensions` duplicated:

- Request creation and header setting
- Response streaming and conversion
- Error status code mapping
- Timeout exception handling

**Solution**: Extracted common logic into `_sendMappedRequest()` private method.

**Location**: `lib/shared/http/resilient_http_client_extensions.dart`

**Impact**:

- ~40 lines of duplicate code removed
- Consistent error handling across HTTP methods
- Easier to add new HTTP methods (PUT, DELETE, etc.)
- Single point of change for request/response handling

**Usage Example**:

```dart
// Before: Duplicated logic in each method
Future<http.Response> getMapped(Uri url, {...}) async {
  try {
    final request = http.Request('GET', url);
    // ... 30+ lines of request/response/error handling
  } on TimeoutException {
    throw http.ClientException('Request timed out', url);
  }
}

Future<http.Response> postMapped(Uri url, {...}) async {
  try {
    final request = http.Request('POST', url);
    // ... 30+ lines of nearly identical code
  } on TimeoutException {
    throw http.ClientException('Request timed out', url);
  }
}

// After: Shared implementation
Future<http.Response> getMapped(Uri url, {...}) =>
  _sendMappedRequest(method: 'GET', url: url, ...);

Future<http.Response> postMapped(Uri url, {...}) =>
  _sendMappedRequest(method: 'POST', url: url, body: body, ...);
```

### 3. Settings Repository Consolidation

**Problem**: `HiveLocaleRepository` and `HiveThemeRepository` duplicated patterns for:

- Loading values from Hive with validation
- Saving values to Hive with error handling
- Type conversion (string ↔ domain type)
- Invalid data cleanup
- `StorageGuard.run` usage

**Solution**: Created generic `HiveSettingsRepository<T>` base class that handles all common operations.

**Location**: `lib/shared/storage/hive_settings_repository.dart`

**Impact**:

- ~120 lines of duplicate code removed across 2 files
- Consistent error handling and validation
- Type-safe generic implementation
- Easy to add new settings repositories (just extend and provide converters)

**Usage Example**:

```dart
// Before: Duplicated load/save/validation logic
class HiveLocaleRepository extends HiveRepositoryBase {
  Future<AppLocale?> load() async => StorageGuard.run<AppLocale?>(
    logContext: 'HiveLocaleRepository.load',
    action: () async {
      final box = await getBox();
      final value = box.get(_keyLocale);
      if (value is! String || value.isEmpty) return null;
      try {
        return AppLocale.fromTag(value);
      } catch (error, stackTrace) {
        AppLogger.error('Invalid locale tag', error, stackTrace);
        await safeDeleteKey(box, _keyLocale);
        return null;
      }
    },
    fallback: () => null,
  );
  // Similar pattern repeated in save()
}

// After: Extend base class with converters
class HiveLocaleRepository extends HiveSettingsRepository<AppLocale>
    implements LocaleRepository {
  HiveLocaleRepository({required super.hiveService})
    : super(
        key: 'preferred_locale_code',
        fromString: AppLocale.fromTag,
        toStringValue: (locale) => locale.tag,
      );
}
```

### 4. Status View Layout Consolidation

**Problem**: `CommonErrorView` and `CommonEmptyState` duplicated the same layout:

- Centered column structure
- Responsive padding/spacing
- Optional icon/title/action sections

**Solution**: Introduced `CommonStatusView` as a shared layout widget.

**Location**: `lib/shared/widgets/common_status_view.dart`

**Impact**:

- Reduced duplicated layout code across empty/error views
- Keeps styling differences in the callers while reusing structure
- Single place to adjust spacing and layout behavior

**Usage Example**:

```dart
// After: Shared status layout with per-view styling
return CommonStatusView(
  message: message,
  icon: Icons.error_outline,
  messageStyle: TextStyle(
    fontSize: context.responsiveTitleSize,
    fontWeight: FontWeight.w600,
  ),
  action: CommonRetryButton(onPressed: onRetry),
);
```

### 5. Form Input Decoration Consolidation

**Problem**: `CommonFormField` and `CommonDropdownField` duplicated:

- Border radius and border styles
- Focused/disabled styling
- Responsive content padding

**Solution**: Extracted a shared input decoration builder.

**Location**: `lib/shared/widgets/common_form_field.dart`

**Impact**:

- Reduced duplicate decoration code across shared form widgets
- Keeps visual consistency for form fields
- Makes future styling tweaks a single change

### 6. Max-Width Layout Consolidation

**Problem**: Multiple pages repeated the same pattern:

- `Center`/`Align` wrapper
- `ConstrainedBox` with `contentMaxWidth`
- Optional padding around the constrained content

**Solution**: Added `CommonMaxWidth` to encapsulate the shared layout.

**Location**: `lib/shared/widgets/common_max_width.dart`

**Impact**:

- Removed repeated max-width boilerplate across pages
- Keeps layout intent consistent and easy to tweak
- Makes further reuse straightforward in new screens

**Usage Example**:

```dart
// After: Shared max-width wrapper
CommonMaxWidth(
  child: Column(
    children: [
      // page content
    ],
  ),
);
```

### 7. Centered Message Layout Consolidation

**Problem**: Multiple widgets used the same centered message layout with
padding and text styling.

**Solution**: Reused `CommonStatusView` for centered text-only empty states,
adding optional padding support for variants.

**Locations**:

- `lib/shared/widgets/common_status_view.dart`
- `lib/features/chat/presentation/widgets/chat_message_list.dart`
- `lib/features/chat/presentation/widgets/chat_history_empty_state.dart`

**Impact**:

- Reduced repeated `Center` + `Padding` + `Text` blocks
- Keeps empty-state layout consistent while allowing custom padding

### 8. Profile Button Style Consolidation

**Problem**: Profile screens duplicated `OutlinedButton` styling and Roboto
label text configuration.

**Solution**: Centralized the style and text helpers in a shared profile
widget utility.

**Location**: `lib/features/profile/presentation/widgets/profile_button_styles.dart`

**Impact**:

- Keeps profile button styling consistent across screens
- Reduces repeated `OutlinedButton.styleFrom` and font configuration

### 9. Profile Page Layout Value Consolidation

**Problem**: The profile page repeated complex spacing and width calculations
for multiple sections and buttons.

**Solution**: Extracted shared layout values into local variables within the
page build method.

**Location**: `lib/features/profile/presentation/pages/profile_page.dart`

**Impact**:

- Reduces repeated calculations and improves readability
- Makes layout tuning easier by updating a single value

### 10. Filled Input Decoration Consolidation

**Problem**: `registerInputDecoration` function and `RegisterPasswordField` duplicated
the same filled input decoration pattern:

- Filled background color calculation (alpha blending)
- Border radius and border styles
- Focused/enabled border styling
- Content padding

**Solution**: Created `buildFilledInputDecoration` helper function to centralize the
filled input decoration pattern.

**Location**: `lib/shared/widgets/common_input_decoration_helpers.dart`

**Impact**:

- ~50 lines of duplicate code removed across 2 files
- Consistent filled input styling across registration forms
- Single point of change for filled input decoration updates
- Easier to maintain and extend registration form fields

**Usage Example**:

```dart
// Before: Duplicated filled decoration logic
InputDecoration registerInputDecoration(...) {
  final double overlayAlpha = theme.brightness == Brightness.dark ? 0.16 : 0.04;
  final Color fillColor = Color.alphaBlend(...);
  return InputDecoration(
    filled: true,
    fillColor: fillColor,
    // ... 30+ lines of border/padding configuration
  );
}

// After: Use shared helper
InputDecoration registerInputDecoration(...) {
  return buildFilledInputDecoration(
    context,
    hintText: hint,
    errorText: errorText,
    hintStyle: customHintStyle,
  );
}
```

### 11. ViewStatus Branching Consolidation (Profile Page)

**Problem**: `ProfilePage` manually branched on loading/error states with repetitive
if-else logic.

**Solution**: Refactored to use `ViewStatusSwitcher` for consistent status handling.

**Location**: `lib/features/profile/presentation/pages/profile_page.dart`

**Impact**:

- Reduced repetitive status checking code
- Consistent status handling pattern across pages
- Easier to maintain status transitions

**Usage Example**:

```dart
// Before: Manual branching
if (bodyData.isLoading && !bodyData.hasUser) {
  return const CommonLoadingWidget(color: Colors.black);
}
if (bodyData.hasError && !bodyData.hasUser) {
  return CommonErrorView(...);
}

// After: Use ViewStatusSwitcher
ViewStatusSwitcher<ProfileCubit, ProfileState, _ProfileBodyData>(
  isLoading: (data) => data.isLoading && !data.hasUser,
  isError: (data) => data.hasError && !data.hasUser,
  loadingBuilder: (_) => const CommonLoadingWidget(color: Colors.black),
  errorBuilder: (context, _) => CommonErrorView(...),
  builder: (context, bodyData) => /* success content */,
)
```

### 12. ViewStatus Branching Consolidation (Chart Page)

**Problem**: `ChartPage` manually branched on loading/error/empty states with
repetitive if-else logic.

**Solution**: Refactored to use `ViewStatusSwitcher` for consistent status handling.

**Location**: `lib/features/chart/presentation/pages/chart_page.dart`

**Impact**:

- Reduced repetitive status checking code
- Consistent status handling pattern matching other pages
- Easier to maintain status transitions

## Further DRY Opportunities

These are candidate areas for consolidation; implement incrementally as patterns
repeat across 2-3+ locations.

### Input Decorations in Feature Widgets

**Pattern**: Custom `InputDecoration` may still appear in some feature widgets that
don't use the filled pattern.

**Examples**:

- `lib/features/search/presentation/widgets/search_text_field.dart`
- `lib/features/chat/presentation/widgets/chat_input_bar.dart`
- `lib/features/graphql_demo/presentation/widgets/graphql_filter_bar.dart`

**Opportunity**:

- Reuse `CommonFormField`/`CommonDropdownField` where possible.
- For custom layouts requiring raw `TextField`, consider if existing helpers
  (`buildFilledInputDecoration` or `_buildCommonInputDecoration`) can be extended.

### Repeated ViewStatus Branching

**Pattern**: Some pages may still manually branch on loading/error/empty states.

**Examples**:

- `lib/features/chat/presentation/widgets/chat_list_view.dart` (uses switch expressions, which is acceptable)

**Opportunity**:

- Prefer `ViewStatusSwitcher` + `CommonStatusView` for consistent status
  handling with shared builders where manual branching becomes repetitive.

### Repeated Max-Width Layout Wrappers

**Pattern**: `Center` + `ConstrainedBox` + `Padding` sequences are repeated for
content width constraints.

**Examples**:

- `lib/features/profile/presentation/pages/profile_page.dart`
- `lib/features/chat/presentation/widgets/chat_message_list.dart`
- `lib/features/chart/presentation/pages/chart_page.dart`

**Opportunity**:

- Introduce a small shared wrapper (or expand `CommonPageLayout` usage) to
  unify max-width layout patterns and responsive padding.

## DRY Patterns Used

The codebase uses several patterns to achieve DRY:

### Base Classes

For repositories, widgets, or services with shared lifecycle:

- **`HiveRepositoryBase`**: Common Hive box management and safe key deletion
- **`HiveSettingsRepository<T>`**: Generic settings repository with validation and error handling
- **`SkeletonBase`**: Common skeleton widget behavior (shimmer, accessibility, repaint boundary)

**When to use**: When multiple classes share >50% of their implementation and have similar lifecycle.

### Mixins

For cross-cutting concerns that can be applied to multiple classes:

- **`CubitErrorHandler`**: Standardized error handling in cubits
- **`CubitSubscriptionMixin`**: Subscription lifecycle management
- **`StateRestorationMixin`**: State restoration from snapshots

**When to use**: When functionality needs to be shared across unrelated classes that can't use inheritance.

### Extensions

For utility methods on existing types:

- **`ResilientHttpClientExtensions`**: HTTP request methods with error mapping
- **`CubitContextHelpers`**: Convenient cubit access from `BuildContext`
- **Responsive extensions**: Spacing, typography, and layout utilities

**When to use**: When adding convenience methods to existing types without modifying their source.

### Helper Classes

For stateless utilities that don't fit into a class hierarchy:

- **`CubitHelpers`**: Safe cubit operations from context
- **`ErrorHandling`**: UI error handling (snackbars, dialogs)
- **`CubitExceptionHandler`**: Async operation exception handling

**When to use**: When functionality is stateless and doesn't belong to a specific class hierarchy.

### Helper Functions

For stateless utility functions that provide shared behavior:

- **`buildFilledInputDecoration`**: Filled input decoration styling for registration forms
- **`_buildCommonInputDecoration`**: Common input decoration styling for form fields

**When to use**: When functionality is a simple function that doesn't require class state or complex behavior.

## When to Apply DRY

### Consolidation Thresholds

- **Repeated patterns**: Extract when the same logic appears **3+ times**
- **Similar implementations**: Consolidate when **>50% of code is shared**
- **Common error handling**: Use shared utilities instead of duplicating try-catch blocks
- **Shared UI patterns**: Extract common widget structures

### Before Creating New Code

1. **Search existing codebase**: Check `lib/shared/` for existing utilities before implementing new logic
2. **Identify patterns**: Look for similar code in the same feature or across features
3. **Extract incrementally**: Refactor duplication after identifying 2-3 instances, not on first occurrence
4. **Maintain contracts**: Ensure consolidated code maintains existing interfaces and behavior

### Good vs. Bad Examples

✅ **Good Practices**:

- `HiveLocaleRepository` and `HiveThemeRepository` extend `HiveSettingsRepository<T>`
- All skeleton widgets use `SkeletonBase` for common shimmer/accessibility logic
- HTTP extensions use `_sendMappedRequest` for shared request/response handling
- Cubits use `CubitExceptionHandler` instead of duplicating try-catch blocks
- Registration forms use `buildFilledInputDecoration` for consistent filled input styling
- Pages use `ViewStatusSwitcher` for consistent loading/error/success state handling

❌ **Bad Practices**:

- Duplicating error handling logic in each cubit method
- Copy-pasting repository load/save patterns without base class
- Creating new skeleton widgets without using `SkeletonBase`
- Reimplementing HTTP request logic instead of using extensions
- Duplicating input decoration styling across form fields
- Manual status branching when `ViewStatusSwitcher` can be used

## Validation After DRY Refactoring

All DRY consolidations must be validated through:

1. **Full test suite**: `flutter test` - Ensure all tests pass
2. **Code quality checks**: `./bin/checklist` - Format, analyze, and coverage
3. **Lint analysis**: `flutter analyze` - No new warnings or errors
4. **No breaking changes**: All existing functionality preserved
5. **Check for unused code**: Remove old duplicated implementations after consolidation

## Future Opportunities

Areas where DRY could be further applied:

- **Error handling in repositories**: If more repositories follow similar error handling patterns
- **State management patterns**: If cubits start duplicating similar state transition logic
- **Widget composition**: If similar widget structures appear across features
- **API client patterns**: If more API clients need similar request/response handling

## Related Documentation

- [`README.md`](../README.md) - Quick overview of DRY principles applied
- [`solid_principles.md`](solid_principles.md) - SOLID principles in the codebase
- [`SHARED_UTILITIES.md`](SHARED_UTILITIES.md) - Shared utilities documentation
