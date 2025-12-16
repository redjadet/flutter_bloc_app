# Runtime Resilience Assessment

Findings on production-readiness patterns observed in the codebase, plus targeted suggestions.

## Implementation Status

**All HIGH and MEDIUM priority tasks have been completed:**

✅ **Network Error Handling:**

- Centralized Error Mapper (`NetworkErrorMapper`) - Extracted and reusable
- Global Connectivity Indicator (`SyncStatusBanner`) - Available for integration
- HTTP Client Interceptor Layer (`ResilientHttpClient`) - Auth tokens, headers, telemetry, error mapping
- Error Recovery Strategies - Automatic retry with exponential backoff and jitter

✅ **Retry Logic:**

- Standardized Retry Policy (`RetryPolicy`) - Ready for use across features
- Retry Metadata in Sync - Enhanced `SyncCycleSummary` with retry metrics
- Resilient HTTP Client with Retry - Automatic retry for transient errors

✅ **Empty State:**

- Shared Empty State Component (`CommonEmptyState`) - Available for use
- Empty State Localization - Fixed all hardcoded strings with proper i18n
- Feature Audit - Migrated Search, Chat, Chart, and Google Maps to use CommonEmptyState

✅ **Loading Skeleton:**

- Shared Skeleton Primitives (`SkeletonListTile`, `SkeletonCard`, `SkeletonGridItem`) - Ready for migration
- Accessibility - Semantic labels integrated into all skeleton widgets
- Loading Strategy - Established comprehensive guidelines for skeleton vs spinner usage
- Feature Migration - Migrated ChatListView, GraphqlDemoPage, and ProfilePage to use skeletons

**All planned resilience improvements have been fully implemented and tested.**

## Network Error Handling

- **Findings**:
  - **Centralized Error Wrapper**: `NetworkGuard` (`lib/shared/utils/network_guard.dart`) provides consistent timeout handling, logging, and error mapping across HTTP requests. Used by `HuggingFaceApiClient`, `CountriesGraphqlRepository`, and `RestCounterRepository`.
  - **No Global HTTP Interceptor**: Each repository manually constructs headers (e.g., `HuggingFaceApiClient._headers()`, `RestCounterRepository._defaultHeaders`). No centralized interceptor for auth token injection, request/response transformation, or telemetry.
  - **Error Message Standardization**: `ErrorHandling` utility (`lib/shared/utils/error_handling.dart`) delegates to `NetworkErrorMapper` (`lib/shared/utils/network_error_mapper.dart`) for consistent error message mapping. `NetworkErrorMapper` can be used by both UI layer and repository layer for consistent error handling.
  - **UI Error Display**: `CommonErrorView` (`lib/shared/widgets/common_error_view.dart`) provides consistent error UI with optional retry button. Used in search page, but not consistently across all features.
  - **Sync Error Visibility**: Background sync (`lib/shared/sync/background_sync_runner.dart`) logs errors and emits `SyncStatus.degraded`. `SyncStatusBanner` widget (`lib/shared/widgets/sync_status_banner.dart`) now displays when sync is degraded, showing "Sync Issues Detected" with retry action. `SyncCycleSummary` tracks failures and retry metrics (retryAttemptsByEntity, lastErrorByEntity, retrySuccessRate) for debugging and monitoring.
  - **Firebase Auth Integration**: Firebase-authenticated routes refresh via `GoRouterRefreshStream`, but non-Firebase HTTP clients don't automatically attach auth tokens or refresh expired tokens.
  - **Error Type Mapping**: Domain-specific exceptions (`ChatException`, `GraphqlDemoException`, `CounterError`) are created per-feature, but no shared base exception hierarchy or standardized error codes.

- **Suggestions** (Priority Order):
  1. ✅ **HIGH: Centralized Error Mapper** - **COMPLETED** - Extracted error parsing logic from `ErrorHandling._getErrorMessage()` into `NetworkErrorMapper` class (`lib/shared/utils/network_error_mapper.dart`). Provides `getErrorMessage()`, `getMessageForStatusCode()`, `isNetworkError()`, `isTimeoutError()`, and `isTransientError()` methods. `ErrorHandling` now delegates to `NetworkErrorMapper` for consistent error handling across UI and repository layers.
  2. ✅ **HIGH: Global Connectivity Indicator** - **COMPLETED** - Created `SyncStatusBanner` widget (`lib/shared/widgets/sync_status_banner.dart`) that displays when `SyncStatusCubit` emits `degraded` status, showing "Sync Issues Detected" with retry action. Exported in `widgets.dart` for easy integration into `CommonPageLayout` or app scaffold.
  3. ✅ **MEDIUM: HTTP Client Interceptor Layer** - **COMPLETED** - Created `ResilientHttpClient` wrapper (`lib/shared/http/resilient_http_client.dart`) that:
     - Automatically injects auth tokens from `FirebaseAuth` with token refresh on 401 responses
     - Applies standardized headers (User-Agent from dynamic version, Content-Type, Accept, Accept-Encoding)
     - Implements request/response telemetry logging (duration, status codes, error rates)
     - Maps HTTP status codes to domain exceptions via `NetworkErrorMapper`
     - Includes automatic retry for transient errors with exponential backoff and jitter
  4. ✅ **MEDIUM: Error Recovery Strategies** - **COMPLETED** - Implemented automatic retry for transient errors (5xx, timeouts, network errors) in `ResilientHttpClient` with:
     - Exponential backoff with jitter to prevent thundering herd
     - Configurable retry limits (default: 3 attempts)
     - Cancellation support via `CancelToken`
     - Manual retry preserved via `CommonErrorView` for user-initiated actions
     - Integrates with `RetryPolicy` for consistent retry behavior

## Retry Logic

- **Findings**:
  - **Background Sync Retry**: `background_sync_runner.dart` implements exponential backoff: `pow(2, retryCount.clamp(0, 5))` minutes (max 32 minutes). Retry state persisted via `PendingSyncRepository` with `nextRetryAt` timestamps. Operations pruned after 10 retries or 30 days (`PendingSyncRepository.prune()`).
  - **UI-Level Retry**: `CommonErrorView` provides opt-in `onRetry` callback. Used in search page (`SearchPage`) but not consistently across features. `ErrorHandling.handleCubitError()` supports retry via `SnackBarAction`, but requires manual implementation per cubit.
  - **No HTTP Client Retry**: `NetworkGuard` doesn't retry failed requests. Each repository must implement its own retry logic if needed. No idempotency safeguards (e.g., request deduplication, idempotency keys).
  - **Retry Metadata**: `SyncCycleSummary` now tracks retry metrics including `retryAttemptsByEntity` (average retry count per entity), `lastErrorByEntity` (most recent error per entity), and `retrySuccessRate` (percentage of operations that succeeded after retries). Telemetry events include retry patterns for debugging and monitoring.
  - **Cubit Retry Patterns**: `RetryPolicy` class (`lib/shared/utils/retry_policy.dart`) provides standardized retry behavior with exponential/linear/fixed strategies, cancellation support, and helper methods. Can be injected into cubits for consistent retry behavior across features (search, chat, charts, etc.).

- **Suggestions** (Priority Order):
  1. ✅ **HIGH: Standardized Retry Policy** - **COMPLETED** - Created `RetryPolicy` class (`lib/shared/utils/retry_policy.dart`) with:
     - Retry strategies: exponential backoff, linear, fixed delay
     - Cancellation support via `CancelToken`
     - `executeWithRetry<T>()` helper method for cubits
     - Predefined policies: `RetryPolicy.transientErrors` and `RetryPolicy.networkErrors`
     - Jitter support to prevent thundering herd
     - Exported in `utils.dart` for use across features
  2. ✅ **HIGH: Retry Metadata in Sync** - **COMPLETED** - Enhanced `SyncCycleSummary` (`lib/shared/sync/background_sync_runner.dart`) with:
     - `retryAttemptsByEntity`: Map of entity type to average retry count
     - `lastErrorByEntity`: Map of entity type to most recent error message
     - `retrySuccessRate`: Percentage of operations that succeeded after retries (0.0 to 1.0)
     - Retry metrics tracked during `runSyncCycle()` and included in telemetry events
     - Provides visibility into retry effectiveness for debugging and monitoring
  3. ✅ **MEDIUM: Resilient HTTP Client with Retry** - **COMPLETED** - Created `ResilientHttpClient` that:
     - Automatically retries transient errors (5xx, timeouts, network errors) with exponential backoff + jitter
     - Applies retry to all HTTP methods with configurable limits (default: 3 attempts)
     - Includes request deduplication through proper async handling
     - Logs retry attempts and final outcomes for telemetry
     - Builds on `RetryPolicy` foundation for consistent retry behavior across the app
  4. **LOW: Retry UI Feedback** - When automatic retries occur, show a subtle indicator (e.g., "Retrying..." snackbar) so users understand delays aren't due to app freezing. Nice-to-have UX improvement.

## Empty State

- **Findings**:
  - **Explicit Empty States**:
    - `WebsocketMessageList` uses `AppMessage` widget for empty state (`lib/features/websocket/presentation/widgets/websocket_message_list.dart`)
    - `ChatHistoryEmptyState` widget exists (`lib/features/chat/presentation/widgets/chat_history_empty_state.dart`) with localized message
    - `ChatMessageList` shows inline empty state with `l10n.chatEmptyState` text
    - `GraphqlDemoPage` uses `AppMessage` for empty countries list
  - **Implicit Empty States**:
    - `ChatListView` checks `contacts.isEmpty` and shows inline text, but no dedicated widget
    - `SearchPage` shows "No results found" text when `!hasResults`, but no icon or action
    - `ChartPage` uses `ChartMessageList` for empty state, but no primary action to guide users
  - **Inconsistent Patterns**: Some features use `AppMessage`, others use inline `Text` widgets, and some use `CommonErrorView` (which is meant for errors, not empty states).
  - **Shared Component Available**: `CommonEmptyState` widget (`lib/shared/widgets/common_empty_state.dart`) provides a standard empty state pattern with icon, title, message, and optional primary action button. Exported in `widgets.dart` for use across features.

- **Suggestions** (Priority Order):
  1. ✅ **HIGH: Shared Empty State Component** - **COMPLETED** - Created `CommonEmptyState` widget (`lib/shared/widgets/common_empty_state.dart`) with:
     - Accepts `icon`, `title`, `message`, and optional `primaryAction` (button with callback)
     - Uses responsive spacing (`context.responsiveStatePadding`, `context.responsiveGapL`)
     - Follows Material 3 design with appropriate icon sizing and typography
     - Includes semantic labels for accessibility (`Semantics(label: 'Empty state: $message')`)
     - Exported in `widgets.dart` for use across features
  2. ✅ **MEDIUM: Empty State Localization** - **COMPLETED** - Fixed hardcoded strings in empty states:
     - SearchPage: Replaced "No results found" with `CommonEmptyState` using localized messages
     - ChartPage: Updated error state to use localized `chartPageError` message
     - All empty state messages now use `AppLocalizations` for proper i18n support
  3. ✅ **MEDIUM: Feature Audit** - **COMPLETED** - Migrated all major list-based features to use `CommonEmptyState`:
     - SearchPage: Uses `CommonEmptyState` for no results
     - ChatListView: Uses `CommonEmptyState` for empty chat history
     - ChartPage: Uses `CommonEmptyState` for empty/error states with localized messages
     - GoogleMapsLocationList: Uses `CommonEmptyState` for empty location lists
     - All features now have explicit empty states with consistent UI and responsive spacing

## Loading Skeleton

- **Findings**:
  - **Skeleton Implementation**:
    - `ChartLoadingList` uses `Skeletonizer` with `ShimmerEffect` for chart loading (`lib/features/chart/presentation/widgets/chart_loading_list.dart`)
    - `CounterPage` uses `_CounterSkeletonizedBody` with conditional `Skeletonizer.enabled` based on loading state
    - `CountdownBarContent` applies skeleton when `isLoading` is true
  - **Spinner Usage**:
    - `CommonLoadingWidget` uses `CircularProgressIndicator` (spinner) - used in search page, chat list, graphql demo
    - `ViewStatusSwitcher` uses `CommonLoadingWidget` by default for loading states
    - Search results, chat history, profile gallery use spinners instead of skeletons
  - **Image Loading**: `FancyShimmerImage` in `SearchResultsGrid` provides shimmer for image loading, but grid items themselves don't have skeleton placeholders during initial load
  - **Shared Primitives Available**: Reusable skeleton components in `lib/shared/widgets/skeletons/`:
    - `SkeletonListTile`: For list-based UIs with optional avatar and subtitle
    - `SkeletonCard`: For card-based layouts with optional image, title, subtitle
    - `SkeletonGridItem`: For grid layouts with configurable aspect ratio
    - All include semantic labels for accessibility and use consistent `ShimmerEffect` theme
    - Exported via `skeletons.dart` and `widgets.dart`

- **Suggestions** (Priority Order):
  1. ✅ **HIGH: Shared Skeleton Primitives** - **COMPLETED** - Created reusable skeleton components in `lib/shared/widgets/skeletons/`:
     - `SkeletonListTile`: For list-based UIs (chat history, search results) with optional avatar and subtitle
     - `SkeletonCard`: For card-based layouts (profile cards, country cards) with optional image, title, subtitle
     - `SkeletonGridItem`: For grid layouts (search results grid, gallery) with configurable aspect ratio and overlay support
     - All use `Skeletonizer` with consistent `ShimmerEffect` theme (baseColor: `surfaceContainerHigh`, highlightColor: `surface`)
     - Exported via `skeletons.dart` and `widgets.dart`
  2. ✅ **HIGH: Accessibility** - **COMPLETED** - Added semantic labels to all skeleton widgets:
     - `Semantics(label: 'Loading content', child: Skeletonizer(...))` in all three skeleton primitives
     - Screen readers will announce loading state appropriately
     - Integrated into skeleton primitives from the start
  3. ✅ **MEDIUM: Loading Strategy** - **COMPLETED** - Established comprehensive guidelines:
     - Use skeletons for data fetches >150ms to reduce layout jank and provide better UX
     - Use spinners (`CommonLoadingWidget`) for quick operations (<150ms) or unpredictable layouts
     - Prefer skeletons for list/grid views to maintain layout stability during loading
     - Documented guidelines with available skeleton components (`SkeletonListTile`, `SkeletonCard`, `SkeletonGridItem`)
  4. ✅ **MEDIUM: Feature Migration** - **COMPLETED** - Migrated key data-heavy screens to use skeletons:
     - `ChatListView`: Replaced spinner with `SkeletonListTile` for contact list loading
     - `GraphqlDemoPage`: Added `SkeletonCard` for country list loading states
     - `ProfilePage`: Added `SkeletonGridItem` for gallery loading states
     - `SearchPage`: Maintained spinner due to fast loading times (<150ms guideline)
     - All migrated features now provide better UX with skeleton placeholders
  5. **LOW: Performance Optimization** - Ensure skeletons don't impact performance by using `RepaintBoundary` around skeleton widgets (already done in some places like `CounterPage`). Apply during migration as needed.
