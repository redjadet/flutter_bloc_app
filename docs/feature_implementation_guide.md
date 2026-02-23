# Feature Implementation Guide (iOS + Android)

This document describes **how each major feature is implemented** in this Flutter BLoC app, or **how to implement it** if it is not yet present. It covers iOS and Android and prefers referencing existing documentation where it exists.

**Last reviewed:** 2026-02-23

## How to Use This Guide

- Use the section for your feature to quickly answer:
  - Is it already implemented?
  - Is there an in-app demo route?
  - Which docs and files are the source of truth?
- For features marked as not implemented, follow the implementation summary in that section and keep it aligned with clean architecture and DI.
- After shipping any feature, update this guide and the summary table so new developers can find the current status quickly.

## Status Legend

- **Implemented:** Production-ready or working demo exists in this repo.
- **Partially implemented:** Some integrations exist, but scope is incomplete.
- **Plan only:** Documented approach exists, but no integrated feature yet.
- **Not implemented:** No integrated feature or active plan in code.

## Definition of Done for New Features

1. Domain contract added in `lib/features/<feature>/domain/`.
2. Data implementation added in `lib/features/<feature>/data/`.
3. Cubit + UI added in `lib/features/<feature>/presentation/`.
4. DI registration added in `lib/core/di/injector_registrations.dart` (or helper registration file).
5. Route wiring added in `lib/app/router/routes.dart` or `lib/app/router/route_groups.dart`.
6. Async/lifecycle safety enforced (`isClosed`, `context.mounted`, `mounted` checks after `await`).
7. Tests added/updated (unit/bloc/widget; golden if visual behavior changed).
8. Validation run: `./bin/checklist` and `dart run tool/update_coverage_summary.dart`.

---

## 1. API Integration

**Status:** Implemented.

**How it was implemented:**

- **HTTP client:** The app uses a shared `ResilientHttpClient` (`lib/shared/http/resilient_http_client.dart`) that wraps `http` and adds:
  - Optional **Firebase ID token injection** for authenticated requests (when Firebase Auth is configured).
  - Retry/backoff and network-awareness via `NetworkStatusService` and `RetryNotificationService`.
- **Token handling:** `AuthTokenManager` (`lib/shared/http/auth_token_manager.dart`) caches Firebase ID tokens per user, refreshes before expiry, and clears on auth changes so tokens are never reused across users.
- **Registration:** HTTP-related services (client, chart repo, GraphQL repo, etc.) are registered in `lib/core/di/register_http_services.dart`. Use `ResilientHttpClient` for any new REST/API calls so auth and retries are consistent.
- **Clean architecture:** API calls live in the **data layer** (repositories); domain defines interfaces. Example: `CountriesGraphqlRepository`, `DelayedChartRepository`, `HuggingfaceChatRepository`.

**References:**

- [Authentication](authentication.md) — token injection and cache safety
- [Tech stack](tech_stack.md) — networking packages
- [New developer guide](new_developer_guide.md) — DI and feature layout
- [Security & secrets](security_and_secrets.md) — API keys and `SecretConfig`

**Adding a new API:** Create a domain repository interface, implement it in `lib/features/<feature>/data/` using `ResilientHttpClient`, register in `injector_registrations.dart` (or a dedicated `register_*_services.dart`).

---

## 2. Login System

**Status:** Implemented.

**How it was implemented:**

- **Firebase Auth + FirebaseUI:** Primary sign-in uses `firebase_auth` and `firebase_ui_auth`. Providers are built via `buildAuthProviders()` so email/password is always available; Google is added when configured (`lib/features/auth/presentation/helpers/provider_builder.dart`, `google_provider_helper.dart`).
- **Anonymous sessions:** Supported from the sign-in screen; anonymous users can upgrade without being redirected away.
- **Routing:** `GoRouter` uses `refreshListenable: GoRouterRefreshStream(auth.authStateChanges())`. `createAuthRedirect()` sends unauthenticated users to `/auth` and authenticated users away from `/auth` (with an exception for anonymous upgrade). See `lib/app/router/auth_redirect.dart`.
- **Sign-in screen:** `lib/features/auth/presentation/pages/sign_in_page.dart` uses `firebase_ui.SignInScreen` when Firebase is initialized, with a minimal anonymous-sign-in fallback otherwise. Auth errors are localized via `auth_error_message.dart` and l10n.
- **Biometric gate:** Sensitive routes (e.g. Settings) can be wrapped with `BiometricAuthenticator` (`lib/shared/platform/biometric_authenticator.dart`) using `local_auth` (Face ID / Touch ID on iOS, BiometricPrompt on Android).
- **Registration:** The current `RegisterPage` is UI-only (validation only); real account creation uses FirebaseUI sign-in/registration.

**References:**

- [Authentication](authentication.md) — full overview, token handling, gaps
- [Tech stack](tech_stack.md) — Firebase and auth packages
- [WalletConnect Auth Status](walletconnect_auth_status.md) — optional wallet-link demo and Firebase setup

**iOS/Android:** Firebase config: `GoogleService-Info.plist` (iOS), `google-services.json` (Android). Generate via `flutterfire configure`. Biometrics: `NSFaceIDUsageDescription` in `Info.plist` (iOS); no extra manifest for Android.

---

## 3. Testing

**Status:** Implemented.

**How it was implemented:**

- **Unit tests:** Isolated logic, repositories, utilities; no Flutter dependencies.
- **Bloc tests:** State flows with `bloc_test`; state machine behavior without widget pumps.
- **Widget tests:** UI and interaction; platform-adaptive components.
- **Golden tests:** Visual regression with `golden_toolkit`; regenerate with `flutter test --update-goldens` after Flutter upgrades.
- **Common bugs prevention:** `test/shared/common_bugs_prevention_test.dart` covers context lifecycle, cubit disposal, stream cleanup; run via `./bin/checklist`.
- **Patterns:** `FakeTimerService` for time-dependent tests; mock Firebase/auth; temp dir + `HiveService` for Hive tests; `pump()` (not `pumpAndSettle()`) with `CachedNetworkImageWidget`.

**References:**

- [Testing overview](testing_overview.md) — coverage, types, patterns, commands
- [New developer guide](new_developer_guide.md) — testing strategy and checklist
- Coverage: `coverage/coverage_summary.md`; update with `dart run tool/update_coverage_summary.dart`

**Commands:**

```bash
flutter test
flutter test --coverage
tool/test_coverage.sh
./bin/checklist
```

---

## 4. App Store & Play Store Submission

**Status:** Implemented and documented.

**How it was implemented:**

- **iOS (App Store):** Prerequisites (Apple Developer Program, Xcode, Firebase config, distribution signing). Steps: App Store Connect setup → switch to distribution entitlements (`./tool/ios_entitlements.sh distribution`) → `dart run tool/prepare_release.dart` → `flutter build ios --release` → archive in Xcode or `bundle exec fastlane ios appstore` / `ios testflight`. TestFlight: same build, assign to internal/external testers in App Store Connect.
- **Android (Play Store):** Play Console setup, App Signing by Google Play or upload key, `dart run tool/prepare_release.dart` → `flutter build appbundle --release` → upload AAB via Play Console or `bundle exec fastlane android deploy track:production` (or internal/alpha/beta).
- **Fastlane:** iOS: `adhoc`, `testflight`, `appstore`; Android: `deploy` with track. Both support Firebase App Distribution lanes (`firebase_distribute`).

**References:**

- [Deployment](deployment.md) — full step-by-step for both stores, TestFlight, Fastlane, entitlements, troubleshooting
- [Firebase App Distribution](firebase_app_distribution.md) — pre-release distribution to testers (iOS + Android)
- [Security & secrets](security_and_secrets.md) — keys and release preparation

**iOS:** Use distribution entitlements for store builds; development entitlements for local runs. **Android:** Ensure `versionCode` is incremented per upload; keep `key.properties` (or keystore env) out of git.

---

## 5. Payment Integration

**Status:** Plan only (not yet implemented in app).

**Existing documentation:**

- [Stripe demo integration plan](stripe_demo_integration_plan.md) — plan for a **Stripe SetupIntent** “Save card” demo on Android + iOS using:
  - **Frontend:** `flutter_stripe` PaymentSheet in setup mode.
  - **Backend:** Firebase Callable Function (or equivalent) to create Stripe Customer, Ephemeral Key, and SetupIntent; return `customerId`, `ephemeralKeySecret`, `setupIntentClientSecret`.
  - **Architecture:** New `payments` feature (domain/data/presentation), `SecretConfig` for publishable key, backend holds secret key.
  - **iOS/Android:** Follow `flutter_stripe` platform setup (Info.plist, min SDK, etc.).

**How to implement (summary):** Add `payments` feature module, register in DI and router, add Stripe demo entry from Example page, implement callable (or document backend contract), add cubit/widget tests, run `./bin/checklist` and coverage. See the plan for the full checklist.

**In-app purchases:** Not covered by the Stripe plan. For IAP (iOS/Android), see section 10 below.

---

## 6. Push Notifications

**Status:** Not implemented; mentioned as future in offline-first docs.

**Current state:** No `firebase_messaging` (FCM) or other push SDK in the project. [Offline-first plan](offline_first/offline_first_plan.md) and [ANALYSIS_AND_IMPROVEMENTS](offline_first/ANALYSIS_AND_IMPROVEMENTS.md) mention using FCM to trigger background sync.

**How to implement (iOS + Android):**

1. **Add dependency:** `firebase_messaging` in `pubspec.yaml`; ensure Firebase is already configured (`flutterfire configure`).
2. **iOS:** Enable Push Notifications capability in Xcode; upload APNs key/certificate to Firebase Console (Project Settings → Cloud Messaging). In `AppDelegate` (or Swift equivalent), register for remote notifications and forward token to FCM.
3. **Android:** No extra capability; ensure `google-services.json` is present. For channels (Android 8+), create a notification channel in code.
4. **Flutter:** Request permission (`requestPermission()`), get token (`getToken()`), subscribe to `onMessage`, `onMessageOpenedApp`, and `getInitialMessage()` for cold start. Store token on your backend if you send targeted messages.
5. **Architecture:** Prefer a small service or repository in the data layer that exposes stream of messages and token; cubits listen and update UI or trigger sync. Keep handling of notification payloads (e.g. sync triggers) in one place and document payload contracts as in the offline-first plan.
6. **Lifecycle:** After any `await` before `emit()` or navigation, check `isClosed` / `context.mounted`. Validate with `tool/check_cubit_isclosed.sh`, `tool/check_context_mounted.sh`, and `tool/check_setstate_mounted.sh` (run via `./bin/checklist`).

**Reference:** [Offline-first plan](offline_first/offline_first_plan.md) — push-triggered sync and payload contracts.

---

## 7. GraphQL

**Status:** Implemented (demo).

**How it was implemented:**

- **Feature:** `lib/features/graphql_demo/`. Remote: `CountriesGraphqlRepository` calls `https://countries.trevorblades.com/`. Cache: `GraphqlDemoCacheRepository` (Hive, encrypted) for continents and countries by filter.
- **Offline-first:** `OfflineFirstGraphqlDemoRepository` implements cache-first: on success write-through to cache; on failure return cached data when available. Staleness: cache entries expire after 24h.
- **UI:** GraphQL demo page shows countries/continents and a “Cache/Remote” badge. Settings includes “Clear GraphQL cache” for dev/QA.
- **DI:** `GraphqlDemoRepository` → `OfflineFirstGraphqlDemoRepository` in `injector_registrations.dart`; remote uses `ResilientHttpClient`.

**References:**

- [Offline-first GraphQL demo](offline_first/graphql_demo.md) — architecture, behavior, testing, status
- [Tech stack](tech_stack.md) — `http` and networking
- Route and registration: see `lib/app/router/route_groups.dart` and feature `lib/features/graphql_demo/`.

**iOS/Android:** No platform-specific GraphQL config; only HTTP and Hive (already set up).

---

## 8. Firebase

**Status:** Implemented across multiple features.

**How it was implemented:**

- **Core:** `firebase_core`; options from `flutterfire configure` → `lib/firebase_options.dart` (gitignored), `GoogleService-Info.plist` (iOS), `google-services.json` (Android).
- **Auth:** See [Login system](#2-login-system) and [Authentication](authentication.md). Firebase UI for sign-in; Realtime Database and Firestore features scoped by `user.uid`.
- **Realtime Database:** Counter and Todo list use user-scoped paths (e.g. `/todos/{userId}/{todoId}`). See `RealtimeDatabaseCounterRepository`, `RealtimeDatabaseTodoRepository`; [Todo list Firebase plan](todo_list_firebase_realtime_database_plan.md) and [security rules](todo_list_firebase_security_rules.md).
- **Remote Config:** `OfflineFirstRemoteConfigRepository` with Hive cache; Settings shows diagnostics and clear-cache. See [Offline-first Remote Config](offline_first/remote_config.md).
- **Analytics / Crashlytics:** Listed in [tech stack](tech_stack.md); bootstrap in `firebase_bootstrap_service.dart`.
- **App Distribution:** Pre-release builds to testers; see [Firebase App Distribution](firebase_app_distribution.md).

**References:**

- [Authentication](authentication.md)
- [Todo list Firebase Realtime Database plan](todo_list_firebase_realtime_database_plan.md)
- [Todo list Firebase security rules](todo_list_firebase_security_rules.md)
- [Offline-first Remote Config](offline_first/remote_config.md)
- [Firebase App Distribution](firebase_app_distribution.md)
- [WalletConnect Auth Status](walletconnect_auth_status.md) — Firebase project setup

**iOS/Android:** Same Firebase project; add both apps in Firebase Console and run `flutterfire configure` to get platform config files.

---

## 9. Realm

**Status:** Not used in this project.

**Current stack:** The app uses **Hive** (and has evaluated **Isar**) for local persistence. See [Migration: SharedPreferences to Isar](migration/shared_preferences_to_isar.md) and [Isar vs Hive comparison](migration/isar_vs_hive_comparison.md). There is no Realm dependency or documentation.

**If you need Realm (iOS + Android):**

- Add `realm` (or the official Flutter Realm package if available) to `pubspec.yaml`. Official Realm supports Dart/Flutter; follow their iOS/Android setup (e.g. CocoaPods, Gradle).
- Keep persistence behind a **domain repository interface** so the rest of the app stays agnostic (same pattern as Hive/Isar). Implement the interface in the data layer with Realm as the backing store.
- For sync (Realm Sync), configure according to Realm docs (Atlas, app ID, etc.) and keep sync logic in the data layer; use the same lifecycle rules (e.g. `isClosed` before `emit()`, dispose subscriptions in `close()`).

**Recommendation:** Prefer the existing Hive/Isar patterns and [offline-first](offline_first/offline_first_plan.md) sync approach unless you have a specific requirement for Realm.

---

## 10. In-App Purchases

**Status:** Not implemented.

**How to implement (iOS + Android):**

- **Packages:** Use `in_app_purchase` (or `in_app_purchase_storekit` / `in_app_purchase_android` if using the federated plugins) from pub.dev. Follow the official [In-App Purchase](https://docs.flutter.dev/cookbook/in-app-purchase) documentation.
- **iOS:** Configure App Store Connect (In-App Purchases, products, agreements). Enable In-App Purchase capability. Use StoreKit 2 or legacy StoreKit as per plugin; handle transactions and restore.
- **Android:** Configure Play Console (Products, subscriptions if needed). Use Google Play Billing; validate purchases on a backend (recommended).
- **Architecture:** Introduce a domain `InAppPurchaseRepository` (or similar) for product list, purchase, and restore; implement in data layer with platform channels. Cubit in presentation drives UI state (loading, success, error). Keep purchase validation and receipt verification on a backend where possible.
- **Testing:** Use sandbox (iOS) and test tracks (Android); mock the repository in bloc/widget tests. Respect lifecycle guards after async (e.g. `isClosed`, `context.mounted`).

**Reference:** Flutter docs and platform docs (App Store Connect, Play Console) for product setup and compliance.

---

## 11. Ads

**Status:** Not implemented.

**How to implement (iOS + Android):**

- **Packages:** Common choice is `google_mobile_ads` (AdMob). Add to `pubspec.yaml`; configure AdMob app and ad unit IDs in AdMob console.
- **iOS:** Add `GADApplicationIdentifier` and optionally `SKAdNetworkItems` in `Info.plist`; AdMob docs list required keys. App Tracking Transparency (ATT) if you use personalized ads; request permission before loading personalized ads.
- **Android:** Add `com.google.android.gms.ads.APPLICATION_ID` in `AndroidManifest.xml`. Declare ads in Play Console if publishing to Play Store.
- **Architecture:** Keep ad loading and display behind a small service or repository if you need to swap providers or test; otherwise use the plugin in presentation with clear lifecycle (dispose banners/interstitials). Avoid hardcoded IDs; use `SecretConfig` or remote config for non-release.
- **Policy:** Follow store policies (e.g. no misleading placement; declare ads in store listing). See [Deployment](deployment.md) for store submission.

---

## 12. Maps

**Status:** Implemented.

**How it was implemented:**

- **Strategy:** **iOS** → Apple Maps (`apple_maps_flutter`); **Android** → Google Maps (`google_maps_flutter`). Selection in `lib/features/google_maps/presentation/pages/google_maps_sample_page.dart`.
- **Feature:** `lib/features/google_maps/`. Domain: `MapLocation`, `MapCoordinate`, `MapLocationRepository`. Data: `SampleMapLocationRepository` (sample POIs). Presentation: `MapSampleCubit`, map widgets, deferred page.
- **Deferred loading:** Map feature is lazy-loaded to reduce startup size; see `lib/app/router/deferred_pages/google_maps_page.dart` and route registration.
- **Keys:** Android: `GOOGLE_MAPS_ANDROID_API_KEY` (gradle property → `AndroidManifest.xml`). iOS: `GMSApiKey` in `Info.plist`; note the sample uses Apple Maps on iOS so a missing Google key does not block the page. Runtime check shows a missing-key message when needed (`NativePlatformService`).

**References:**

- [Google Maps integration](google_maps_integration.md) — setup, keys, behavior, testing, extending (e.g. live location)
- [Tech stack](tech_stack.md) — platform-specific map packages
- [ADR 0003 – Deferred feature loading](adr/0003-deferred-feature-loading.md)

**iOS/Android:** Android requires Maps API key and SDK enabled for the key. iOS: Apple Maps needs no key; for Google on iOS, set `GMSApiKey` and init in `AppDelegate`.

---

## 13. Chat

**Status:** Implemented.

**How it was implemented:**

- **AI backend:** Hugging Face Inference API for chat completions; model and API key from `SecretConfig` (`lib/features/chat/data/huggingface_chat_repository.dart`, `huggingface_api_client.dart`).
- **Offline-first:** `OfflineFirstChatRepository` with local Hive storage (encrypted), `PendingSyncRepository` for queued sends when offline, and `BackgroundSyncCoordinator` for replay. User messages are persisted locally before the remote call. See [Offline-first chat contract](offline_first/chat.md).
- **UI:** Chat list and conversation UI; sync banner (`ChatSyncBanner`), pending indicators, manual flush. Cubit: `ChatCubit`, `ChatListCubit`.
- **Security:** Chat history in Hive with secure key management; no raw Hive boxes in feature code.

**References:**

- [AI integration](ai_integration.md) — message flow, config, offline-first, error handling
- [Offline-first chat](offline_first/chat.md) — storage plan, repository wiring, conflict resolution, UI, testing
- [Feature overview](feature_overview.md) — Chat entry points
- [Security & secrets](security_and_secrets.md) — Hugging Face API key

**iOS/Android:** No chat-specific platform config; only HTTP and secrets (Hugging Face key).

---

## 14. AI

**Status:** Implemented (Chat + GenUI Demo).

**How it was implemented:**

- **Chat:** Hugging Face Inference API; see [AI integration](ai_integration.md) and [Chat](#13-chat). Offline-first, secure storage, configurable model via `SecretConfig`.
- **GenUI Demo:** AI-generated dynamic UI using GenUI SDK with **Google Gemini**; route and entry from Example page. Requires `GEMINI_API_KEY` (or `GOOGLE_API_KEY`) in `SecretConfig`. See [Feature overview](feature_overview.md) and [GenUI demo user guide](genui_demo_user_guide.md).
- **Architecture:** AI calls are behind repository interfaces (e.g. `ChatRepository`, remote part of `OfflineFirstChatRepository`); cubits stay testable with fakes/mocks.

**References:**

- [AI integration](ai_integration.md)
- [GenUI demo user guide](genui_demo_user_guide.md)
- [Security & secrets](security_and_secrets.md) — Hugging Face and Gemini keys

**iOS/Android:** No AI-specific native setup; keys via `SecretConfig` / `--dart-define` or assets (dev only).

---

## 15. Social Integration

**Status:** Partially implemented.

**How it was implemented:**

- **Google Sign-In:** Provided via **Firebase UI** and `firebase_ui_oauth_google`. Enabled when configured in `google_provider_helper.dart`; same sign-in screen and auth state as email/password. No standalone “social login” doc; covered in [Authentication](authentication.md).
- **WalletConnect Auth (demo):** Demo flow to connect a wallet and link to Firebase Auth; profile stored in Firestore. See [WalletConnect Auth Status](walletconnect_auth_status.md) and [Feature overview](feature_overview.md). Route: `/walletconnect-auth` from Example page.
- **Other providers (e.g. Apple, Facebook):** Not implemented. Firebase UI supports additional OAuth providers; add the corresponding package (e.g. `firebase_ui_oauth_apple`) and extend `buildAuthProviders()` and provider helpers; configure each provider in Firebase Console and (where required) in Apple/Developer or Meta apps.

**References:**

- [Authentication](authentication.md) — OAuth and token management
- [WalletConnect Auth Status](walletconnect_auth_status.md)
- [Tech stack](tech_stack.md) — Firebase UI and auth packages

**iOS:** For Apple Sign-In, add Sign in with Apple capability and `firebase_ui_oauth_apple`; configure in Firebase Console. **Android:** Google Sign-In usually works with default Firebase config; for Facebook/Twitter etc., add app IDs in manifest and Firebase.

---

## Suggested Implementation Order (Missing Features)

1. **Push notifications** (section 6): enables offline-first sync triggers and user re-engagement.
2. **Payment integration (Stripe)** (section 5): already has a detailed implementation plan.
3. **In-app purchases** (section 10): separate from Stripe; needed for native store billing.
4. **Ads** (section 11): policy-heavy; easiest after core monetization flows are stable.
5. **Realm** (section 9): only if a requirement cannot be met by existing Hive/Isar patterns.

---

## Summary Table

<!-- markdownlint-disable MD060 -->
| Feature | Status | Demo route in app | Primary doc(s) |
| --- | --- | --- | --- |
| API integration | Implemented | Indirect demos | authentication.md, tech_stack.md, register_http_services.dart |
| Login system | Implemented | `/auth` | authentication.md |
| Testing | Implemented | N/A | testing_overview.md |
| App Store / Play | Implemented | N/A | deployment.md, firebase_app_distribution.md |
| Payment integration | Plan only (Stripe) | Not yet | stripe_demo_integration_plan.md |
| Push notifications | Not implemented | Not yet | offline_first/offline_first_plan.md (future) |
| GraphQL | Implemented (demo) | `/graphql-demo` | offline_first/graphql_demo.md |
| Firebase | Implemented | Multiple features | authentication.md, todo_list_firebase_*, firebase_app_distribution.md, offline_first/remote_config.md |
| Realm | Not used | Not yet | migration/isar_vs_hive_comparison.md (Hive/Isar instead) |
| In-app purchases | Not implemented | Not yet | — (see section 10) |
| Ads | Not implemented | Not yet | — (see section 11) |
| Maps | Implemented (demo) | `/google-maps` | google_maps_integration.md |
| Chat | Implemented | `/chat`, `/chat-list` | offline_first/chat.md, ai_integration.md |
| AI | Implemented | `/chat`, `/genui-demo` | ai_integration.md, genui_demo_user_guide.md |
| Social integration | Partially implemented | `/auth`, `/walletconnect-auth` | authentication.md, walletconnect_auth_status.md |
<!-- markdownlint-enable MD060 -->

---

## Related Documentation

- [New developer guide](new_developer_guide.md) — quickstart, architecture, adding features
- [Feature overview](feature_overview.md) — catalog and entry points
- [Tech stack](tech_stack.md) — dependencies and platform requirements
- [Security & secrets](security_and_secrets.md) — API keys and release
