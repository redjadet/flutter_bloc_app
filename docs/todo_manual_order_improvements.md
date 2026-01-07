# Todo Feature: Manual Order Normalization Improvements

## Overview

This document analyzes the uncommitted code quality improvements made to the todo feature, specifically focusing on manual order normalization when items are deleted or updated.

## Changes Summary

### Files Modified

1. `lib/features/todo_list/presentation/cubit/todo_list_cubit_methods.dart` (+40 lines)
2. `test/features/todo_list/presentation/cubit/todo_list_cubit_test.dart` (+55 lines)

**Total**: 95 lines added

## Problem Addressed

### Issue: Manual Order Data Integrity

When items are deleted or new items are added while in manual sort mode, the `manualOrder` map could become inconsistent:

1. **Stale Entries**: Deleted items would remain in `manualOrder`, causing memory leaks and potential bugs
2. **Missing Entries**: New items added from external sources (e.g., repository watch stream) wouldn't have manual order entries
3. **Inconsistent State**: The manual order map could contain IDs for items that no longer exist

### Example Scenario

```dart
// Initial state: items [A, B, C] with manualOrder {A: 0, B: 1, C: 2}
// User deletes item B
// Problem: manualOrder still contains {A: 0, B: 1, C: 2}
// Expected: manualOrder should be {A: 0, C: 1} (or {A: 0, C: 2} if preserving gaps)
```

## Solution Implemented

### 1. New Method: `_normalizeManualOrder`

**Location**: `lib/features/todo_list/presentation/cubit/todo_list_cubit_methods.dart:33-61`

**Purpose**: Normalizes the manual order map to match the current items list.

**Algorithm**:

1. Returns empty map if items list is empty
2. Creates a set of current item IDs for fast lookup
3. Preserves existing order entries for items that still exist
4. Tracks maximum order value
5. Adds new items (not in manual order) to the end with incrementing order values

**Key Features**:

- **Removes stale entries**: Deleted items are automatically removed
- **Preserves existing order**: Items that exist keep their current order values
- **Adds new items**: New items get appended with order values greater than max
- **Maintains consistency**: Ensures manual order always matches current items

### 2. Updated `emitOptimisticUpdate`

**Location**: `lib/features/todo_list/presentation/cubit/todo_list_cubit_methods.dart:63-79`

**Changes**:

- Added manual order normalization when in manual sort mode
- Only normalizes if `sortOrder == TodoSortOrder.manual`
- Preserves manual order unchanged for other sort modes

**Impact**: When items are deleted optimistically (before repository confirmation), the manual order is immediately cleaned up.

### 3. Updated `onItemsUpdated`

**Location**: `lib/features/todo_list/presentation/cubit/todo_list_cubit_methods.dart:81-97`

**Changes**:

- Added manual order normalization when in manual sort mode
- Ensures consistency when items are updated from the repository watch stream

**Impact**: When items are added/removed from external sources (e.g., sync from another device), manual order stays consistent.

## Test Coverage

### Test 1: Delete Removes ID from Manual Order

**Location**: `test/features/todo_list/presentation/cubit/todo_list_cubit_test.dart:239-261`

**What it tests**:

- When an item is deleted in manual sort mode
- The deleted item's ID is removed from `manualOrder`
- Other items' order is preserved

**Assertion**:

```dart
expect(s.manualOrder.containsKey('a'), false)
```

### Test 2: New Items Appended to Manual Order

**Location**: `test/features/todo_list/presentation/cubit/todo_list_cubit_test.dart:263-290`

**What it tests**:

- When a new item is added while in manual sort mode
- The new item gets added to `manualOrder` with an order value greater than existing max
- Existing items' order is preserved

**Assertion**:

```dart
expect(cubit.state.manualOrder.containsKey('c'), isTrue);
expect(cubit.state.manualOrder['c']!, greaterThan(maxOrder));
```

## Code Quality Benefits

### 1. **Data Integrity**

- Manual order map always reflects current items
- No stale entries for deleted items
- No missing entries for new items

### 2. **Memory Efficiency**

- Prevents memory leaks from accumulating deleted item IDs
- Keeps manual order map size proportional to items list

### 3. **Consistency**

- Manual order stays synchronized with items list
- Works correctly with optimistic updates and repository streams
- Handles edge cases (empty lists, new items, deleted items)

### 4. **Maintainability**

- Centralized normalization logic in `_normalizeManualOrder`
- Clear separation of concerns
- Easy to test and verify

### 5. **Robustness**

- Handles concurrent operations (items deleted while being reordered)
- Works with external updates (repository watch stream)
- Prevents state corruption from race conditions

## Edge Cases Handled

1. **Empty items list**: Returns empty map
2. **All items deleted**: Manual order becomes empty
3. **New items added externally**: Automatically get order values
4. **Mixed operations**: Deletions and additions handled correctly
5. **Non-manual sort mode**: Manual order preserved but not normalized (only when needed)

## Performance Considerations

- **Time Complexity**: O(n) where n is the number of items
  - Iterates through manual order entries: O(m) where m is manual order size
  - Iterates through items: O(n)
  - Overall: O(n + m) ≈ O(n) in typical cases

- **Space Complexity**: O(n) for the normalized map

- **Optimization**: Only called when `sortOrder == TodoSortOrder.manual`, avoiding unnecessary work

## Related Improvements

This change complements other recent improvements:

- Race condition fixes in batch operations
- Index validation in `reorderItems`
- Item existence checks in `toggleItemSelection`
- Filter/search guard in `reorderItems` (prevents reordering while filtered)

## Conclusion

These changes significantly improve the robustness and data integrity of the manual sort feature. The normalization ensures that the manual order map always accurately reflects the current state of items, preventing bugs and memory issues that could occur from stale or missing entries.
