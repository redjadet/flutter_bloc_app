# Shared Utilities Documentation

## Overview

The `lib/shared/` directory contains reusable utilities, widgets, and services used across multiple features. This document describes the purpose and organization of each category.

## Directory Structure

```text
lib/shared/
├── extensions/          # BuildContext extensions and responsive utilities
├── platform/           # Platform-specific implementations
├── responsive/         # Responsive design configuration
├── services/           # Cross-cutting services
├── storage/            # Storage abstractions and implementations
├── ui/                 # UI constants and view status
├── utils/              # Utility functions and helpers
└── widgets/            # Reusable widgets
```

## Categories

### 1. Extensions (`lib/shared/extensions/`)

**Purpose:** BuildContext extensions and responsive design utilities.

**Contents:**

- `build_context_l10n.dart` - Localization extensions for `BuildContext`
- `responsive.dart` - Responsive design extensions (spacing, typography, layout)
- `responsive/` - Detailed responsive utilities:
  - `helpers.dart` - Helper functions for responsive calculations
  - `responsive_buttons.dart` - Platform-adaptive button extensions
  - `responsive_grid.dart` - Grid layout utilities
  - `responsive_layout.dart` - Layout helpers (max width, padding)
  - `responsive_metrics.dart` - Screen metrics and breakpoints
  - `responsive_spacing.dart` - Spacing utilities (gaps, padding)
  - `responsive_typography.dart` - Typography scaling utilities

**Usage Example:**

```dart
// Responsive spacing
SizedBox(height: context.responsiveGapL)

// Responsive typography
Text('Title', style: TextStyle(fontSize: context.responsiveHeadlineSize))

// Platform-adaptive buttons
PlatformAdaptive.filledButton(context: context, onPressed: handle, child: Text('Action'))
```

### 2. Platform (`lib/shared/platform/`)

**Purpose:** Platform-specific implementations and abstractions.

**Contents:**

- `biometric_authenticator.dart` - Biometric authentication (Face ID, Touch ID, fingerprint)
- `native_platform_service.dart` - Native platform information via MethodChannel
- `secure_secret_storage.dart` - Secure storage for secrets (API keys, tokens)

**Usage Example:**

```dart
final authenticator = getIt<BiometricAuthenticator>();
final isAvailable = await authenticator.isAvailable();
if (isAvailable) {
  final success = await authenticator.authenticate(reason: 'Authenticate to continue');
}
```

### 3. Responsive (`lib/shared/responsive/`)

**Purpose:** Responsive design configuration and scope management.

**Contents:**

- `responsive_config.dart` - Responsive configuration (breakpoints, scaling factors)
- `responsive_scope.dart` - InheritedWidget for responsive configuration
- `responsive.dart` - Main responsive utilities export

**Usage Example:**

```dart
ResponsiveScope(
  config: ResponsiveConfig.defaultConfig,
  child: MyApp(),
)
```

### 4. Services (`lib/shared/services/`)

**Purpose:** Cross-cutting services used throughout the app.

**Contents:**

- `error_notification_service.dart` - Service for displaying error notifications (snackbars, dialogs)

**Usage Example:**

```dart
final errorService = getIt<ErrorNotificationService>();
errorService.showError('Something went wrong');
```

### 5. Storage (`lib/shared/storage/`)

**Purpose:** Storage abstractions and implementations for local data persistence.

**Contents:**

- `hive_key_manager.dart` - Manages encryption keys for Hive boxes
- `hive_repository_base.dart` - Base class for Hive-backed repositories
- `hive_service.dart` - Service for opening and managing Hive boxes
- `migration_helpers.dart` - Utilities for data migration and normalization
- `shared_preferences_migration_service.dart` - Migrates data from SharedPreferences to Hive

**Usage Example:**

```dart
// Extend HiveRepositoryBase for Hive-backed repositories
class MyRepository extends HiveRepositoryBase implements MyRepositoryInterface {
  @override
  String get boxName => 'my_box';

  Future<void> saveData(String data) async {
    final box = await getBox();
    await box.put('key', data);
  }
}
```

### 6. UI (`lib/shared/ui/`)

**Purpose:** UI constants and view status definitions.

**Contents:**

- `ui_constants.dart` - App-wide UI constants (colors, sizes, durations)
- `view_status.dart` - View status enum (loading, success, error, empty)

**Usage Example:**

```dart
// View status for state management
enum ViewStatus { loading, success, error, empty }

// UI constants
const kDefaultPadding = EdgeInsets.all(16.0);
const kAnimationDuration = Duration(milliseconds: 300);
```

### 7. Utils (`lib/shared/utils/`)

**Purpose:** Utility functions and helpers for common operations.

**Contents:**

- `bloc_provider_helpers.dart` - Helpers for accessing BLoC/Cubit from context
- `cubit_async_operations.dart` - Utilities for async operations in Cubits
- `cubit_helpers.dart` - General Cubit helper functions
- `cubit_state_emission_mixin.dart` - Mixin for safe state emission in Cubits
- `error_handling.dart` - Error handling utilities and domain failures
- `http_request_failure.dart` - HTTP failure exception with statusCode (and optional retryAfter) so callers can differentiate 401 vs 503, etc.
- `initialization_guard.dart` - Safe initialization wrapper for critical operations
- `isolate_json.dart` - JSON decoding/encoding with automatic isolate offloading for large payloads (>8KB)
- `isolate_samples.dart` - Examples of isolate usage for heavy computations
- `logger.dart` - App-wide logging utility
- `navigation.dart` - Navigation helper functions
- `network_guard.dart` - Network connectivity checking utilities
- `platform_adaptive.dart` - Platform-adaptive widget utilities
- `storage_guard.dart` - Storage availability checking utilities
- `websocket_guard.dart` - WebSocket connectivity checking utilities
- `retry_policy.dart` - Standardized retry with backoff and cancellation for non-HTTP async work

### Reliability and retries

- **ResilientHttpClient** (`lib/shared/http/resilient_http_client.dart`): Use for **HTTP** requests. It provides automatic retries for transient failures, 401 token refresh, network check before send, and telemetry. All HTTP entry points should go through this client (or its extensions) with an explicit timeout. The **resilient_http_client_extensions** (`getMapped` / `postMapped`) throw [HttpRequestFailure](lib/shared/utils/http_request_failure.dart) for status ≥ 400 so repositories and cubits receive a statusCode and can show accurate messages (e.g. 503 "Service temporarily unavailable" vs 401 "Sign in again"). [NetworkErrorMapper](lib/shared/utils/network_error_mapper.dart) maps status codes and `HttpRequestFailure` to user-facing messages and [AppErrorCode](lib/shared/utils/error_codes.dart) (including `serviceUnavailable` for 503).
- **RetryPolicy** (`lib/shared/utils/retry_policy.dart`): Use for **non-HTTP** retriable work (e.g. repository load, sync steps, external SDK calls). It supports exponential/linear/fixed backoff, jitter, and `CancelToken` so cubits can cancel in-flight retries in `close()`.

When to use which:

| Use case | Use |
| ---------- | ----- |
| HTTP GET/POST (API, REST) | ResilientHttpClient + timeout extension |
| Single async repository call that may fail transiently | RetryPolicy.executeWithRetry with CancelToken from cubit |
| Stream or watch | No RetryPolicy; handle errors in listener and optionally restart |

**Timeouts:** Use explicit timeouts for all HTTP calls. The resilient client extensions accept a `timeout` parameter (default 30s). Recommended: 15–30s for typical API calls, longer for uploads or slow endpoints. Configure per call site; for enterprise tuning, consider a shared config (e.g. `HttpClientOptions`) injected via DI.

**Circuit breaker (optional):** For high-traffic or enterprise builds, use [CircuitBreaker](lib/shared/http/circuit_breaker.dart) to fail fast when an endpoint is repeatedly failing. Wrap repository or HTTP calls with `CircuitBreaker(key: 'endpoint-name').execute(() => ...)`. Enable via feature-flag or build config. Use when protecting the backend from thundering herd is important.

Example: cubit that retries a one-off load and cancels on close:

```dart
class MyCubit extends Cubit<MyState> {
  MyCubit({required MyRepository repo}) : _repo = repo, super(MyState.initial());
  final MyRepository _repo;
  CancelToken? _loadToken;

  Future<void> load() async {
    _loadToken?.cancel();
    _loadToken = CancelToken();
    await CubitExceptionHandler.executeAsync(
      operation: () => RetryPolicy.transientErrors.executeWithRetry(
        action: _repo.load,
        cancelToken: _loadToken,
        shouldRetry: (e) => e is TimeoutException || NetworkErrorMapper.isNetworkError(e),
      ),
      isAlive: () => !isClosed,
      onSuccess: (data) { if (!isClosed) emit(state.copyWith(data: data)); },
      onError: (msg) { if (!isClosed) emit(state.copyWith(error: msg)); },
      logContext: 'MyCubit.load',
    );
  }

  @override
  Future<void> close() {
    _loadToken?.cancel();
    return super.close();
  }
}
```

**Usage Example:**

```dart
// Safe Cubit state emission
class MyCubit extends Cubit<MyState> with CubitStateEmissionMixin {
  void updateState() {
    emitSafely(MyState.updated()); // ✅ Safe emission
  }
}

// Standardized async error handling
await CubitExceptionHandler.executeAsync(
  operation: _repository.load,
  onSuccess: (data) {
    if (isClosed) return;
    emit(state.copyWith(data: data));
  },
  onError: (message) {
    if (isClosed) return;
    emit(state.copyWith(errorMessage: message));
  },
  logContext: 'MyCubit.load',
);

// Error handling
try {
  await riskyOperation();
} on DomainFailure catch (failure) {
  handleDomainFailure(failure);
} catch (error, stackTrace) {
  handleUnexpectedError(error, stackTrace);
}

// Safe initialization
await InitializationGuard.executeSafely(
  () => criticalOperation(),
  context: 'MyFeature',
  failureMessage: 'Failed to initialize feature',
);

// JSON decoding/encoding with isolate offloading (for payloads >8KB)
import 'package:flutter_bloc_app/shared/utils/isolate_json.dart';

final Map<String, dynamic> decoded = await decodeJsonMap(response.body);
final List<dynamic> list = await decodeJsonList(storedJson);
final String encoded = await encodeJsonIsolate(object); // For size estimation
```

### 8. Widgets (`lib/shared/widgets/`)

**Purpose:** Reusable widgets used across multiple features.

**Contents:**

- `app_message.dart` - App-wide message display widget
- `common_app_bar.dart` - Common app bar implementation
- `common_error_view.dart` - Standardized error display widget
- `common_form_field.dart` - Reusable form field widgets (`CommonFormField`, `CommonSearchField`)
- `common_dropdown_field.dart` - Platform-adaptive dropdown widget (`CommonDropdownField`, `DropdownLabelPosition`)
- `common_input_decoration_helpers.dart` - Input decoration helper functions (`buildCommonInputDecoration`, `buildFilledInputDecoration`)
- `common_loading_widget.dart` - Standardized loading indicator
- `common_page_layout.dart` - Common page layout wrapper
- `flavor_badge.dart` - Flavor indicator badge (dev, staging, prod)
- `cached_network_image_widget.dart` - Cached network image widget with automatic caching and error handling
- `message_bubble.dart` - Chat message bubble widget
- `resilient_svg_asset_image.dart` - SVG image widget with fallback support
- `root_aware_back_button.dart` - Back button that respects root navigation

**Usage Example:**

```dart
// Common error view
CommonErrorView(
  message: 'Failed to load data',
  onRetry: () => loadData(),
)

// Common loading widget
CommonLoadingWidget(message: 'Loading...')

// Cached network image
CachedNetworkImageWidget(
  imageUrl: 'https://example.com/image.jpg',
  fit: BoxFit.cover,
  width: 100,
  height: 100,
)

// Resilient SVG image
ResilientSvgAssetImage(
  assetPath: 'assets/images/icon.svg',
  width: 100,
  height: 100,
)
```

## Best Practices

### When to Add to Shared

Add utilities to `lib/shared/` when:

1. **Used by multiple features** - Not specific to a single feature
2. **Reusable across contexts** - Can be used in different scenarios
3. **Cross-cutting concerns** - Logging, error handling, navigation, etc.
4. **Platform abstractions** - Platform-specific implementations

### When NOT to Add to Shared

Don't add to `lib/shared/` when:

1. **Feature-specific** - Only used by one feature (keep in feature directory)
2. **Tightly coupled** - Strongly coupled to specific feature logic
3. **Experimental** - Still being developed/tested (keep in feature first)

### Organization Guidelines

1. **Group related utilities** - Keep related functions/classes together
2. **Use barrel files** - Export related utilities from single files (e.g., `utils.dart`, `widgets.dart`)
3. **Document complex utilities** - Add "why" comments and usage examples
4. **Keep it lean** - Don't add utilities "just in case" - wait until actually needed

## Import Patterns

### Recommended Imports

```dart
// Import entire shared module
import 'package:flutter_bloc_app/shared/shared.dart';

// Or import specific categories
import 'package:flutter_bloc_app/shared/utils/utils.dart';
import 'package:flutter_bloc_app/shared/widgets/widgets.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
```

### Feature-Specific Imports

```dart
// Import only what you need
import 'package:flutter_bloc_app/shared/utils/error_handling.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
```

## Summary

- **Extensions:** BuildContext extensions and responsive utilities
- **Platform:** Platform-specific implementations (biometric, native services)
- **Services:** Cross-cutting services (error notifications)
- **Storage:** Storage abstractions (Hive, migration utilities)
- **UI:** UI constants and view status definitions
- **Utils:** Utility functions (error handling, navigation, guards)
- **Widgets:** Reusable widgets (error views, loading indicators, form fields)

Each category serves a specific purpose and follows clear organization principles to maintain code clarity and reusability.
