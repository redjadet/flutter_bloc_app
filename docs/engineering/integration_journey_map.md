# Integration Journey Map

This map links must-have user journeys to executable integration targets and
tier expectations.

## J1 Auth/session lifecycle

- **Goal:** Anonymous guest sign-in reaches Home/counter; router allows
  anonymous users off `/auth` except `?upgrade=true`; session-safe navigation.
- **Primary target:** `integration_test/guest_sign_in_flow_test.dart`
  (`registerGuestSignInIntegrationFlow`: real Firebase Auth, Continue as guest,
  Home Page + anonymous `AuthRepository` user).
- **Secondary target:** `integration_test/standard_flows_test.dart` (broader
  auth/session navigation).
- **Negative path:** stale session behavior during navigation guarded by app
  state assertions; unit/widget coverage in `test/app/router/auth_redirect_test.dart`,
  `test/core/di/register_auth_services_test.dart`, `test/sign_in_page_test.dart`
  via `./bin/router_feature_validate`.
- **Tier:** `pr_smoke`, `smoke`, `standard`, `exhaustive`
- **Owner:** feature QA owner

## J2 Core CRUD flow

- **Goal:** Todo add/filter/completion end-to-end.
- **Primary target:** `integration_test/todo_list_flow_test.dart`
- **Negative path:** completed vs active filtering check.
- **Tier:** `smoke`, `standard`, `exhaustive`
- **Owner:** feature QA owner

## J3 Offline to online recovery

- **Goal:** state restoration/persistence continuity through app lifecycle.
- **Primary target:** `integration_test/counter_persistence_test.dart`
- **Negative path:** rebuild and restore verification.
- **Tier:** `standard`, `exhaustive`
- **Owner:** feature QA owner

## J4 Error + retry user path

- **Goal:** visible empty/error handling and user recovery path.
- **Primary target:** `integration_test/search_flow_test.dart`
- **Negative path:** empty-result state assertion.
- **Tier:** `standard`, `exhaustive`
- **Owner:** feature QA owner

## J5 RTDB remote wiring

- **Goal:** Counter and Todo offline-first repositories keep Realtime Database
  remotes wired when integration tests run with real plugin-backed Firebase Auth.
- **Primary target:** `integration_test/rtdb_remote_wiring_flow_test.dart`
- **Negative path:** mock-auth integration harness still omits RTDB remotes to
  avoid unauthenticated plugin stream timeouts.
- **Tier:** targeted real-Firebase proof, not aggregate tier by default
- **Owner:** feature QA owner

## J6 Demo showcase reachability

- **Goal:** Example-page demos open and render primary content (educational
  showcases reachable without platform guards).
- **Primary target (native platform):**
  `integration_test/native_platform_showcase_flow_test.dart`
  (`registerNativePlatformShowcaseIntegrationFlow`: Example →
  `example-native-platform-showcase-button` → summary → native security section
  (`native-security-showcase-section` + five cards; noninteractive crypto/AES/storage
  taps; no secret-looking text) → live interop tiles
  `native-platform-showcase-interop-{swift,kotlin,cpp}` + lesson 0 + platform/UI
  family labels). Scroll past the security section before asserting interop keys
  (ListView may not build off-screen children).
- **Web lane:** `test/integration_preflight/web_bootstrap_smoke_test.dart`
  (`opens native platform showcase from Example on web`; scroll security then
  interop; via `./bin/integration_preflight`;
  showcase channel mock registered globally in `test/flutter_test_config.dart` —
  not `integration_test` on web).
- **Tier:** `smoke`, `standard`, `exhaustive` (device integration); web via
  `./bin/integration_preflight`
- **Owner:** feature QA owner

## Aggregate mapping

- `pr_smoke` -> `integration_test/pr_smoke_flows_test.dart`
  (`registerPrSmokeIntegrationFlows`: guest sign-in, launch, charts, search,
  settings, todo, counter persistence, chat list)
- `smoke` -> `integration_test/smoke_flows_test.dart`
- `standard` -> `integration_test/standard_flows_test.dart`
  (`registerStandardIntegrationFlows`: smoke + extended; see `flow_scenarios.dart`)
- `exhaustive` -> `integration_test/all_flows_test.dart`
  (`registerAllIntegrationFlows`: standard plus `registerExhaustiveOnlyIntegrationFlows`,
  including deterministic GraphQL network error + **Try again** recovery)

## CI workflow shape

- **Pull requests / merge queue:** `CI / integration-preflight` runs
  `./bin/integration_preflight` automatically (browser/bootstrap guardrails).
- **Manual dispatch:** enable `run_integration` on **Actions → CI → Run workflow**
  to run the macOS simulator lane after preflight passes. Choose
  `integration_tier` (`smoke` | `standard` | `exhaustive`).

See [`ci_automation.md`](ci_automation.md) and
[`validation_scripts/overview.md`](../validation_scripts/overview.md) for the
current GitHub Actions contract.

## Notes

- Keep aggregate suite as canonical gate.
- Add new integration tests by first attaching them to one journey and one tier.
