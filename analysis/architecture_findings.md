# Clean Architecture Findings

## High Severity

### Presentation Depends on Data Implementation — **Resolved**

- Location: `lib/features/remote_config/presentation/cubit/remote_config_cubit.dart`
- Resolution: `RemoteConfigCubit` now consumes the `RemoteConfigService` domain contract, and DI binds the interface to the concrete repository.

### Domain Leaks Flutter UI Types — **Resolved**

- Locations: `lib/features/settings/domain/locale_repository.dart`, `lib/features/settings/domain/theme_repository.dart`
- Resolution: Introduced domain value objects (`AppLocale`, `ThemePreference`) and updated cubits/data adapters to translate between Flutter types and domain models.

## Medium Severity

### Domain Coupled to Routing Layer — **Resolved**

- Location: `lib/features/deeplink/domain/deep_link_target.dart`
- Resolution: Removed the `AppRoutes` dependency from the domain enum and introduced a presentation-side extension (`lib/features/deeplink/presentation/deep_link_target_extensions.dart`) that translates targets to router locations.

### Domain Imports Flutter Foundation — **Resolved**

- Location: `lib/features/chat/domain/chat_conversation.dart`
- Resolution: Removed the unused `package:flutter/foundation.dart` import so the domain layer now stays Flutter-agnostic and only relies on Freezed.
