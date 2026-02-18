# Stripe demo integration plan

Integrate a demo Stripe SetupIntent flow for Android + iOS using a clean-architecture Payments feature, Stripe PaymentSheet in setup mode, and a minimal backend endpoint (recommended: Firebase Callable Cloud Function) to create customer, ephemeral key, and setup intent.

---

## Goal

- Add a **demo "Save card"** flow (Stripe **SetupIntent**) for **Android + iOS**.
- Keep the app aligned with repo rules: **Clean Architecture**, **Cubit**, **type-safe cubit access**, **no hardcoded strings/colors**, **async guards** (`context.mounted`, `isClosed`).

## Prerequisites — do this before you start building

Nothing is required inside **Strapi** (this integration uses **Stripe** for payments, not Strapi). Complete the following **before** implementing the feature.

### 1. Stripe (dashboard.stripe.com)

- **Create or use a Stripe account** at [stripe.com](https://stripe.com). For the demo, use **Test mode** (toggle in the top-right of the Dashboard) so no real money is involved.
- **Get API keys** (Developers → API keys):
  - **Publishable key** (starts with `pk_test_...`): used by the Flutter app only. You will provide this to the app via `SecretConfig` / `--dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...` or `assets/config/secrets.json` (dev-only).
  - **Secret key** (starts with `sk_test_...`): used **only by your backend** (e.g. Firebase Callable Function). Never put this in the app or in git.
- **No extra Stripe setup** is required for a "save card" (SetupIntent) demo: no Products, Prices, or Checkout Sessions needed. Default payment method types are fine.

### 2. Firebase (console.firebase.google.com)

- **Use an existing Firebase project** (this app already uses Firebase). If you add a new project, link it to the same app so `cloud_functions` and `firebase_core` point to it.
- **Cloud Functions**: ensure **Cloud Functions** is enabled. If you deploy a callable function that calls Stripe, you need the **Blaze (pay-as-you-go)** plan for outbound HTTPS (Stripe API) from Functions; the free tier only allows Firebase-to-Firebase calls.
- **Store the Stripe secret key for the backend**: when you implement the callable (e.g. `createSetupIntent`), the function must read the Stripe **secret key** (`sk_test_...`). Do one of the following:
  - **Option A**: Firebase Functions config — e.g. `firebase functions:config:set stripe.secret_key="sk_test_..."` (see [Firebase env config](https://firebase.google.com/docs/functions/config-env)).
  - **Option B**: Google Cloud Secret Manager — store the secret there and grant your Cloud Functions runtime access to it; then read it in the function at startup.
- **Firestore / Auth**: optional. For a minimal demo, the callable can create a new Stripe Customer per request. If you want one Stripe Customer per Firebase user, you will use Firebase Auth UID and optionally Firestore to store the mapping; that can be added after the first working demo.

### 3. Summary checklist before coding

- **Stripe**: Copy **Publishable key** (`pk_test_...`) for the app; copy **Secret key** (`sk_test_...`) for the backend only (Test mode).
- **Firebase**: Confirm Cloud Functions is enabled; upgrade to Blaze if you call Stripe from a callable; set Stripe secret key in Functions config or Secret Manager.

After these are done, you can start implementing the app (SecretConfig + Flutter UI + cubit), the callable (create Customer, Ephemeral Key, SetupIntent), and wire the demo to the Example page.

## What exists today (repo context)

- **No Stripe SDK** currently in `pubspec.yaml`.
- DI is centralized via GetIt in [lib/core/di/injector.dart](../lib/core/di/injector.dart) and registrations in [lib/core/di/injector_registrations.dart](../lib/core/di/injector_registrations.dart).
- Secrets are handled via `SecretConfig` and documented in [security_and_secrets.md](security_and_secrets.md). The app already depends on `cloud_functions`, so Firebase callable functions are a good fit.

## Recommended integration approach (demo-friendly)

### Option A (recommended): Stripe PaymentSheet + backend-created SetupIntent

- **Frontend (app)** uses `flutter_stripe` to present **PaymentSheet** in **setup** mode.
- **Backend** (recommended: Firebase Callable Cloud Function) creates:
  - a Stripe **Customer**
  - an **Ephemeral Key** for the customer
  - a **SetupIntent** for the customer
  - returns `{customerId, ephemeralKeySecret, setupIntentClientSecret}`.
- App initializes `Stripe.instance.initPaymentSheet(...)` and calls `presentPaymentSheet()`.

### Option B: Custom UI / lower-level confirmSetupIntent

- More code + more edge cases; not needed for a demo in this repo.

## Architecture / file layout

Create a new feature module `payments`.

- **Domain** (Flutter-agnostic):
  - [lib/features/payments/domain/payment_method_repository.dart](../lib/features/payments/domain/payment_method_repository.dart) (interface)
  - Entities / failures (e.g. `SetupIntentParams`, `PaymentMethodId`, `PaymentsFailure`)
- **Data**:
  - [lib/features/payments/data/stripe_payment_method_repository.dart](../lib/features/payments/data/stripe_payment_method_repository.dart)
  - [lib/features/payments/data/payments_functions_api.dart](../lib/features/payments/data/payments_functions_api.dart) (wrap `cloud_functions` call)
- **Presentation**:
  - [lib/features/payments/presentation/cubit/payments_cubit.dart](../lib/features/payments/presentation/cubit/payments_cubit.dart)
  - [lib/features/payments/presentation/cubit/payments_state.dart](../lib/features/payments/presentation/cubit/payments_state.dart) (prefer `freezed`)
  - [lib/features/payments/presentation/pages/payments_demo_page.dart](../lib/features/payments/presentation/pages/payments_demo_page.dart)

## Dependency injection

- Add [lib/core/di/register_payments_services.dart](../lib/core/di/register_payments_services.dart) and call it from `registerAllDependencies()` in [lib/core/di/injector_registrations.dart](../lib/core/di/injector_registrations.dart).
- Follow existing pattern: `registerXServices()` per feature; presentation does not reference GetIt directly.

## Routing / navigation

- Add a new route constant in [lib/core/router/app_routes.dart](../lib/core/router/app_routes.dart) (e.g. `payments` / `paymentsPath`).
- Wire in GoRouter in [lib/app/router/routes.dart](../lib/app/router/routes.dart) similarly to the calculator feature's pattern: create `PaymentsCubit` in the route builder and inject the domain repository.

### Demo page access (easy discoverability)

Make the Stripe demo **easily accessible from the central demo (Example) page** so users can open it in one tap:

- **Example page** = [lib/features/example/presentation/pages/example_page.dart](../lib/features/example/presentation/pages/example_page.dart) (route `/example`); it uses `ExamplePageBody` which lists demo buttons (WebSocket, Chat, Todo, Library, Scapes, WalletConnect, etc.).
- Add a **Stripe/Payments demo button** on that page:
  - In `ExamplePageBody`: add callback `onOpenPaymentsDemo` and a new `_buildIconButton` that calls it, with label from l10n (e.g. `examplePaymentsDemoButton`), icon e.g. `Icons.credit_card` or `Icons.payment`.
  - In `ExamplePage`: pass `onOpenPaymentsDemo: () => context.pushNamed(AppRoutes.payments)` into `ExamplePageBody`.
- Add l10n key in [lib/l10n/app_en.arb](../lib/l10n/app_en.arb) (and other locales), e.g. `"examplePaymentsDemoButton": "Stripe Save Card Demo"`.
- Place the button among the other demo buttons (e.g. after WalletConnect Auth or after Library Demo).

## Secrets and configuration

- **App (publishable key)**: add a `SecretConfig` entry for Stripe publishable key (test key) and load it in bootstrap (pattern already exists in `SecretConfig`).
- **Backend (secret key)**: store Stripe secret key only in backend environment; never in app.
- Add a snippet to [security_and_secrets.md](security_and_secrets.md) describing:
  - required `--dart-define=STRIPE_PUBLISHABLE_KEY=...` for demo
  - local dev fallback via `assets/config/secrets.json` only if the repo's dev-only gate is enabled.

## iOS/Android native setup (minimum)

- Add `flutter_stripe` and follow its platform setup:
  - iOS: update `Info.plist` if needed (URL schemes / return URL) depending on chosen flow.
  - Android: ensure min SDK / gradle settings are compatible.
- Keep the "demo" limited to saving a card (no Apple Pay / Google Pay scope creep).

## Backend (recommended) — Firebase Callable Function

Since the repo currently has no `functions/` directory, plan is to add one (or integrate with an existing Firebase project you already use):

- Create `functions/` Node/TS project (standard Firebase Functions layout).
- Implement a callable function `createSetupIntent` that:
  - Authenticates user (or allows unauth demo with a clear switch)
  - Creates/looks up Stripe Customer (store mapping in Firestore if desired)
  - Creates ephemeral key (with Stripe API version pinned)
  - Creates SetupIntent
  - Returns secrets to the app.

If you prefer not to add backend code into this repo, the plan will instead define the expected HTTP/callable contract and the app will call your existing backend.

## UI/UX and localization

- Add a simple `PaymentsDemoPage` with:
  - primary CTA: `context.l10n.paymentsSaveCard`
  - loading + error states driven by cubit
- Add l10n keys to `lib/l10n/app_*.arb` (no hardcoded strings).
- Use theme colors/typography only (no hardcoded colors).

## Testing strategy (repo-aligned)

- **Unit/bloc tests** for `PaymentsCubit`:
  - success path: repository returns setup secrets; cubit reaches `ready` then `completed`.
  - failure path: repository throws domain failure; cubit emits error state.
- **Widget test** for `PaymentsDemoPage`:
  - renders CTA, shows loading when tapped, renders error text from state.
- Keep Stripe SDK calls behind a seam:
  - presentation uses a `StripePaymentSheetService` interface so tests can fake it without platform channels.

## Verification (required in this repo)

- Run `./bin/checklist`.
- Run tests with coverage (`tool/test_coverage.sh`) and update summary (`dart run tool/update_coverage_summary.dart`).
- Ensure validation scripts pass: hardcoded strings/colors, `context.mounted`, `isClosed` guards, and architecture checks.

## Rollout flags (demo safety)

- Gate the route behind flavor or a remote-config flag if desired (repo already has flavors and remote config registered). Default: show only in dev builds.

## Implementation checklist

- [ ] Confirm where to store Stripe publishable key via SecretConfig and where bootstrap loads it; identify best place to initialize Stripe in app startup.
- [ ] Add new payments feature module (domain/data/presentation) with repository interface, cubit/state, and demo page using l10n + theming.
- [ ] Register payments services in GetIt; add payments route in app_routes.dart and routes.dart; add Stripe demo button and onOpenPaymentsDemo on Example page (ExamplePageBody + ExamplePage) and l10n key so the demo is easily accessible from the demo page.
- [ ] Add flutter_stripe dependency and complete Android + iOS native configuration needed for PaymentSheet (setup mode).
- [ ] Add Firebase callable function (recommended) or document required backend contract to create customer + ephemeral key + setup intent and return secrets.
- [ ] Add cubit + widget tests, then run ./bin/checklist, coverage update, and fix any validation script failures.
