# In-App Purchase Demo (Store IAP)

This repo includes a **Store In‑App Purchase demo** for **iOS (App Store)** and **Android (Google Play Billing)** using Flutter’s official `in_app_purchase` plugin.

## Current status (what exists today)

- **Feature module**: `lib/features/in_app_purchase_demo/` (Domain → Data → Presentation)
- **Route**: `AppRoutes.iapDemoPath` (`/iap-demo`) wired in `lib/app/router/routes_demos.dart`
- **Entry point**: “In-app purchases (IAP) demo” button on the Example page
- **IAP types demoed**:
  - **Consumable**: adds 100 “credits”
  - **Non-consumable**: “premium owned”
  - **Subscription**: “subscription active” (demo expiry shown)
- **Two repository paths**:
  - **Fake**: `FakeInAppPurchaseRepository` (deterministic, works on emulator/simulator/CI)
  - **Real**: `FlutterInAppPurchaseRepository` (wraps `in_app_purchase`; requires store sandbox/test track)
- **Entitlements UI**: credits / premium owned / subscription active (+ expiry)
- **UX rules implemented**:
  - “Buy” is **disabled** for premium/subscription when already owned/active (consumables remain buyable)
  - opening the page resets premium/subscription to **No** (demo UX), but preserves credits (see persistence)
- **Tests**: basic unit/cubit/widget tests under `test/features/in_app_purchase_demo/`
- **Validation**: router validation script is expected to pass for changes in this area: `./bin/router_feature_validate`

## What you must do to make real purchases work (production checklist)

### 1) Store console setup (required)

- **iOS (App Store Connect)**
  - Create In‑App Purchase products matching the demo IDs (see `IapDemoProductIds` in `lib/features/in_app_purchase_demo/domain/iap_product.dart`).
  - Complete agreements/tax/banking, and create a sandbox tester.
  - Ensure the iOS build has the In‑App Purchase capability enabled.

- **Android (Play Console)**
  - Create **in‑app products** (consumable + non-consumable) and a **subscription** matching the demo IDs.
  - Upload a build to an internal testing track and add license testers.

### 2) Device/testing constraints (expected)

- **Emulators/simulators** often cannot complete real billing flows. Use the fake path there.
- Real purchase testing requires:
  - **iOS**: sandbox account on a real device (or a correctly configured simulator if supported by your environment).
  - **Android**: internal test track + a Play-account device.

### 2.1) Run on a real device (sandbox) — practical steps

This section is for getting the **current demo** working on a **real device** (not production-hardening).

#### iOS (App Store sandbox)

- **Bundle ID / App record**: the app’s iOS bundle identifier must match an App Store Connect app record.
- **Capabilities**: enable **In‑App Purchase** capability for the iOS target.
- **Products**: create IAP products in App Store Connect matching `IapDemoProductIds`:
  - consumable credits
  - non-consumable premium
  - subscription monthly
- **Sandbox tester**: create a sandbox tester account in App Store Connect.
- **Install on device**: run/install a debug or release build on a physical device.
- **Sign in when prompted**: during purchase, iOS will prompt for sandbox Apple ID credentials.
- **Common gotcha**: if products aren’t “ready for sale” / correctly configured, the store will return “not found” and the demo will show “Unavailable…”.

#### Android (Google Play Billing sandbox)

- **ApplicationId**: the Android `applicationId` must match the Play Console app.
- **Upload a build**: upload an AAB to an **Internal testing** track (or Closed testing).
- **License testers**: add your Gmail as a **license tester** in Play Console.
- **Products**: create in‑app products + subscription matching `IapDemoProductIds`.
- **Install via Play**: install the app from the testing track (recommended), or ensure the device account is eligible.
- **Payments profile**: some setups require Play payments profile / country settings before billing can complete.

#### What “Restore purchases” should (and should not) do

- **Restorable**: non-consumables and subscriptions (premium/subscription flags)
- **Not restorable**: consumables (credits). Credits must be tracked by your app (server or local), not by the store.

### 3) Receipt / purchase validation (recommended for real apps)

The current implementation is **demo-grade** and does **not** validate receipts on a backend.

To make this production‑workable:

- Add a backend endpoint that verifies:
  - **App Store** receipts/transactions
  - **Play Billing** purchase tokens
- Use backend verification results to compute entitlements (premium/subscription) and to prevent fraud/refunds/cancellations from leaving stale access.

### 4) Persist entitlements (recommended)

**Implemented (demo):** credits are persisted locally so they survive reopen/restart.

- **Credits store**: Hive box `iap_demo`, key `credits`
- **Implementation**: `IapDemoCreditsStore` (`HiveIapDemoCreditsStore`) used by both fake/real IAP repositories

Still recommended for production usage, persist:

- last-known entitlements (premium/subscription status, credits balance if you keep a consumable counter)
- last processed purchase ids/tokens (dedupe)

Recommended pattern:

- keep persistence behind a domain repository contract, implement using existing repo storage approach (Hive patterns in this codebase).

### 5) Harden the purchase stream handling (required before shipping)

Even with the plugin, production apps must correctly handle:

- pending/deferred purchases
- duplicate purchase updates
- already-owned scenarios
- store unavailable/offline
- app restarts while a purchase is pending

The demo is a good starting point, but expect a production hardening pass.

## “Fake vs real” behavior (how the demo works)

- **Fake repo**
  - demo-friendly deterministic outcomes by default (success), plus a “Force outcome” control
  - consumable adds +100 credits on success
  - restore affects non-consumable/subscription only (does not promise consumable restore)

- **Real repo**
  - queries `IapDemoProductIds.all`
  - initiates purchases via `in_app_purchase`
  - maps purchase updates into the demo’s `IapPurchaseResult` stream
  - best-effort: `purchase()` waits briefly for the corresponding purchase-stream result so the UI updates right after tapping “Buy”

## Quick dev workflow

- Run the app, open **Example** page, tap **In-app purchases (IAP) demo**
- Use **“Use simulated purchases”** for emulator/simulator
- Run validation when touching router/DI/UI:

```bash
./bin/router_feature_validate
```
