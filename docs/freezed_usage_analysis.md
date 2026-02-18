# Freezed Usage Analysis

Analysis of where Freezed is already used and where it is suitable to adopt: *"Immutable states (`freezed` > `Equatable`)."*

## Why use Freezed with BLoC?

BLoC and Cubit emit **immutable state**; the UI rebuilds when state **changes** (by identity or equality). Freezed fits this model and is the recommended way to define state in this project.

- **Immutable state** — BLoC/Cubit should never mutate state in place; they `emit(newState)`. Freezed generates immutable classes, so you cannot accidentally mutate a state object. Every transition is an explicit new instance.
- **Equality and rebuilds** — `BlocBuilder` and `BlocSelector` avoid unnecessary rebuilds when the new state is **equal** to the old one. Freezed generates `==` and `hashCode` from your fields, so equality is correct and consistent. No manual `props` or missing fields.
- **Sealed union states** — Many cubits have states like Initial / Loading / Loaded / Error. With Freezed you model these as a single sealed type with multiple factories (e.g. `RemoteConfigState.initial()`, `.loading()`, `.loaded(...)`, `.error(message)`). Exhaustive `.when()` / `.map()` and Dart 3 `switch` give type-safe handling and the compiler warns if you forget a case.
- **copyWith for emissions** — Updating one field (e.g. `state.copyWith(count: state.count + 1)`) is common. Freezed generates a type-safe `copyWith`; you avoid bugs from hand-written copyWith (wrong null handling, missing fields).
- **Less boilerplate** — No manual `props`, `==`, `hashCode`, or `copyWith`. Add or rename a field in the factory, run `build_runner`, and generated code stays in sync. This reduces mistakes and keeps the focus on business logic in the cubit.

For conversion steps and patterns, see [Equatable to Freezed Conversion Guide](equatable_to_freezed_conversion.md).

## Benefits of Using Freezed

Using Freezed for state and domain models reduces boilerplate, improves type safety, and keeps immutability consistent. Benefits include:

- **Generated code** — `copyWith`, `==`, `hashCode`, `toString` are generated, avoiding manual `props` and copyWith bugs.
- **Union types** — Sealed state (e.g. Initial / Loading / Loaded / Error) as one class with multiple factories and exhaustive `.when()` / `switch`.
- **Immutability** — Generated types are immutable by default; fewer accidental mutations.
- **Consistency** — Same pattern across the codebase; less cognitive load and easier refactors.

For a fuller list and conversion steps, see [Equatable to Freezed Conversion Guide](equatable_to_freezed_conversion.md#benefits-of-freezed).

## Current Freezed Usage

The project already uses Freezed in many places:

| Location | Type | Notes |
| --------- | ------ | -------- |
| `lib/features/chat/presentation/chat_state.dart` | State | Single state class with many fields |
| `lib/features/search/presentation/search_state.dart` | State | |
| `lib/features/counter/presentation/counter_state.dart` | State | |
| `lib/features/counter/domain/counter_snapshot.dart` | Domain | |
| `lib/features/counter/domain/counter_error.dart` | Domain (sealed union) | `CounterError` – sealed with `.when()` |
| `lib/features/genui_demo/presentation/cubit/genui_demo_state.dart` | State | Union-style (GenuiDemoState) |
| `lib/features/profile/presentation/cubit/profile_state.dart` | State | |
| `lib/features/scapes/presentation/scapes_state.dart` | State | |
| `lib/features/chart/presentation/cubit/chart_state.dart` | State | (part of chart_cubit) |
| `lib/features/graphql_demo/presentation/graphql_demo_state.dart` | State | |
| `lib/features/graphql_demo/domain/graphql_country.dart` | Domain | GraphqlCountry + GraphqlContinent |
| `lib/features/websocket/presentation/cubit/websocket_state.dart` | State | |
| `lib/features/search/domain/search_result.dart` | Domain | |
| `lib/features/todo_list/domain/todo_item.dart` | Domain | TodoItem (freezed) |
| `lib/shared/sync/sync_operation.dart` | Shared | SyncOperation |
| `lib/shared/sync/presentation/sync_status_state.dart` | State | SyncStatusState (sync status cubit) |
| `lib/features/remote_config/presentation/cubit/remote_config_state.dart` | State (union) | RemoteConfigState |
| `lib/features/chat/presentation/chat_list_state.dart` | State (union) | ChatListState |
| `lib/features/deeplink/presentation/deep_link_state.dart` | State (union) | DeepLinkState |
| `lib/features/auth/presentation/cubit/register/register_state.dart` | State | RegisterState + RegisterFieldState |
| `lib/features/chat/domain/chat_contact.dart` | Domain | ChatContact |
| `lib/features/profile/domain/profile_user.dart` | Domain | ProfileUser + ProfileImage |
| `lib/features/google_maps/domain/map_location.dart` | Domain | MapLocation |
| `lib/features/google_maps/domain/map_coordinate.dart` | Domain | MapCoordinate |
| `lib/features/websocket/domain/websocket_message.dart` | Domain | WebsocketMessage |
| `lib/features/websocket/domain/websocket_connection_state.dart` | Domain (union) | WebsocketConnectionState |
| `lib/features/settings/domain/app_info.dart` | Domain | AppInfo |
| `lib/features/settings/domain/app_locale.dart` | Domain | AppLocale |
| `lib/features/remote_config/domain/remote_config_snapshot.dart` | Domain | RemoteConfigSnapshot |
| `lib/features/walletconnect_auth/domain/wallet_user_profile.dart` | Domain | WalletUserProfile |
| `lib/features/walletconnect_auth/domain/wallet_address.dart` | Domain | WalletAddress |
| `lib/features/walletconnect_auth/domain/nft_metadata.dart` | Domain | NftMetadata |
| `lib/features/auth/presentation/cubit/register/register_country_option.dart` | Presentation | CountryOption |
| `lib/shared/sync/sync_cycle_summary.dart` | Shared | SyncCycleSummary |

Build and tooling already account for Freezed (e.g. `**/*.freezed.dart` in scripts and `analysis_options.yaml`). Conversion guide: [equatable_to_freezed_conversion.md](equatable_to_freezed_conversion.md).

---

## Recommended: Use Freezed Where Suitable

### Tier 1 – High value (sealed / cubit states and state-like classes)

These are **sealed state hierarchies** or **large state classes** that benefit most from Freezed (union types, generated `copyWith`, equality, `when`/`map`).

| File | Current | Recommendation |
| ------ | --------- | ----------------- |
| `lib/features/remote_config/presentation/cubit/remote_config_state.dart` | ~~sealed + 4 subclasses~~ | **Done.** Freezed union: `RemoteConfigState.initial()`, `.loading()`, `.loaded(...)`, `.error(message)`. |
| `lib/features/chat/presentation/chat_list_state.dart` | ~~sealed + 4 subclasses~~ | **Done.** Freezed union: `ChatListState.initial()`, `.loading()`, `.loaded(contacts)`, `.error(message)`. |
| `lib/features/deeplink/presentation/deep_link_state.dart` | ~~sealed + 4 subclasses~~ | **Done.** Freezed union: `DeepLinkState.idle()`, `.loading()`, `.navigate(target, origin)`, `.error(message)`. |
| `lib/features/auth/presentation/cubit/register/register_state.dart` | ~~RegisterState + RegisterFieldState (Equatable)~~ | **Done.** Both converted to Freezed; validation getters in private constructor. |
| `lib/shared/sync/presentation/sync_status_cubit.dart` | ~~`SyncStatusState` (Equatable, `copyWith`, getters)~~ | **Done.** State moved to `sync_status_state.dart` with Freezed; `isOnline` / `isSyncing` in private constructor. |

**Note:** `lib/shared/utils/sealed_state_helpers.dart` extends `Equatable`. Freezed-generated union types do not extend Equatable (they implement `==`/`hashCode`). After migrating sealed states to Freezed, either:

- Use Freezed’s generated `.when()` / `.map()` and Dart 3 `switch` on the union, and stop using `SealedStateHelpers` for those states, or
- Generalize the extension (e.g. `extension SealedStateHelpers<T> on T`) if you still need a shared helper for non-Freezed sealed types.

---

### Tier 2 – Domain and shared data models

Use Freezed for **immutable domain/shared types** that have (or would benefit from) `copyWith`, equality, and consistent serialization patterns.

| File | Current | Recommendation |
| ------ | --------- | ----------------- |
| `lib/features/chat/domain/chat_contact.dart` | ~~Equatable + manual `copyWith`~~ | **Done.** Freezed. |
| `lib/features/profile/domain/profile_user.dart` | ~~ProfileUser + ProfileImage (Equatable)~~ | **Done.** Freezed for both. |
| `lib/features/google_maps/domain/map_location.dart` | ~~Equatable~~ | **Done.** Freezed. |
| `lib/features/google_maps/domain/map_coordinate.dart` | ~~Equatable~~ | **Done.** Freezed. |
| `lib/features/websocket/domain/websocket_message.dart` | ~~Equatable~~ | **Done.** Freezed. |
| `lib/features/websocket/domain/websocket_connection_state.dart` | ~~Equatable~~ | **Done.** Freezed union with `.disconnected()`, `.connecting()`, `.connected()`, `.error(message)` and `status` / `errorMessage` getters. |
| `lib/features/settings/domain/app_info.dart` | ~~Equatable~~ | **Done.** Freezed. |
| `lib/features/settings/domain/app_locale.dart` | ~~Equatable~~ | **Done.** Freezed; `tag` and `fromTag` in private constructor. |
| `lib/features/remote_config/domain/remote_config_snapshot.dart` | ~~Equatable~~ | **Done.** Freezed; `hasValues` and `getValue` in private constructor. |
| `lib/features/walletconnect_auth/domain/wallet_user_profile.dart` | ~~Equatable~~ | **Done.** Freezed. |
| `lib/features/walletconnect_auth/domain/wallet_address.dart` | ~~Equatable~~ | **Done.** Freezed; `isValid`, `truncated`, `toString` in private constructor. |
| `lib/features/walletconnect_auth/domain/nft_metadata.dart` | ~~Equatable~~ | **Done.** Freezed. |
| `lib/features/auth/presentation/cubit/register/register_country_option.dart` | ~~CountryOption (Equatable)~~ | **Done.** Freezed; `flagEmoji` and `defaultCountry` preserved. |
| `lib/shared/sync/sync_cycle_summary.dart` | ~~Equatable + long manual `copyWith`~~ | **Done.** Freezed. |

---

### Tier 3 – Presentation view models / local UI state (optional)

These are **private or feature-local** Equatable classes used for BlocSelector/view data. Converting them to Freezed is optional (lower ROI, more churn).

| File | Class | Note |
| ------ | -------- | ------ |
| `lib/features/calculator/presentation/pages/calculator_page.dart` | ~~`_DisplayData`~~ | **Done.** Freezed. |
| `lib/features/chart/presentation/pages/chart_page.dart` | ~~`_ChartViewData`~~ | **Done.** Freezed. |
| `lib/features/google_maps/presentation/pages/google_maps_sample_page.dart` | ~~`_MapBodyData`~~ | **Done.** Freezed. |
| `lib/features/google_maps/presentation/pages/google_maps_sample_sections.dart` | ~~`_ControlsViewModel`, `_LocationListViewModel`~~ | **Done.** Freezed (in main page file). |
| `lib/features/graphql_demo/presentation/graphql_demo_view_models.dart` | ~~`GraphqlFilterBarData`, `GraphqlBodyData`~~ | **Done.** Freezed. |
| `lib/features/remote_config/presentation/widgets/awesome_feature_widget.dart` | ~~`_FeatureEnabledData`~~ | **Done.** Freezed. |
| `lib/features/settings/presentation/widgets/remote_config_view_data.dart` | ~~`_RemoteConfigViewData`~~ | **Done.** Freezed; `RemoteConfigViewData` + `RemoteConfigViewStatus` in standalone file; `fromState` and getters preserved. |
| `lib/features/settings/presentation/widgets/app_info_section.dart` | ~~`_AppInfoViewData`~~ | **Done.** Freezed. |
| `lib/features/chat/presentation/widgets/chat_input_bar.dart` | ~~`_SendButtonData`~~ | **Done.** Freezed. |
| `lib/features/chat/presentation/widgets/chat_history_sheet.dart` | ~~`_HistorySheetData`~~ | **Done.** Freezed. |
| `lib/features/websocket/presentation/pages/websocket_demo_page.dart` | ~~`_WebsocketViewData`~~ | **Done.** Freezed. |

---

## Summary

- **Use Freezed for:**
  - All new immutable state and domain models.
  - Existing sealed cubit states (RemoteConfig, ChatList, DeepLink) as union types.
  - Large or frequently copied state (Register, SyncStatus) and domain models with `copyWith` (ChatContact, SyncCycleSummary, etc.).

- **Optional:**
  - Private/view Equatable classes (Tier 3); migrate when touching those files or when you want consistent patterns.

- **After migrating sealed states to Freezed:**
  - Prefer Freezed’s `.when()`/`.map()` and Dart 3 `switch`; adjust or relax `SealedStateHelpers` if it still needs to support non-Freezed sealed types.

- **Workflow:**
  - Follow [equatable_to_freezed_conversion.md](equatable_to_freezed_conversion.md).
  - Run `dart run build_runner build --delete-conflicting-outputs` after changes.
  - Run `./bin/checklist` and tests (and coverage script if present) before commit.
  - The checklist runs `tool/check_freezed_preferred.sh`: it fails if any **class** in `lib/` extends or mixes in `Equatable` (Freezed is preferred for state/domain models). To allowlist a specific line, add `// check-ignore: reason` on that line or the line above.
