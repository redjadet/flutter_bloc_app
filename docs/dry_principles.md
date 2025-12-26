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

❌ **Bad Practices**:

- Duplicating error handling logic in each cubit method
- Copy-pasting repository load/save patterns without base class
- Creating new skeleton widgets without using `SkeletonBase`
- Reimplementing HTTP request logic instead of using extensions

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
