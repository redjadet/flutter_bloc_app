# Firebase Cloud Messaging Demo Integration Plan

This document replaces the earlier draft with a repo-aligned, execution-ready
plan for an FCM demo feature.

## Goal

- Add a demo FCM flow that can:
  - request permission,
  - show current FCM token,
  - show last message payload received in foreground,
  - handle open-from-notification events (`getInitialMessage`,
    `onMessageOpenedApp`).
- Keep implementation aligned with this repo's clean architecture, Cubit rules,
  DI conventions, lifecycle guards, and localization standards.

## Non-goals (Demo Scope)

- No production notification orchestration backend.
- No APNs key upload/configuration in Firebase Console as part of this task.
- No guaranteed iOS background/terminated delivery on real devices without APNs.
- No foreground system-banner guarantee on Android unless local notifications are
  explicitly added (out of scope for first demo).

## Key Corrections vs Previous Draft

- Use `FirebaseMessaging.onBackgroundMessage(...)` (static API), not
  instance-level "setBackgroundMessageHandler".
- Do not register `FcmDemoCubit` as a lazy singleton in DI. Create it per-route
  (same pattern used by most feature pages).
- Keep bootstrap impact minimal: register background handler before app start,
  but perform permission/token UI flow on-demand when demo page initializes.
- Add Android 13+ runtime permission handling implications
  (`POST_NOTIFICATIONS`).
- Clarify foreground behavior: `onMessage` callback works, but system banners in
  foreground typically need additional local notification integration.

## Existing Repo Context

- Firebase app bootstrap already exists:
  `lib/core/bootstrap/firebase_bootstrap_service.dart`.
- App startup entry funnel:
  `main*.dart -> main_bootstrap.dart -> BootstrapCoordinator`.
- DI pattern uses feature registration files:
  `lib/core/di/register_<feature>_services.dart`.
- Route constants live in `lib/core/router/app_routes.dart`.
- Route wiring lives in `lib/app/router/routes.dart` / `route_groups.dart`.
- Type-safe BLoC access is mandatory (`context.cubit<T>()`,
  `TypeSafeBlocBuilder/Selector/...`).

## Architecture

Create new feature module `lib/features/fcm_demo/`:

- `domain/`
  - `fcm_messaging_service.dart` (interface only)
  - `push_message.dart` (Freezed model)
  - `fcm_permission_state.dart` (optional enum/model for UI clarity)
- `data/`
  - `firebase_messaging_repository.dart` (implements domain interface)
  - `fcm_background_handler.dart` (top-level background handler function)
- `presentation/`
  - `cubit/fcm_demo_cubit.dart`
  - `cubit/fcm_demo_state.dart` (Freezed)
  - `pages/fcm_demo_page.dart`
- `fcm_demo.dart` (feature barrel export)

Domain must remain Flutter-agnostic (no `package:flutter/*` imports).

## Platform and Dependency Setup

## 1. Pubspec

- Add `firebase_messaging` dependency.
- Run `flutter pub get`.

## 2. Android

- Confirm existing `com.google.gms.google-services` plugin remains in
  `android/app/build.gradle` (already present).
- Ensure `google-services.json` exists under `android/app/`.
- Add notification permission for Android 13+:
  `android.permission.POST_NOTIFICATIONS` in
  `android/app/src/main/AndroidManifest.xml`.
- Optional metadata (`default_notification_channel_id`, icon, color) can be
  added for richer notification UX later, but is not required for basic token +
  message callback demo.

## 3. iOS

- In Xcode (`ios/Runner.xcworkspace`), Runner target -> Signing & Capabilities:
  - Add `Push Notifications`.
  - Add `Background Modes`, enable:
    - `Background fetch`
    - `Remote notifications`
- Keep "APNs key in Firebase Console" explicitly out of scope for this demo.
- Clarify in docs/UI: without APNs key in Firebase project, iOS
  background/terminated FCM delivery is limited/not guaranteed.

## Initialization and Runtime Flow

## 1. Background handler registration

- Define a top-level handler in
  `lib/features/fcm_demo/data/fcm_background_handler.dart`:
  - annotate with `@pragma('vm:entry-point')`,
  - initialize Firebase inside handler if needed,
  - avoid DI/getIt access in background isolate.
- Register once before app bootstrap in `main_bootstrap.dart`:
  - call `FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler)` before
    `BootstrapCoordinator.bootstrapApp(...)`.

## 2. On-demand feature initialization

- Do not request notification permission globally at app startup.
- In `FcmDemoCubit.initialize()`:
  - request permission,
  - load token (`getToken()`),
  - read `getInitialMessage()`,
  - subscribe to:
    - foreground stream,
    - opened-app stream,
    - token refresh stream.

## 3. Lifecycle/race-safety requirements

- `FcmDemoCubit` must use `CubitSubscriptionMixin` for stream subscriptions.
- After every `await` and inside every async callback:
  `if (isClosed) return;` before `emit`.
- Stream listeners must include `onError` with `AppLogger.error(...)`.
- Cancel/dispose resources in `close()` and call `super.close()`.

## Data and Domain Contracts

`FcmMessagingService` should expose:

- `Future<FcmPermissionState> requestPermission()`
- `Future<String?> getToken()`
- `Future<String?> getApnsToken()` (Apple only; null elsewhere)
- `Future<PushMessage?> getInitialMessage()`
- `Stream<PushMessage> foregroundMessages()`
- `Stream<PushMessage> openedMessages()`
- `Stream<String> tokenRefreshes()`

`PushMessage` model should include:

- `messageId`
- `title`
- `body`
- `sentTime`
- `Map<String, String> data`
- optional `source` (`foreground`, `opened`, `initial`, `background`) for demo
  diagnostics.

## Presentation Plan

`FcmDemoState` (Freezed):

- `status` (`initial/loading/ready/error`)
- `permissionState`
- `fcmToken`
- `apnsToken` (nullable)
- `lastMessage` (nullable)
- `errorMessage` (nullable)

`FcmDemoPage` requirements:

- Use l10n (`context.l10n.*`) for all user strings.
- Show:
  - permission state,
  - FCM token with copy action,
  - APNs token (if available),
  - last received message + data payload.
- Explain platform constraints in UI text:
  - iOS background/terminated delivery requires APNs config in Firebase.
  - Simulator uses `.apns` simulation, not real FCM.

## DI, Routing, and Discoverability

## 1. DI

Create `lib/core/di/register_fcm_demo_services.dart`:

- register `FcmMessagingService` -> `FirebaseMessagingRepository`.
- do not register `FcmDemoCubit` as singleton.
- if repository holds controllers/subscriptions, register with `dispose`.

Wire into `lib/core/di/injector_registrations.dart` with
`registerFcmDemoServices()`.

## 2. Routing

- Add constants to `lib/core/router/app_routes.dart`:
  - `fcmDemo`
  - `fcmDemoPath` (for example `/fcm-demo`)
- Add route in `lib/app/router/routes.dart` using
  `BlocProviderHelpers.withAsyncInit<FcmDemoCubit>(...)`.
- Create cubit in route builder with repository from DI.

## 3. Entry point from demo UI

- Add a button on Example page to open FCM demo route:
  - update `ExamplePage` callbacks,
  - update `ExamplePageBody` button list,
  - add localized label key.

## Localization and Documentation

## 1. Localization

- Add keys to `lib/l10n/app_en.arb` for:
  - page title,
  - permission labels,
  - token labels/states,
  - copy success/failure,
  - APNs/FCM scope notes,
  - simulator testing note.
- Regenerate localizations if required by current workflow.

## 2. Integration doc

Create `docs/fcm_demo_integration.md` with:

- setup steps (Android + iOS),
- explicit APNs limitation note,
- Firebase Console test-send flow,
- iOS simulator `.apns` testing instructions.

Add sample file: `tool/fcm_demo_simulator.apns`.

## Testing Strategy

## 1. Unit tests

- `FirebaseMessagingRepository` mapping tests:
  - `RemoteMessage -> PushMessage` translation,
  - null/empty payload handling.

## 2. Cubit tests

- `initialize()` success path,
- permission denied path,
- message stream updates state,
- token refresh updates state,
- stream error path logs + emits error safely,
- close-before-callback does not emit.

## 3. Widget tests

- page renders permission/token/message sections from state,
- copy token action feedback,
- long payload text remains overflow-safe.

## 4. Manual validation matrix

- Android device:
  - foreground data/notification callback,
  - open from notification (`onMessageOpenedApp`),
  - cold start via notification (`getInitialMessage`).
- iOS device (without APNs key):
  - permission prompt and token/APNs diagnostics behavior,
  - foreground behavior validation.
- iOS simulator:
  - `.apns` push injection via drag-drop or `xcrun simctl push`.

## Execution Checklist

- [ ] Add `firebase_messaging` and run `flutter pub get`.
- [ ] Add Android permission/config entries.
- [ ] Enable iOS capabilities in Xcode.
- [ ] Implement `fcm_demo` feature (domain/data/presentation).
- [ ] Register background handler in `main_bootstrap.dart`.
- [ ] Add DI registration file + injector wiring.
- [ ] Add `AppRoutes` constants + route wiring.
- [ ] Add Example page entry button + l10n keys.
- [ ] Add tests (unit/cubit/widget + race/lifecycle-focused cases).
- [ ] Add `docs/fcm_demo_integration.md` + sample `.apns` file.
- [ ] Run `./bin/checklist`.
- [ ] Run `dart run tool/update_coverage_summary.dart`.

## File-Level Plan

| Action | Path |
| ------ | ---- |
| Modify | `pubspec.yaml` |
| Modify | `android/app/src/main/AndroidManifest.xml` |
| Modify | `lib/main_bootstrap.dart` |
| Create | `lib/features/fcm_demo/fcm_demo.dart` |
| Create | `lib/features/fcm_demo/domain/fcm_messaging_service.dart` |
| Create | `lib/features/fcm_demo/domain/push_message.dart` |
| Create | `lib/features/fcm_demo/data/firebase_messaging_repository.dart` |
| Create | `lib/features/fcm_demo/data/fcm_background_handler.dart` |
| Create | `lib/features/fcm_demo/presentation/cubit/fcm_demo_cubit.dart` |
| Create | `lib/features/fcm_demo/presentation/cubit/fcm_demo_state.dart` |
| Create | `lib/features/fcm_demo/presentation/pages/fcm_demo_page.dart` |
| Create | `lib/core/di/register_fcm_demo_services.dart` |
| Modify | `lib/core/di/injector_registrations.dart` |
| Modify | `lib/core/router/app_routes.dart` |
| Modify | `lib/app/router/routes.dart` |
| Modify | `lib/features/example/presentation/pages/example_page.dart` |
| Modify | `lib/features/example/presentation/widgets/example_page_body.dart` |
| Modify | `lib/l10n/app_en.arb` (+ generated localization outputs as needed) |
| Create | `tool/fcm_demo_simulator.apns` |
| Create | `docs/fcm_demo_integration.md` |
