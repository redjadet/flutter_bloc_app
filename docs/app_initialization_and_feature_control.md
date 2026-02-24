# App Initialization and Feature/Endpoint Control

## Have you implemented app initialization logic that controls feature or endpoint behavior?

**High-level answer:** Applications should implement **explicit app initialization logic** that (1) runs once at startup, (2) resolves build- and environment-dependent configuration (e.g. flavor, environment variables), and (3) exposes a **single runtime config** that features and endpoints read for toggles and URLs. Remote or dynamic config (e.g. feature flags from a server) can remain on-demand so startup stays fast.

---

## Why it matters

- **Compliance and audit:** One place that defines what is enabled and which endpoints are used at app start.
- **Predictability:** Feature and endpoint behavior is determined at a known moment (bootstrap) instead of scattered checks.
- **Testability:** Tests can inject or override the same config object.

---

## General implementation pattern

### 1. Bootstrap runs first

- **Before** painting the first frame, run a single bootstrap sequence that:
  - Binds the app to a **flavor** or environment (e.g. dev, staging, prod).
  - Loads **secrets** and **platform** setup as needed.
  - Initializes **dependency injection** and registers a **runtime config** object.
  - Optionally runs **migrations** or other one-time setup.

### 2. Single runtime config (init-time)

- Introduce an **app runtime config** (e.g. `AppRuntimeConfig`) that is **created during or right after bootstrap** and registered in DI.
- It should hold only what is known at init time, for example:
  - **Flavor / environment** (e.g. dev, staging, prod).
  - **Endpoint base URLs** (from env, compile-time defines, or flavor).
  - **Feature toggles** that are fixed at build or startup (e.g. from `bool.fromEnvironment` or a small config file).
- Features and API clients **read from this config** instead of calling environment or flavor APIs directly. That gives one place to control behavior for compliance and consistency.

### 3. Remote/dynamic config stays on-demand (optional)

- Server-driven feature flags (e.g. Firebase Remote Config) can stay **on-demand**: loaded when a feature first needs them, not during bootstrap.
- This keeps startup fast and avoids blocking the first frame on the network. The **init-time config** still gives a single place for “what was decided at app start”; remote config can override or extend for dynamic toggles.

### 4. What “controls” means

- **Feature behavior:** Whether a feature is available, or how it behaves (e.g. delays, debug menus), can be derived from the runtime config (flavor + init-time toggles) and optionally from remote config when loaded.
- **Endpoint behavior:** Base URLs and which backend to use should come from the runtime config (flavor + env) so all clients use the same source of truth.

---

## Summary table

| Concern                | Where it’s decided     | When       | Who uses it                      |
|------------------------|------------------------|------------|----------------------------------|
| Flavor / environment   | Bootstrap              | At startup | Runtime config → features        |
| Base URLs / endpoints  | Bootstrap (env/flavor) | At startup | Runtime config → API clients     |
| Init-time toggles      | Bootstrap (env/flavor) | At startup | Runtime config → features        |
| Remote feature flags   | On first use           | Lazy       | Features that need them          |

---

## Checklist for any application

- [ ] A single bootstrap sequence runs before the first frame (e.g. `BootstrapCoordinator.bootstrapApp()`).
- [ ] A runtime config object is created at bootstrap and registered in DI (e.g. `AppRuntimeConfig`).
- [ ] Flavor/environment and, where applicable, base URLs and init-time feature toggles are exposed via this config.
- [ ] Features and API clients read from the runtime config instead of ad hoc flavor/env checks.
- [ ] Remote/dynamic config (if used) remains on-demand; init-time config remains the single place for “decided at app start.”

This gives a clear, high-level “yes” to: **Have you implemented app initialization logic that controls feature or endpoint behavior?** — by having explicit bootstrap plus a single init-time config that features and endpoints use.

---

## This project

- **Bootstrap:** [lib/core/bootstrap/bootstrap_coordinator.dart](../lib/core/bootstrap/bootstrap_coordinator.dart) sets flavor, runs platform init, secrets, Firebase, DI, migrations, and materializes [AppRuntimeConfig](../lib/core/config/app_runtime_config.dart) before `runApp`.
- **Runtime config:** [AppRuntimeConfig](../lib/core/config/app_runtime_config.dart) holds flavor, optional `apiBaseUrl` (from `--dart-define=API_BASE_URL`), and `skeletonDelay`; built via `AppRuntimeConfig.fromBootstrap()` and registered in DI. Features and repositories (e.g. counter route, [DelayedChartRepository](../lib/features/chart/data/delayed_chart_repository.dart)) read from it for init-controlled behavior.
- **Remote config:** Firebase Remote Config remains on-demand (`RemoteConfigCubit.ensureInitialized()` when a feature needs it); see [lazy_loading_review.md](lazy_loading_review.md).
