# Google Maps Integration

This document describes how Google Maps is integrated in this repository,
including integration of Google Maps API for location tracking, how to
configure required platform keys, and where to extend the feature.

## Scope in This Project

- Feature path: `lib/features/google_maps/`
- Route: `AppRoutes.googleMapsPath` (`/google-maps`)
- Route registration: `lib/app/router/route_groups.dart`
- Deferred page entry: `lib/app/router/deferred_pages/google_maps_page.dart`
- DI registration: `lib/core/di/injector_registrations.dart`

The map feature is implemented as a clean-architecture feature module:

- Domain: `MapLocation`, `MapCoordinate`, `MapLocationRepository`
- Data: `SampleMapLocationRepository` (in-memory sample POIs)
- Presentation: `MapSampleCubit`, `MapSampleState`, map widgets/page

## Platform Strategy

The app intentionally uses different map providers by platform:

- iOS: Apple Maps (`apple_maps_flutter`)
- Android: Google Maps (`google_maps_flutter`)
- Web/Desktop: map sample page is shown as unsupported

Selection logic is in
`lib/features/google_maps/presentation/pages/google_maps_sample_page.dart`.

## Dependencies

Declared in `pubspec.yaml`:

- `google_maps_flutter: ^2.14.0`
- `apple_maps_flutter: ^1.4.0`

## Routing and Lazy Loading

Google Maps is lazy-loaded with deferred imports to reduce startup bundle size:

- Deferred import and route:
  `lib/app/router/route_groups.dart`
- Deferred page builder:
  `lib/app/router/deferred_pages/google_maps_page.dart`

The deferred builder creates `MapSampleCubit` with DI and runs
`loadLocations()` via `BlocProviderHelpers.withAsyncInit(...)`.

## Dependency Injection

`MapLocationRepository` is registered in
`lib/core/di/injector_registrations.dart`:

- `MapLocationRepository -> SampleMapLocationRepository`

If you replace sample locations with remote/local data, only this binding and
its concrete data implementation should change.

## Android Setup

Android map key is provided through a manifest placeholder:

- Placeholder setup: `android/app/build.gradle`
- Manifest meta-data: `android/app/src/main/AndroidManifest.xml`

`build.gradle` uses:

```gradle
manifestPlaceholders["GOOGLE_MAPS_API_KEY"] =
    project.findProperty("GOOGLE_MAPS_ANDROID_API_KEY")
    ?: "YOUR_ANDROID_GOOGLE_MAPS_API_KEY"
```

`AndroidManifest.xml` consumes it:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${GOOGLE_MAPS_API_KEY}" />
```

### Recommended local setup

Add your key to local Gradle properties (do not commit secrets):

```properties
# ~/.gradle/gradle.properties (recommended)
GOOGLE_MAPS_ANDROID_API_KEY=your_android_maps_key
```

You can also pass it from CI with `-PGOOGLE_MAPS_ANDROID_API_KEY=...`.

## iOS Setup

iOS key is read from `Info.plist` key `GMSApiKey` and initialized in
`ios/Runner/AppDelegate.swift` with `GMSServices.provideAPIKey(...)`.

Current plist entry:

- File: `ios/Runner/Info.plist`
- Key: `GMSApiKey`

Replace the placeholder value locally with your real key for iOS builds.

Note: this sample page renders Apple Maps on iOS, so missing Google key does
not block the page in current behavior.

## Runtime Key Validation and User Feedback

The map page checks key availability at runtime for non-iOS-map mode:

- Dart service: `lib/shared/platform/native_platform_service.dart`
- Android channel check:
  `android/app/src/main/kotlin/com/example/flutter_bloc_app/MainActivity.kt`
- iOS channel check: `ios/Runner/AppDelegate.swift`

If key is missing/placeholder, UI shows a dedicated missing-key message instead
of failing silently (`GoogleMapsMissingKeyMessage`).

## Feature Behavior

Main flow:

1. Route opens deferred map page.
2. `MapSampleCubit.loadLocations()` loads sample locations.
3. Cubit emits markers, selected marker, and camera position.
4. Page renders controls, map, and location list.
5. Selecting/focusing a location syncs marker selection and camera movement.

## Integration of Google Maps API for Location Tracking

Current implementation status:

- The map feature currently tracks selected sample locations on the map
  (marker selection + camera focus).
- Live GPS-based user location tracking is not yet implemented in this module.

How to implement real location tracking with this architecture:

1. Add a domain contract (for example, `LocationTrackingRepository` or
   `LocationTrackingService`) in `lib/features/google_maps/domain/`.
2. Implement platform data source in data layer (permission + location stream).
3. Register implementation in DI (`injector_registrations.dart`).
4. Extend `MapSampleCubit` state to include current user location and tracking
   status.
5. Update map widgets to render tracked location marker/camera updates from
   cubit state.

Guideline: keep location permission and stream logic out of widgets; widgets
should only render state emitted by the cubit.

Key files:

- Page: `lib/features/google_maps/presentation/pages/google_maps_sample_page.dart`
- Cubit: `lib/features/google_maps/presentation/cubit/map_sample_cubit.dart`
- State: `lib/features/google_maps/presentation/cubit/map_sample_state.dart`
- Shared map view shell:
  `lib/features/google_maps/presentation/widgets/map_sample_map_view.dart`
- Google map widget:
  `lib/features/google_maps/presentation/widgets/google_maps_view.dart`
- Apple map widget:
  `lib/features/google_maps/presentation/widgets/apple_maps_view.dart`
- Camera abstraction:
  `lib/features/google_maps/presentation/widgets/map_camera_controller.dart`

## Architecture Notes for Future Changes

When extending maps, keep these boundaries:

- Domain layer remains Flutter-agnostic.
- Data layer owns API/DTO/persistence details.
- Cubit owns business/state transitions.
- Widgets stay focused on rendering, theming, and interaction wiring.

If you add live places or backend data:

1. Add/extend repository contract in domain.
2. Implement data source/repository in data layer.
3. Update DI registration.
4. Keep map UI widgets simple and Cubit-driven.

## Testing

Existing tests for this feature are under `test/features/google_maps/`,
including:

- Cubit tests
- Repository tests
- Page/widget tests
- Map state manager tests

Run focused tests:

```bash
flutter test test/features/google_maps/
```

Run full quality checks:

```bash
./bin/checklist
```

## Troubleshooting

- Blank map / missing map tiles on Android:
  - verify `GOOGLE_MAPS_ANDROID_API_KEY` is set
  - verify Android Maps SDK is enabled for the key
- iOS map page disabled for Google mode:
  - check Xcode logs for AppDelegate warning messages
  - current sample route is Apple Maps on iOS by design
- Page shows unsupported message:
  - expected on web/desktop for this sample page
- Markers not shown:
  - check `SampleMapLocationRepository` output and Cubit load flow

## Related Docs

- `docs/tech_stack.md`
- `docs/new_developer_guide.md`
- `docs/security_and_secrets.md`
- `docs/architecture_details.md`
- `docs/adr/0003-deferred-feature-loading.md`
