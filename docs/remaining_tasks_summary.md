# Remaining Tasks Summary

Quick reference for remaining compile-time safety tasks.

## Task Overview

| Task | Priority | Risk | Time | Status |
| :--- | :--- | :--- | :--- | :--- |
| Convert Equatable to Freezed | High | Medium | 2-4h/state | ✅ 6/6 Complete |
| Convert to Sealed Classes | Medium | Medium-High | 3-5h/hierarchy | ✅ 2/2 Complete |
| Sealed Event Types | Medium | Medium-High | 2-3h/BLoC | ✅ Complete (No BLoCs with events) |
| Null-Safety Review | Low | Low | 1-2h | ✅ Complete |
| Custom Code Generators | Low | Low | 1-2 weeks | ✅ Partial (Script + Package) |
| IDE Plugins | Low | Low | 2-4 weeks | ✅ Partial (Snippets + Guide) |

## Quick Start

1. **Read**: [Remaining Tasks Plan](remaining_tasks_plan.md) - Complete implementation plan
2. **Choose Task**: Start with highest priority (Equatable → Freezed)
3. **Follow Guide**: Use specific conversion guides
4. **Test**: Run tests after each change
5. **Review**: Code review before merging

## Detailed Guides

- [Remaining Tasks Plan](remaining_tasks_plan.md) - Complete plan with step-by-step instructions
- [Equatable to Freezed Conversion](equatable_to_freezed_conversion.md) - Detailed conversion guide
- [Sealed Classes Migration](sealed_classes_migration.md) - Sealed class conversion guide

## States to Convert

### Equatable → Freezed

1. ✅ `SearchState` - `lib/features/search/presentation/search_state.dart` - **COMPLETED**
2. ✅ `WebsocketState` - `lib/features/websocket/presentation/cubit/websocket_state.dart` - **COMPLETED**
3. ✅ `ProfileState` - `lib/features/profile/presentation/cubit/profile_state.dart` - **COMPLETED**
4. ✅ `ChartState` - `lib/features/chart/presentation/cubit/chart_state.dart` - **COMPLETED**
5. ✅ `MapSampleState` - `lib/features/google_maps/presentation/cubit/map_sample_state.dart` - **COMPLETED**
6. ✅ `AppInfoState` - `lib/features/settings/presentation/cubits/app_info_cubit.dart` - **COMPLETED**

### Abstract → Sealed

1. ✅ `RemoteConfigState` - `lib/features/remote_config/presentation/cubit/remote_config_state.dart` - **COMPLETED**
2. ✅ `ChatListState` - `lib/features/chat/presentation/chat_list_state.dart` - **COMPLETED**

## Implementation Order

1. ✅ Start with `SearchState` (Equatable → Freezed)
2. ✅ Then `WebsocketState` (Equatable → Freezed)
3. ✅ Then `ProfileState` (Equatable → Freezed)
4. ✅ Then `ChartState` (Equatable → Freezed)
5. ✅ Then `MapSampleState` (Equatable → Freezed)
6. ✅ Then `AppInfoState` (Equatable → Freezed)
7. ✅ `RemoteConfigState` (Abstract → Sealed) - **COMPLETED**
8. ✅ `ChatListState` (Abstract → Sealed) - **COMPLETED**
9. ✅ Review null-safety annotations - **COMPLETED** (No issues found)
10. ✅ Sealed Event Types - **COMPLETED** (No BLoCs with events found, only Cubits)
11. ⏳ Optional: Custom code generators
12. ⏳ Optional: IDE plugins

## Success Criteria

- [x] All Equatable states converted to Freezed ✅
- [x] All state hierarchies converted to sealed classes ✅
- [x] All event types reviewed (no BLoCs with events found) ✅
- [x] Null-safety reviewed (no issues found) ✅
- [x] All tests pass ✅
- [x] No analyzer warnings ✅
- [x] Code coverage maintained ✅
- [x] No runtime errors ✅

## Related Documentation

- [State Management Choice](state_management_choice.md) - Overall rationale
- [Compile-Time Safety Usage](compile_time_safety_usage.md) - Usage guide
- [Implementation Summary](compile_time_safety_implementation_summary.md) - What's done
