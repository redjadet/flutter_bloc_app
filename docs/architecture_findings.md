# Clean Architecture Findings

This document tracks architecture violations found during codebase analysis and their resolution status. Findings are categorized by severity and include specific locations, impact assessment, and recommendations.

## Summary

- **Resolved**: 6 findings (all high and medium severity items addressed)
- **Open**: 0 findings (composition-root `getIt` usage in `app_scope.dart` is intentional)

## High Severity

### Presentation Depends on Data Implementation — **Resolved**

- **Location**: `lib/features/remote_config/presentation/cubit/remote_config_cubit.dart`
- **Finding**: Presentation layer directly depended on data layer implementations, violating the dependency rule.
- **Impact**: Tight coupling between layers, making it difficult to swap implementations or test in isolation.
- **Resolution**: `RemoteConfigCubit` now consumes the `RemoteConfigService` domain contract, and DI binds the interface to the concrete repository. The cubit depends only on the domain abstraction.

### Domain Leaks Flutter UI Types — **Resolved**

- **Locations**: `lib/features/settings/domain/locale_repository.dart`, `lib/features/settings/domain/theme_repository.dart`
- **Finding**: Domain layer used Flutter-specific types (`Locale`, `ThemeMode`) directly, making the domain layer platform-dependent.
- **Impact**: Domain layer was not Flutter-agnostic, violating clean architecture principles and making it impossible to reuse domain logic outside Flutter.
- **Resolution**: Introduced domain value objects (`AppLocale`, `ThemePreference`) and updated cubits/data adapters to translate between Flutter types and domain models. The domain layer now remains platform-agnostic.

## Medium Severity

### Domain Coupled to Routing Layer — **Resolved**

- **Location**: `lib/features/deeplink/domain/deep_link_target.dart`
- **Finding**: Domain enum directly referenced `AppRoutes` from the routing layer, creating a dependency from domain to presentation.
- **Impact**: Domain layer was aware of presentation concerns, violating the dependency rule.
- **Resolution**: Removed the `AppRoutes` dependency from the domain enum and introduced a presentation-side extension (`lib/features/deeplink/presentation/deep_link_target_extensions.dart`) that translates targets to router locations. Routing decisions now stay in the presentation layer.

### Domain Imports Flutter Foundation — **Resolved**

- **Location**: `lib/features/chat/domain/chat_conversation.dart`
- **Finding**: Domain model imported `package:flutter/foundation.dart` unnecessarily.
- **Impact**: Domain layer had a Flutter dependency even though it wasn't needed, reducing portability.
- **Resolution**: Removed the unused `package:flutter/foundation.dart` import so the domain layer now stays Flutter-agnostic and only relies on Freezed.

### Duplicate Hive Initialization in DI — **Resolved**

- **Locations**:
  - `lib/core/di/injector_registrations.dart` (line 80 in `_registerStorageServices`)
  - `lib/core/di/injector.dart` (line 50 in `configureDependencies`)
- **Finding**: `HiveService.initialize()` was invoked twice during startup: once in `_registerStorageServices()` and again in `configureDependencies()`. While `HiveService.initialize()` has an internal guard (`if (_initialized) return;`) making it idempotent, the duplicate call was redundant and obscured the single bootstrap path.
- **Resolution**: The initialization call from `_registerStorageServices()` was removed, and only the one in `configureDependencies()` inside `InitializationGuard` was kept. This centralizes initialization and makes the bootstrap path explicit.

### Widget-Level `getIt` Lookups — **Partially Resolved**

- **Locations**:
  - Addressed: `lib/features/deeplink/presentation/deep_link_listener.dart`, `lib/features/settings/presentation/pages/settings_page.dart`, `lib/features/search/presentation/pages/search_page.dart`, `lib/features/counter/presentation/pages/counter_page.dart`, `lib/features/counter/presentation/widgets/counter_sync_banner.dart` all now receive dependencies via constructor injection.
  - Intentional: `lib/app/app_scope.dart` remains the composition root and uses `getIt` by design for top-level wiring.
- **Finding**: Widgets and presentation components pull dependencies directly from the service locator (`getIt`) instead of receiving them via constructor injection or through the widget tree.
- **Impact**:
  - Makes widgets harder to test in isolation (requires mocking `getIt` registrations)
  - Blurs dependency ownership and makes it unclear what a widget needs
  - Reduces flexibility for providing different implementations in different contexts
- **Status**: Resolved for feature widgets; dependency ownership is explicit and tests can inject fakes without touching the service locator.
- **Recommendation**:
  - Keep composition-root usage (`app_scope.dart`, routing) documented as intentional.
  - Maintain constructor injection for new widgets/cubits to preserve testability and layer boundaries.
