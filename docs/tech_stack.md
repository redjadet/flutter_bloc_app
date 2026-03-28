# Tech Stack

This document summarizes the current stack used by the app. It is an overview,
not a replacement for `pubspec.yaml`.

## Source of truth

- Dependency constraints: [`pubspec.yaml`](../pubspec.yaml)
- Pinned Flutter toolchain: [README](../README.md) and
  [`.github/workflows/ci.yml`](../.github/workflows/ci.yml)

## Toolchain and app shell

| Area | Current state |
| --- | --- |
| Flutter | `3.41.6` |
| Dart | `3.11.4` |
| App entrypoints | `lib/main_dev.dart`, `lib/main_staging.dart`, `lib/main_prod.dart` |
| Shared bootstrap | `lib/main_bootstrap.dart` |
| App shell | `lib/app.dart`, `lib/app/app_scope.dart`, `lib/core/app_config.dart` |

## Core architecture

| Concern | Libraries or approach |
| --- | --- |
| State management | `flutter_bloc` `^9.1.1`, `equatable` `^2.0.5`, `freezed` `^3.2.3`, `freezed_annotation` `^3.1.0` |
| Dependency injection | `get_it` `^9.0.5` |
| Routing | `go_router` `^17.0.0` |
| Localization | `intl` `^0.20.2`, `flutter_localizations` |
| Architecture style | Clean Architecture with `Domain -> Data -> Presentation` layering |

## Persistence and offline-first support

| Concern | Libraries or approach |
| --- | --- |
| Local persistence | `hive` `^2.2.0`, `hive_flutter` `^1.1.0` |
| Secure storage | `flutter_secure_storage` `^10.0.0` |
| Legacy migration support | `shared_preferences` `^2.5.3` |
| Sync infrastructure | Pending sync queue and background sync under `lib/shared/sync/` |
| Offline-first docs | [Offline-First Adoption Guide](offline_first/adoption_guide.md) |

## Networking and backend integrations

| Concern | Libraries or approach |
| --- | --- |
| REST client | `dio` `^5.8.0` |
| Typed REST APIs | `retrofit` `^4.9.0`, `retrofit_generator` `^10.0.0` |
| WebSocket | `web_socket_channel` `^3.0.3` |
| Firebase | `firebase_core`, `firebase_auth`, `firebase_analytics`, `firebase_crashlytics`, `firebase_database`, `firebase_messaging`, `firebase_remote_config`, `cloud_firestore`, `cloud_functions` |
| Firebase UI | `firebase_ui_auth` `^3.0.1`, `firebase_ui_localizations` `^2.0.0`, `firebase_ui_oauth_google` `^2.0.0` |
| Supabase | `supabase_flutter` `^2.8.0` |
| Deep links | `app_links` `^6.4.1` |
| Backend auth retry and token injection | Shared Dio interceptors under `lib/shared/http/` |

## UI, design, and feature packages

| Concern | Libraries or approach |
| --- | --- |
| Design system and theming | Material 3, Cupertino, `mix` `^1.7.0` |
| Responsive layout | `flutter_screenutil` `^5.9.3`, `responsive_framework` `^1.5.1` |
| Typography | `google_fonts` `^8.0.0` plus bundled font assets |
| Images and SVG | `cached_network_image` `^3.4.1`, `fancy_shimmer_image` `^2.0.3`, `flutter_svg` `^2.2.2`, `skeletonizer` `^2.1.0+1` |
| Charts and visualization | `fl_chart` `^1.1.1` |
| Media and device features | `image_picker` `^1.2.1`, `local_auth` `^3.0.0`, `device_info_plus` `^12.3.0`, `package_info_plus` `^9.0.0` |
| Maps | `google_maps_flutter` `^2.14.0`, `apple_maps_flutter` `^1.4.0` |
| AI demos | `genui` `^0.7.0`, `genui_google_generative_ai` `^0.7.0` |
| Other feature packages | `in_app_purchase` `^3.2.3`, `wallet_connect_v2` `^1.0.0`, `flutter_tts` `^4.2.0`, `markdown` `^7.3.0`, `flex_color_picker` `^3.3.0` |

## Testing and developer tooling

| Concern | Libraries or approach |
| --- | --- |
| Unit and bloc testing | `flutter_test`, `bloc_test` `^10.0.0`, `mocktail` `^1.0.4`, `fake_async` `^1.3.3` |
| Golden tests | `golden_toolkit` `^0.15.0` |
| Integration tests | `integration_test` plus repo scripts under `bin/` and `tool/` |
| Code generation | `build_runner`, `json_serializable`, `freezed`, `retrofit_generator` |
| Static analysis | `very_good_analysis` `^10.2.0`, `flutter_lints` `^6.0.0`, custom lint packages in `custom_lints/` |

## Platform-Specific Dependencies

| Package or concern | Notes |
| --- | --- |
| `apple_maps_flutter` | iOS-only map provider used on Apple platforms. |
| `google_maps_flutter` | Requires platform API key configuration where Google Maps is used. |
| `window_manager` | Desktop-only window management support. |
| `local_auth` | Uses platform biometric APIs on iOS and Android. |
| Firebase config files | `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, and `macos/Runner/GoogleService-Info.plist` when applicable. |

Platform-specific setup details belong in:

- [Firebase Setup](firebase_setup.md)
- [Deployment](deployment.md)
- [Google Maps Integration](google_maps_integration.md)

## Notes on maintenance

- Keep this document focused on major stack choices and package groups.
- Update `pubspec.yaml` first; then refresh this summary when the stack has
  materially changed.
- Do not duplicate secrets, Firebase setup, or release steps here. Reference
  the dedicated docs instead.

## Related docs

- [Architecture Details](architecture_details.md)
- [Feature Overview](feature_overview.md)
- [Testing Overview](testing_overview.md)
- [Security and Secrets](security_and_secrets.md)
