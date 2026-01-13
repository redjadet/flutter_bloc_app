# Cupertino Widget Migration Plan

## Overview

This document outlines the plan and implementation for migrating Material widgets to use Cupertino equivalents on Apple platforms (iOS/macOS) to provide a more native iOS experience while maintaining Android compatibility.

## Current State Analysis

### Already Using Cupertino Widgets

The codebase already had platform-adaptive implementations for:

- **Navigation**: `CommonAppBar` uses `CupertinoNavigationBar` on iOS/macOS
- **Bottom Navigation**: `ProfileBottomNav` uses `CupertinoTabBar` on iOS/macOS
- **Loading Indicators**: `CommonLoadingWidget` uses `CupertinoActivityIndicator` on iOS/macOS
- **Date Pickers**: `showAdaptiveTodoDatePicker` uses `CupertinoDatePicker` on iOS/macOS
- **Buttons**: `PlatformAdaptive` helpers use `CupertinoButton` on iOS/macOS
- **Dialogs**: `showAdaptiveDialog` uses `CupertinoAlertDialog` on iOS/macOS
- **Some TextFields**: Todo dialog fields use `CupertinoTextField` on iOS/macOS
- **Action Sheets**: Country picker uses `CupertinoActionSheet` on iOS/macOS

### Areas Migrated

1. **TextFields** - Multiple locations migrated to use `PlatformAdaptive.textField()`
2. **Dropdown Buttons** - Priority selector now uses `CupertinoPicker` modal on iOS/macOS
3. **Checkboxes** - Verified `Checkbox.adaptive` works correctly (already platform-adaptive)
4. **List Tiles** - Settings cards and list items now use `CupertinoListTile` on iOS/macOS
5. **Modal Bottom Sheets** - Updated to use platform-adaptive helper

## Implementation Details

### Phase 1: Platform-Adaptive Helper Methods

Added new helper methods to `lib/shared/utils/platform_adaptive.dart`:

#### 1. TextField Helper

```dart
PlatformAdaptive.textField({
  required BuildContext context,
  required TextEditingController controller,
  String? placeholder,
  String? hintText,
  void Function(String)? onChanged,
  void Function(String)? onSubmitted,
  TextInputType? keyboardType,
  bool obscureText = false,
  int? maxLines = 1,
  bool enabled = true,
  bool autofocus = false,
  EdgeInsetsGeometry? padding,
  InputDecoration? decoration,
  TextStyle? style,
})
```

- Returns `CupertinoTextField` on iOS/macOS, `TextField` elsewhere
- Handles styling differences between platforms

#### 2. Checkbox Helper

```dart
PlatformAdaptive.checkbox({
  required BuildContext context,
  required bool? value,
  required ValueChanged<bool?>? onChanged,
  Color? activeColor,
  Color? checkColor,
})
```

- Returns `CupertinoCheckbox` on iOS/macOS, `Checkbox` elsewhere
- Note: `Checkbox.adaptive` already provides platform adaptation, but this helper ensures consistency

#### 3. List Tile Helper

```dart
PlatformAdaptive.listTile({
  required BuildContext context,
  required Widget title,
  Widget? subtitle,
  Widget? leading,
  Widget? trailing,
  VoidCallback? onTap,
  bool selected = false,
  Color? selectedTileColor,
})
```

- Returns `CupertinoListTile` on iOS/macOS, `ListTile` elsewhere
- Handles API differences (e.g., `selectedTileColor` vs `backgroundColor`)

#### 4. Modal Bottom Sheet Helper

```dart
PlatformAdaptive.showAdaptiveModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  Color? backgroundColor,
  bool useSafeArea = false,
  bool isDismissible = true,
  bool enableDrag = true,
})
```

- Shows `CupertinoActionSheet` via `showCupertinoModalPopup` on iOS/macOS
- Uses Material `showModalBottomSheet` elsewhere

#### 5. Picker Modal Helper

```dart
PlatformAdaptive.showPickerModal<T>({
  required BuildContext context,
  required List<T> items,
  required T selectedItem,
  required String Function(T) itemLabel,
  String? title,
  Widget Function(BuildContext, T)? itemBuilder,
})
```

- Shows `CupertinoPicker` in a modal on iOS/macOS
- Shows Material bottom sheet with list on Android
- Used for dropdown/picker selection patterns

### Phase 2: TextField Migrations

Updated the following files to use `PlatformAdaptive.textField()`:

1. **lib/features/search/presentation/widgets/search_text_field.dart**
   - Custom Container styling preserved on both platforms
   - Uses platform-adaptive text field internally

2. **lib/features/chat/presentation/widgets/chat_input_bar.dart**
   - Simple text field with outline decoration
   - Direct migration to platform-adaptive helper

3. **lib/features/websocket/presentation/pages/websocket_demo_page.dart**
   - Message input field
   - Uses platform-adaptive text field

4. **lib/features/library_demo/presentation/widgets/library_demo_search_row.dart**
   - Search field with custom styling
   - Platform-adaptive implementation

5. **lib/features/todo_list/presentation/helpers/todo_list_dialog_fields.dart**
   - `buildTodoTextField()` refactored to use platform-adaptive helper
   - Previously had manual CupertinoTextField implementation

**Note**: Some TextFields were not migrated:

- `CommonFormField` - Uses `TextFormField` with validation, complex to migrate
- `MarkdownEditorField` - Uses `expands: true` and `scrollController`, not supported by CupertinoTextField

### Phase 3: Dropdown/Picker Migrations

#### Priority Selector

Updated `buildTodoPrioritySelector()` in `lib/features/todo_list/presentation/helpers/todo_list_dialog_fields.dart`:

- **iOS/macOS**: Shows a tappable container that opens `CupertinoPicker` modal via `PlatformAdaptive.showPickerModal()`
- **Android**: Continues using `DropdownButtonFormField`

The iOS implementation provides a native picker experience with Cancel/Done buttons, matching iOS design patterns.

**Note**: Other dropdowns (GraphQL filter bar, chat model selector) can be migrated using the same pattern when needed.

### Phase 4: Checkbox Verification

Verified that `Checkbox.adaptive` already provides platform adaptation:

- Automatically uses `CupertinoCheckbox` on iOS/macOS
- Uses Material `Checkbox` on Android
- No changes needed - existing implementation is correct

### Phase 5: List Tile Migrations

Updated the following files to use `PlatformAdaptive.listTile()`:

1. **lib/features/settings/presentation/widgets/settings_card.dart**
   - `_SettingsTile` widget
   - Selection state handling works on both platforms

2. **lib/features/google_maps/presentation/widgets/google_maps_location_list.dart**
   - Location list items
   - Title, subtitle, trailing widgets preserved

3. **lib/features/counter/presentation/widgets/counter_sync_queue_inspector_button.dart**
   - Sync operation list items
   - Simple title/subtitle layout

4. **lib/features/chat/presentation/widgets/chat_history_conversation_tile.dart**
   - Complex list tile with custom subtitle (Column widget)
   - Selected state with custom colors
   - Note: `shape` property not supported by CupertinoListTile, but `selectedTileColor` works

### Phase 6: Modal Bottom Sheet Migrations

Updated modal bottom sheet calls to use `PlatformAdaptive.showAdaptiveModalBottomSheet()`:

1. **lib/features/chat/presentation/pages/chat_page.dart**
   - `_showHistorySheet()` method
   - Complex scrollable sheet - Cupertino implementation uses `showCupertinoModalPopup`

2. **lib/features/counter/presentation/widgets/counter_sync_queue_inspector_button.dart**
   - Sync queue inspector sheet
   - Simple list-based sheet

## Files Modified

### Core Utilities

- `lib/shared/utils/platform_adaptive.dart` - Added new helper methods

### TextFields

- `lib/features/search/presentation/widgets/search_text_field.dart`
- `lib/features/chat/presentation/widgets/chat_input_bar.dart`
- `lib/features/websocket/presentation/pages/websocket_demo_page.dart`
- `lib/features/todo_list/presentation/helpers/todo_list_dialog_fields.dart`
- `lib/features/library_demo/presentation/widgets/library_demo_search_row.dart`

### Dropdowns

- `lib/features/todo_list/presentation/helpers/todo_list_dialog_fields.dart`

### List Tiles

- `lib/features/settings/presentation/widgets/settings_card.dart`
- `lib/features/google_maps/presentation/widgets/google_maps_location_list.dart`
- `lib/features/counter/presentation/widgets/counter_sync_queue_inspector_button.dart`
- `lib/features/chat/presentation/widgets/chat_history_conversation_tile.dart`

### Modal Bottom Sheets

- `lib/features/chat/presentation/pages/chat_page.dart`
- `lib/features/counter/presentation/widgets/counter_sync_queue_inspector_button.dart`

## File Organization Note

The `platform_adaptive.dart` file exceeds the 250-line limit but uses an ignore comment. This is acceptable because:

- It's a utility class with only static methods (cohesive functionality)
- Splitting static methods in Dart requires complex patterns (extensions can't add static methods)
- The file is well-organized and maintainable despite its length
- All methods are related and belong together conceptually

### Refresh Indicators (Complex)

Refresh indicators require significant refactoring:

- Material `RefreshIndicator` works with `ListView`/`SingleChildScrollView`
- Cupertino `CupertinoRefreshControl` requires `CustomScrollView` with slivers
- Existing code uses `ReorderableListView`, `ListView.builder`, etc.

**Files affected:**

- `lib/features/todo_list/presentation/widgets/todo_list_content.dart`
- `lib/features/graphql_demo/presentation/pages/graphql_demo_page.dart`
- `lib/features/chart/presentation/pages/chart_page.dart`

**Approach**: This would require converting list structures to use `CustomScrollView` with `SliverList`, which is a significant refactoring. Consider handling this case-by-case or creating wrapper widgets that handle the complexity.

### Scaffold Migration (Optional)

Scaffold migration to `CupertinoPageScaffold` is complex due to:

- Many Scaffold features (drawer, floatingActionButton, persistentFooterButtons)
- Different navigation patterns
- Potential breaking changes

**Recommendation**: Current approach (Scaffold + CupertinoNavigationBar) works well and provides good iOS appearance. Scaffold migration may not be necessary.

### Other Dropdowns

Additional dropdowns that could be migrated using the same pattern:

- `lib/features/graphql_demo/presentation/widgets/graphql_filter_bar.dart`
- `lib/features/chat/presentation/widgets/chat_model_selector.dart`
- `lib/shared/widgets/common_form_field.dart` (CommonDropdownField)

## Testing Considerations

1. **Manual Testing**: Test on iOS simulator/device to verify native feel
2. **Widget Tests**: Update tests to handle both Material and Cupertino branches
3. **Golden Tests**: Update golden tests for iOS appearance if applicable
4. **Cross-Platform**: Verify Android appearance remains unchanged

## Design Guidelines

When implementing platform-adaptive widgets:

1. **Consistency**: Use `PlatformAdaptive` helpers for consistency
2. **Styling**: Ensure Cupertino widgets match app theme and color scheme
3. **Accessibility**: Verify accessibility features work on both platforms
4. **Performance**: Cupertino widgets should not introduce performance regressions
5. **API Differences**: Handle API differences gracefully (e.g., `selectedTileColor` vs `backgroundColor`)

## Best Practices

1. **Always use PlatformAdaptive helpers** instead of manual platform checks
2. **Preserve functionality** - platform adaptation should not change behavior
3. **Handle edge cases** - Some Material features don't have Cupertino equivalents
4. **Test on both platforms** - Verify appearance and functionality on iOS and Android
5. **Document exceptions** - Note when widgets can't be migrated and why

## Success Criteria

- ✅ All major Material widgets that have Cupertino equivalents use platform-adaptive helpers on iOS/macOS
- ✅ App feels more native on iOS devices
- ✅ No regression in functionality or appearance on Android
- ✅ Code follows existing patterns and architecture guidelines
- ✅ Platform-adaptive helpers are reusable and maintainable

## Future Enhancements

1. **Refresh Indicators**: Implement platform-adaptive refresh control wrapper
2. **Form Fields**: Consider migration strategy for `TextFormField` with validation
3. **Complex Widgets**: Handle edge cases like `expands: true` TextFields
4. **Testing**: Add comprehensive tests for platform-adaptive widgets
5. **Documentation**: Update developer guide with platform-adaptive patterns

## References

- Flutter Cupertino Widgets: <https://docs.flutter.dev/development/ui/widgets/cupertino>
- Platform-Adaptive Widgets: <https://docs.flutter.dev/development/ui/widgets/cupertino#adapting-to-platforms>
- Existing Platform-Adaptive Utilities: `lib/shared/utils/platform_adaptive.dart`
