# Clean Architecture Findings

## High Severity

### Presentation Depends on Data Implementation — **Resolved**

- Location: `lib/features/remote_config/presentation/cubit/remote_config_cubit.dart`
- Resolution: `RemoteConfigCubit` now consumes the `RemoteConfigService` domain contract, and DI binds the interface to the concrete repository.

### Domain Leaks Flutter UI Types — **Resolved**

- Locations: `lib/features/settings/domain/locale_repository.dart`, `lib/features/settings/domain/theme_repository.dart`
- Resolution: Introduced domain value objects (`AppLocale`, `ThemePreference`) and updated cubits/data adapters to translate between Flutter types and domain models.

## Medium Severity

### Domain Coupled to Routing Layer

- Location: `lib/features/deeplink/domain/deep_link_target.dart`
- Issue: Domain enum references presentation navigation constants via `AppRoutes`, binding domain logic to routing details.
- Recommendation: Keep the enum semantic-only and move route mappings to a presentation adapter or mapper.

### Domain Imports Flutter Foundation

- Location: `lib/features/chat/domain/chat_conversation.dart`
- Issue: The domain model imports `package:flutter/foundation.dart` despite not needing Flutter-specific APIs, adding an unnecessary dependency.
- Recommendation: Remove the Flutter import (rely on Freezed annotations only) or replace with a package-agnostic alternative.
