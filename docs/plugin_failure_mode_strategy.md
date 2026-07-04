# Plugin failure-mode strategy

<!-- markdownlint-disable MD060 -->

Canonical guidance for wrapping Flutter plugins behind data-layer services and surfacing failures safely in presentation.

## Goals

- Keep **domain** free of plugin types and exceptions.
- Return **`Result<T>`** with typed **`Failure`** from data-layer wrappers.
- Map **`Failure` → `AppError`** (or l10n keys) only at presentation boundaries.
- Preserve **legacy null/fallback** behavior where product already depends on it (e.g. optional location on clock-in).

## Layering

| Layer | Responsibility |
|-------|----------------|
| **Domain** | `Result<T>`, sealed `Failure` variants (`PermissionFailure`, `PlatformFailure`, `StorageFailure`, `TimeoutFailure`, `ValidationFailure`, `UnknownFailure`). No `dart:io`, no plugin imports. |
| **Data** | Plugin calls, exception → `Failure` mapping, optional logging. Exposes `Future<Result<T>>` or feature-specific result types (`MediaPickResult`). |
| **Presentation** | Cubits/widgets consume results; map failures to user-visible copy via `appErrorFromFailure` or existing l10n key helpers. |

Core types live in:

- `apps/mobile/lib/core/domain/result.dart`
- `apps/mobile/lib/core/domain/failure.dart`
- `apps/mobile/lib/shared/utils/failure_to_app_error.dart`

## Wrapper pattern

1. **One wrapper per plugin concern** (location, secure storage, image pick, etc.) under `data/` or `shared/platform/`.
2. **Catch narrow exceptions** (`PlatformException`, `MissingPluginException`, plugin-specific errors) and map to `Failure` with stable `kind` / message.
3. **Do not leak** raw exception strings to UI unless wrapped in a known l10n key (see staff proof photo picker).
4. **Log at data layer** when swallowing failure into null fallback (timeclock location unwrap).

### Staff demo reference implementations

| Concern | Wrapper | Presentation consumption |
|---------|---------|-------------------------|
| Geolocator location | `StaffDemoLocationService.captureCurrentLocation()` → `Result<StaffDemoCapturedLocation>` | Timeclock repo unwraps to nullable location + log |
| Image picker (proof) | Domain port `StaffDemoProofPhotoPicker`; data impl `ImagePickerStaffDemoProofPhotoPicker` → `MediaPickResult` | `StaffDemoProofCubit` returns l10n error key or persists photo |
| Secure storage | `SecretStorage.readResult()` | Callers migrating to `Result`; legacy `read()` uses `getOrNull()` |
| Camera/gallery cubit | `CameraGalleryFailureMapper` on existing `CameraGalleryResult` | No change to `CameraGalleryResult` shape |

## Exception handling rules

- **Permission denied** → `PermissionFailure` (location) or `MediaPickResult.failure` with `MediaPickErrorKeys.permissionDenied`.
- **Platform / missing plugin** → `PlatformFailure` or `StorageFailure` as appropriate.
- **Timeouts** (location) → `TimeoutFailure`.
- **User cancel** → `MediaPickResult.cancelled` or success path with null (not a failure).
- **Unknown** → `UnknownFailure` with optional cause for logs.

### `appErrorFromFailure` mapping

Generic bridge for future presentation use (not wired to all cubits yet):

- `PermissionFailure` / `PlatformFailure` → `UnknownError` (device/OS permission or capability; **not** `AuthError` / `StorageError`).
- `StorageFailure` → `StorageError`; `TimeoutFailure` → `NetworkError`; `ValidationFailure` / `UnknownFailure` → `UnknownError`.

Feature-specific l10n keys (e.g. `MediaPickErrorKeys`) stay preferred at cubit boundaries when they exist.

## Fallback policy

When business allows degraded behavior:

- Document **why** null/empty is acceptable.
- **Log** the underlying `Failure` (integration log or `AppLogger`).
- Do **not** silently ignore without a trace.

Example: offline-first timeclock may clock in without GPS when location capture fails; `_unwrapLocationResult` logs and returns `null`.

## Adding a new plugin

1. Inventory call sites (presentation must not import the plugin).
2. Add a data-layer wrapper returning `Result<T>` or a sealed feature result.
3. Map exceptions in one place; add unit tests for deny/cancel/timeout/unavailable paths.
4. Wire DI in the feature registrar.
5. Presentation: map to `AppError` or l10n keys—never show raw `PlatformException.code` in UI.
6. Cross-link this doc from the feature plan or ADR if behavior is non-obvious.

## Out of scope (current pass)

- Firebase bootstrap `bool` contract unchanged.
- No `permission_handler`; staff location uses Geolocator permission APIs only.
- Broad retrofit of every plugin touchpoint—expand using this pattern incrementally.

## Related

- [storage_rules.md](storage_rules.md) — where secrets and prefs live
- [architecture_details.md](architecture_details.md) — DI and app shell
- [reliability_error_handling_performance.md](reliability_error_handling_performance.md) — broader error handling
