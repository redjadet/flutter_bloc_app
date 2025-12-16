# Runtime Resilience Assessment

Findings on production-readiness patterns observed in the codebase, plus targeted suggestions.

## Network Error Handling

- **Findings**:
  - **Centralized Error Wrapper**: `NetworkGuard` (`lib/shared/utils/network_guard.dart`) provides consistent timeout handling, logging, and error mapping across HTTP requests. Used by `HuggingFaceApiClient`, `CountriesGraphqlRepository`, and `RestCounterRepository`.
  - **No Global HTTP Interceptor**: Each repository manually constructs headers (e.g., `HuggingFaceApiClient._headers()`, `RestCounterRepository._defaultHeaders`). No centralized interceptor for auth token injection, request/response transformation, or telemetry.
  - **Error Message Standardization**: `ErrorHandling` utility (`lib/shared/utils/error_handling.dart`) provides user-friendly error messages via `_getErrorMessage()` that maps network/timeout/HTTP status codes to localized strings, but this is only used in UI layer (snackbars).
  - **UI Error Display**: `CommonErrorView` (`lib/shared/widgets/common_error_view.dart`) provides consistent error UI with optional retry button. Used in search page, but not consistently across all features.
  - **Sync Error Visibility**: Background sync (`lib/shared/sync/background_sync_runner.dart`) logs errors and emits `SyncStatus.degraded`, but no user-visible indicator when sync fails. `SyncCycleSummary` tracks failures but isn't surfaced to users.
  - **Firebase Auth Integration**: Firebase-authenticated routes refresh via `GoRouterRefreshStream`, but non-Firebase HTTP clients don't automatically attach auth tokens or refresh expired tokens.
  - **Error Type Mapping**: Domain-specific exceptions (`ChatException`, `GraphqlDemoException`, `CounterError`) are created per-feature, but no shared base exception hierarchy or standardized error codes.

- **Suggestions** (Priority Order):
  1. **HIGH: Centralized Error Mapper** - Extract error parsing logic from `ErrorHandling._getErrorMessage()` into a reusable `NetworkErrorMapper` class that can be used by both UI layer and repository layer for consistent error handling. This is foundational and enables other improvements.
  2. **HIGH: Global Connectivity Indicator** - Add a `SyncStatusBanner` widget that displays when `SyncStatusCubit` emits `degraded` or `error`, showing "Sync issues detected" with a retry action. Integrate into `CommonPageLayout` or app scaffold. Improves user awareness of sync failures immediately.
  3. **MEDIUM: HTTP Client Interceptor Layer** - Create a `ResilientHttpClient` wrapper that:
     - Automatically injects auth tokens from `FirebaseAuth` or secure storage
     - Applies standardized headers (User-Agent, Content-Type, Accept)
     - Implements request/response interceptors for telemetry (duration, status codes, error rates)
     - Handles token refresh on 401 responses
     - Maps HTTP status codes to domain exceptions via a configurable `NetworkErrorMapper`
  4. **MEDIUM: Error Recovery Strategies** - Implement automatic retry for transient errors (5xx, timeouts) at the HTTP client level, with exponential backoff and jitter, while preserving manual retry via `CommonErrorView` for user-initiated actions. Can be done after `ResilientHttpClient` is in place.

## Retry Logic

- **Findings**:
  - **Background Sync Retry**: `background_sync_runner.dart` implements exponential backoff: `pow(2, retryCount.clamp(0, 5))` minutes (max 32 minutes). Retry state persisted via `PendingSyncRepository` with `nextRetryAt` timestamps. Operations pruned after 10 retries or 30 days (`PendingSyncRepository.prune()`).
  - **UI-Level Retry**: `CommonErrorView` provides opt-in `onRetry` callback. Used in search page (`SearchPage`) but not consistently across features. `ErrorHandling.handleCubitError()` supports retry via `SnackBarAction`, but requires manual implementation per cubit.
  - **No HTTP Client Retry**: `NetworkGuard` doesn't retry failed requests. Each repository must implement its own retry logic if needed. No idempotency safeguards (e.g., request deduplication, idempotency keys).
  - **Retry Metadata**: `SyncCycleSummary` tracks `operationsFailed` and `pullRemoteFailures`, but doesn't record retry attempt counts, last error messages, or failure reasons. Telemetry events include failure counts but not retry patterns.
  - **Cubit Retry Patterns**: Some cubits (e.g., `RemoteConfigCubit`, `DeepLinkCubit`) have explicit retry methods, but no standardized `RetryPolicy` helper for consistent behavior across features.

- **Suggestions** (Priority Order):
  1. **HIGH: Standardized Retry Policy** - Create a `RetryPolicy` class in `lib/shared/utils/` that:
     - Defines retry strategies (exponential backoff, linear, fixed delay)
     - Supports cancellation via `CancelToken`
     - Provides helper methods for cubits: `RetryPolicy.executeWithRetry<T>(Future<T> Function() action)`
     - Can be injected into cubits for consistent retry behavior (search, chat, charts, etc.)
     - This enables consistent retry patterns across the codebase before implementing HTTP-level retries.
  2. **HIGH: Retry Metadata in Sync** - Enhance `SyncCycleSummary` to include:
     - `retryAttemptsByEntity`: Map of entity type to average retry count
     - `lastErrorByEntity`: Map of entity type to most recent error message
     - `retrySuccessRate`: Percentage of operations that succeeded after retries
     - Provides visibility into retry effectiveness for debugging and monitoring.
  3. **MEDIUM: Resilient HTTP Client with Retry** - Extend `NetworkGuard` or create a new `RetryableHttpClient` that:
     - Automatically retries idempotent requests (GET, HEAD, OPTIONS) with exponential backoff + jitter
     - Requires explicit opt-in for non-idempotent requests (POST, PUT, DELETE) via a `RetryPolicy` parameter
     - Implements request deduplication for identical requests within a short time window
     - Supports configurable retry limits (default: 3 attempts) and backoff strategy
     - Logs retry attempts and final outcomes for telemetry
     - Builds on `RetryPolicy` foundation.
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
  - **No Shared Component**: While `AppMessage` is reusable, it doesn't provide a standard empty state pattern with icon + primary action button. Each feature implements its own layout.

- **Suggestions** (Priority Order):
  1. **HIGH: Shared Empty State Component** - Create `CommonEmptyState` widget in `lib/shared/widgets/` that:
     - Accepts `icon`, `title`, `message`, and optional `primaryAction` (button with callback)
     - Uses responsive spacing (`context.responsiveStatePadding`, `context.responsiveGapL`)
     - Follows Material 3 design with appropriate icon sizing and typography
     - Supports semantic labels for accessibility
     - Foundation for consistent empty states across features.
  2. **MEDIUM: Empty State Localization** - Ensure all empty state messages are localized via `AppLocalizations` (currently some use hardcoded strings like "No results found" in `SearchPage`). Fix localization gaps before feature audit.
  3. **MEDIUM: Feature Audit** - Review all list-based features (chat history, search, charts, profile gallery, Google Maps locations) to ensure:
     - Empty states are explicit (not relying on implicit UI)
     - Use `CommonEmptyState` for consistency
     - Include primary actions where appropriate (e.g., "Start Chatting", "Search Again", "Refresh Data")
     - Align with responsive spacing standards
     - Migrate features one at a time after `CommonEmptyState` is available.

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
  - **No Shared Primitives**: Each feature implements its own skeleton structure. No reusable skeleton components for common patterns (list tile, card, grid item).

- **Suggestions** (Priority Order):
  1. **HIGH: Shared Skeleton Primitives** - Create reusable skeleton components in `lib/shared/widgets/skeletons/`:
     - `SkeletonListTile`: For list-based UIs (chat history, search results)
     - `SkeletonCard`: For card-based layouts (profile cards, country cards)
     - `SkeletonGridItem`: For grid layouts (search results grid, gallery)
     - All use `Skeletonizer` with consistent `ShimmerEffect` theme (baseColor: `surfaceContainerHighest`, highlightColor: `surface`)
     - Foundation for consistent loading states.
  2. **HIGH: Accessibility** - Add semantic labels to skeleton widgets:
     - `Semantics(label: 'Loading content', child: Skeletonizer(...))`
     - Ensure screen readers announce loading state appropriately
     - Should be implemented alongside skeleton primitives.
  3. **MEDIUM: Loading Strategy** - Establish a guideline:
     - Use skeletons for data fetches >150ms (reduces layout jank, provides better UX)
     - Use spinners (`CommonLoadingWidget`) for quick operations (<150ms) or when skeleton structure doesn't match final layout
     - Prefer skeletons for list/grid views to maintain layout stability
     - Document in `AGENTS.md` or architecture docs for consistency.
  4. **MEDIUM: Feature Migration** - Migrate data-heavy screens to use skeletons (one feature at a time):
     - `SearchPage`: Replace `CommonLoadingWidget` with `SkeletonGridItem` grid (highest impact)
     - `ChatListView`: Replace spinner with `SkeletonListTile` for contact list
     - `GraphqlDemoPage`: Add skeleton for country list loading
     - `ProfilePage`: Add skeleton for gallery loading
  5. **LOW: Performance Optimization** - Ensure skeletons don't impact performance by using `RepaintBoundary` around skeleton widgets (already done in some places like `CounterPage`). Apply during migration as needed.
