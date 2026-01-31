# Tech Stack

This document lists all the technologies, packages, and tools used in this Flutter application.

## Core Framework

- **Flutter** 3.38.9 (Dart 3.10.8)
- **Material 3** with `ColorScheme.fromSeed`
- **Cupertino** widgets for iOS-native feel

## State Management

- `flutter_bloc` ^9.1.1 - BLoC/Cubit pattern
- `equatable` ^2.0.5 - Value equality
- `freezed` ^3.2.3 - Immutable data classes

## Storage & Persistence

- `hive` ^2.2.0 - Encrypted local database
- `hive_flutter` ^1.1.0 - Flutter integration
- `flutter_secure_storage` ^10.0.0 - Keychain/Keystore access
- `shared_preferences` ^2.5.3 - Legacy migration support

## Networking & APIs

- `http` ^1.6.0 - REST API client
- `web_socket_channel` ^3.0.3 - WebSocket support
- `cached_network_image` ^3.4.1 - Image caching

## Firebase

- `firebase_core` ^4.2.1
- `firebase_auth` ^6.1.2
- `firebase_analytics` ^12.0.4
- `firebase_crashlytics` ^5.0.5
- `firebase_remote_config` ^6.1.2
- `firebase_database` ^12.1.0
- `firebase_ui_auth` ^3.0.0
- `firebase_ui_localizations` ^2.0.0
- `firebase_ui_oauth_google` ^2.0.0

## UI & Design

- `flutter_screenutil` ^5.9.3 - Responsive sizing
- `responsive_framework` ^1.5.1 - Layout breakpoints
- `fancy_shimmer_image` ^2.0.3 - Loading effects
- `skeletonizer` ^2.1.0+1 - Skeleton screens
- `google_fonts` ^6.2.1 - Typography
- `flutter_svg` ^2.2.2 - SVG rendering
- `fl_chart` ^1.1.1 - Charts and graphs
- `flex_color_picker` ^3.3.0 - Color picker for whiteboard
- `markdown` ^7.3.0 - Markdown parsing for editor

## Navigation & Routing

- `go_router` ^17.0.0 - Declarative routing
- `app_links` ^6.4.1 - Deep linking

## Maps

- `google_maps_flutter` ^2.14.0 - Google Maps
- `apple_maps_flutter` ^1.4.0 - Apple Maps (iOS)

## Authentication

- `local_auth` ^3.0.0 - Biometric authentication

## Dependency Injection

- `get_it` ^9.0.5 - Service locator

## Internationalization

- `intl` ^0.20.2 - Internationalization
- `flutter_localizations` - Flutter i18n support

## Development Tools

- `build_runner` ^2.10.4 - Code generation
- `bloc_test` ^10.0.0 - BLoC testing
- `golden_toolkit` ^0.15.0 - Golden tests
- `mocktail` ^1.0.4 - Mocking framework
- `file_length_lint` - Custom analyzer plugin

## Package Management

See `pubspec.yaml` for the complete list with exact version constraints.

## Related Documentation

- Dependency updates: `docs/DEPENDENCY_UPDATES.md`
- Architecture: `docs/architecture_details.md`
- Testing: `docs/testing_overview.md`
