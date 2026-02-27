# Camera and Gallery Demo Integration Plan

## Objective

Add a new **Camera & Gallery Demo** that is reachable from the Example page and
lets users:

- capture a photo with the camera,
- pick a photo from gallery,
- preview the selected image on the same page,
- handle cancel, permission denial, and Android process-death recovery.

Target platforms: **iOS + Android**.

## Scope and Non-Goals

### In scope

- One new demo route/page.
- Clean architecture feature module (domain/data/presentation).
- Cubit-driven state management.
- Localization for all user-facing strings.
- Platform permission plist/manifest updates needed for photo capture/pick.
- Tests (cubit + widget + navigation wiring impact).

### Out of scope (for this iteration)

- Custom native camera UI (AVFoundation/CameraX).
- Video capture.
- Uploading images to backend.
- Persisting selected image across app restarts.

## Key Technical Decisions

1. Use `image_picker` (Flutter-maintained plugin) instead of custom native code.
2. Implement as a **separate feature module** (`lib/features/camera_gallery/`),
   not inside `features/example`, so Example page remains a launcher only.
3. Keep domain Flutter-agnostic and return typed results (success/cancel/error),
   not raw string-only flow.
4. Recover Android lost picker data via `retrieveLostData()` during demo page
   initialization.

## Pre-Implementation Checks (Gate)

1. Add dependency with `flutter pub add image_picker`.
2. Confirm selected `image_picker` version compatibility with this project:
   - Flutter/Dart constraints (project uses Dart `^3.9.2`).
   - Android minimum SDK requirement of that plugin version.
3. Confirm Android activity launch mode is **not** `singleInstance` (current
   manifest uses `singleTop`, which is compatible).

If the chosen `image_picker` version requires higher Android `minSdk` than the
current app baseline, explicitly decide one path before coding:

1. bump app `minSdk`, or
2. pin a compatible `image_picker` version and document the reason in PR.

## Architecture and File Plan

### New feature module

```text
lib/features/camera_gallery/
├── camera_gallery.dart
├── domain/
│   ├── camera_gallery_repository.dart
│   └── camera_gallery_result.dart
├── data/
│   └── image_picker_camera_gallery_repository.dart
└── presentation/
    ├── cubit/
    │   ├── camera_gallery_cubit.dart
    │   └── camera_gallery_state.dart
    └── pages/
        └── camera_gallery_page.dart
```

### Existing files to update

- `pubspec.yaml` (add `image_picker`).
- `lib/core/router/app_routes.dart` (add route name/path constants).
- `lib/app/router/routes.dart` (register new `GoRoute` + cubit provider).
- `lib/core/di/injector_registrations.dart` (register repository binding).
- `lib/features/example/presentation/pages/example_page.dart` (new navigation
  callback).
- `lib/features/example/presentation/widgets/example_page_body.dart` (new demo
  button).
- `lib/l10n/app_*.arb` (all locales).
- `ios/Runner/Info.plist` (camera + photo library usage descriptions).

## Domain/Data Contract

### Domain contract

Use an interface with typed result semantics:

- `pickFromCamera()`
- `pickFromGallery()`
- `retrieveLostImage()` (Android recovery path)

`CameraGalleryResult` should represent:

- success (`imagePath`),
- cancelled,
- failure (`code`/message).

This keeps permission and plugin-specific details out of UI widgets.

### Data implementation

`ImagePickerCameraGalleryRepository` responsibilities:

- call `ImagePicker().pickImage(...)` for camera/gallery,
- map `null` to cancelled,
- map plugin/platform exceptions to typed failure,
- implement `retrieveLostData()` mapping for Android process death.

## Presentation Plan

### Cubit

`CameraGalleryCubit`:

- state modeled with Freezed (`ViewStatus`, selected path/source, error key).
- methods:
  - `initialize()` -> attempt `retrieveLostImage()` once,
  - `pickFromCamera()`,
  - `pickFromGallery()`,
  - optional `clearSelection()`.

Safety requirements:

- use `CubitExceptionHandler.executeAsync*` with `isAlive: () => !isClosed`.
- guard `emit()` paths after async (`if (isClosed) return;`).
- avoid out-of-order updates (request-id guard if multiple picks race).

### Page

`CameraGalleryPage`:

- built with `CommonPageLayout`.
- action buttons via `PlatformAdaptive.filledButton` + `IconLabelRow`.
- preview area with stable layout (placeholder when empty).
- `TypeSafeBlocSelector/Builder` + `context.cubit<CameraGalleryCubit>()`.
- user-visible error text from l10n keys (no hardcoded strings).
- accessibility: semantics labels, no row text overflow, text scale resilience.

## Routing and Navigation

1. Add:
   - `AppRoutes.cameraGallery`
   - `AppRoutes.cameraGalleryPath` (e.g. `'/camera-gallery'`)
2. Register `GoRoute` in `lib/app/router/routes.dart` with cubit creation from
   DI (`getIt<CameraGalleryRepository>()`).
3. Add button in Example page body and wire
   `context.pushNamed(AppRoutes.cameraGallery)`.

## Platform Configuration

### iOS (`ios/Runner/Info.plist`)

Add:

- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`

Use clear user-facing purpose text.

### Android

- No extra storage permission required for gallery picker path.
- Keep activity launch mode compatible (`singleTop`/`singleTask`, not
  `singleInstance`).
- Do not add unnecessary manifest permissions unless required by tested
  behavior.

## Localization

Add keys in all ARB files under `lib/l10n/` (names can follow):

- `cameraGalleryPageTitle`
- `cameraGalleryTakePhoto`
- `cameraGalleryPickFromGallery`
- `cameraGalleryNoImage`
- `cameraGalleryPermissionDenied`
- `cameraGalleryCancelled`
- `cameraGalleryGenericError`
- `exampleCameraGalleryButton`

Then run:

- `dart run tool/ensure_localizations.dart`

## Testing Plan

### Unit/Bloc tests

Create `test/features/camera_gallery/presentation/cubit/camera_gallery_cubit_test.dart`:

1. camera success -> emits loading -> success + image path.
2. gallery success -> emits loading -> success + image path.
3. cancelled flow -> no crash, state reflects cancellation UX.
4. permission/failure flow -> emits error state with mapped message key.
5. lost-data recovery on `initialize()` path.
6. closed cubit safety (no emits after close).

### Widget tests

Create `test/features/camera_gallery/presentation/pages/camera_gallery_page_test.dart`:

1. renders placeholder and both action buttons.
2. renders preview when state has image path.
3. renders localized error message when state is error.

Update `test/features/example/presentation/widgets/example_page_body_test.dart`
with one assertion for the new Example-page entry button callback.

## Validation and Delivery

Run in order:

1. `dart format .`
2. `dart run build_runner build --delete-conflicting-outputs` (if Freezed added)
3. `flutter test test/features/camera_gallery`
4. `flutter test test/features/example/presentation/widgets/example_page_body_test.dart`
5. `./bin/checklist`
6. `dart run tool/update_coverage_summary.dart`

## Acceptance Criteria (Definition of Done)

1. From Example page, user can open Camera & Gallery Demo route.
2. On iOS and Android, user can:
   - take a photo,
   - pick from gallery,
   - see selected image preview in-page.
3. Cancel and permission-denied cases show user-visible localized feedback.
4. Android lost-data recovery path is implemented and covered by tests.
5. No architecture/lifecycle/type-safe BLoC rule violations from checklist.
6. New/updated tests pass and coverage summary is updated.

## Risks and Mitigations

1. Plugin version requires higher Android min SDK.
   - Mitigation: decide minSdk bump vs version pin at gate stage.
2. Async race if user taps camera/gallery repeatedly.
   - Mitigation: in-flight/request-id guard in cubit.
3. Platform permission behavior differs by OS version.
   - Mitigation: device/emulator verification on latest iOS + Android APIs.
