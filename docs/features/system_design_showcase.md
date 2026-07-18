# System design showcase

This doc maps engineering claims to live code, docs, and commands. Use it for
architecture review, technical discussion, or interview follow-up. Do not
present planned integrations as shipped.

## Talk track

| Skill signal | Positioning | Proof |
| --- | --- | --- |
| Architecture decisions | Modular monolith, feature Clean Architecture, Cubit-first presentation, app-level DI composition, offline-first data layer. | [`adr/README.md`](../adr/README.md), [`clean_architecture.md`](../clean_architecture.md), [`architecture_details.md`](../architecture_details.md) |
| System design | App shell composes route-scoped features; domain contracts hide storage, HTTP, Firebase, Supabase, platform channels, and sync queues. | [`apps/mobile/lib/app/bootstrap/bootstrap_coordinator.dart`](../../apps/mobile/lib/app/bootstrap/bootstrap_coordinator.dart), [`apps/mobile/lib/app/composition/injector_registrations.dart`](../../apps/mobile/lib/app/composition/injector_registrations.dart), [`apps/mobile/lib/app/router/routes.dart`](../../apps/mobile/lib/app/router/routes.dart) |
| Production operations | Scripted release, CI delivery gate, drift checks, integration tiers, and Crashlytics when Firebase is enabled. | [`deployment.md`](../deployment.md), [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml), [`observability.md`](../observability.md) |
| Security | Runtime secret injection, secure storage abstraction, auth route policy, denial checks, and tracked-secret scanning. | [`security_and_secrets.md`](../security_and_secrets.md), [`review/security_checklist.md`](../review/security_checklist.md), [`tool/check_tracked_secret_literals.sh`](../../tool/check_tracked_secret_literals.sh) |

## Architecture decisions

| Decision | Why it matters | Code/doc evidence |
| --- | --- | --- |
| Feature-based Clean Architecture | Keeps demo breadth maintainable without cross-feature dependency sprawl. | [`adr/0001-architecture-and-layering.md`](../adr/0001-architecture-and-layering.md), [`tool/check_clean_architecture_imports.sh`](../../tool/check_clean_architecture_imports.sh) |
| Offline-first repositories | User actions persist locally, then replay through a queue when network/backend is ready. | [`adr/0002-offline-first-data.md`](../adr/0002-offline-first-data.md), [`packages/storage/lib/src/sync/pending_sync_repository.dart`](../../packages/storage/lib/src/sync/pending_sync_repository.dart), [`packages/networking/lib/src/sync/background_sync_coordinator.dart`](../../packages/networking/lib/src/sync/background_sync_coordinator.dart) |
| Deferred routed features | Heavy or infrequent demos do not bloat initial route cost. | [`adr/0003-deferred-feature-loading.md`](../adr/0003-deferred-feature-loading.md), [`apps/mobile/lib/app/router/deferred_pages/`](../../apps/mobile/lib/app/router/deferred_pages) |
| Type-safe Cubit access | Routine UI code avoids stringly typed provider lookups and stale context patterns. | [`adr/0004-type-safe-cubit-access.md`](../adr/0004-type-safe-cubit-access.md), [`docs/bloc_standards.md`](../bloc_standards.md) |
| Frozen interview spine | Portfolio demo stays honest and repeatable instead of claiming every route as production-critical. | [`adr/0005-interview-showcase-scope.md`](../adr/0005-interview-showcase-scope.md), [`interview_showcase.md`](../interview_showcase.md) |

## Production operations

| Operational concern | Current answer | Proof |
| --- | --- | --- |
| Pre-merge gate | `./bin/checklist` runs the delivery checklist; `./bin/checklist-fast` is docs/tooling local sanity only. | [`validation_scripts.md`](../validation_scripts.md), [`engineering/validation_routing_fast_vs_full.md`](../engineering/validation_routing_fast_vs_full.md) |
| Integration tiers | Browser/bootstrap preflight, PR smoke, smoke/standard/exhaustive integration tiers. | [`engineering/integration_runner_contract.md`](../engineering/integration_runner_contract.md), [`engineering/integration_journey_map.md`](../engineering/integration_journey_map.md) |
| Release path | Fastlane wrappers for TestFlight, Play internal, dual-store deploy, and web Pages. | [`deployment.md`](../deployment.md), [`tool/release_both_stores.sh`](../../tool/release_both_stores.sh), [`tool/fastlane.sh`](../../tool/fastlane.sh) |
| Drift and dependency risk | CI, nightly drift, dependency review, OSV, Dependabot security-only updates. | [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml), [`.github/workflows/drift.yml`](../../.github/workflows/drift.yml), [`.github/dependabot.yml`](../../.github/dependabot.yml) |
| Incident triage | Structured error codes, `AppLogger`, Crashlytics handlers, sync diagnostics UI. | [`observability.md`](../observability.md), [`packages/utilities/lib/src/errors/error_codes.dart`](../../packages/utilities/lib/src/errors/error_codes.dart), [`apps/mobile/lib/features/settings/presentation/widgets/sync_diagnostics_section.dart`](../../apps/mobile/lib/features/settings/presentation/widgets/sync_diagnostics_section.dart) |

## Security and trust boundaries

| Boundary | Current design | Proof |
| --- | --- | --- |
| Secrets | Local and CI values flow through env / `--dart-define`; real platform config files stay gitignored. | [`security_and_secrets.md`](../security_and_secrets.md), [`tool/flutter_dart_defines_from_env.sh`](../../tool/flutter_dart_defines_from_env.sh) |
| Local sensitive storage | `SecretStorage` wraps secure storage; Apple debug uses in-memory fallback because simulator Keychain is unreliable. | [`packages/app_shared_flutter/lib/src/platform/secure_secret_storage.dart`](../../packages/app_shared_flutter/lib/src/platform/secure_secret_storage.dart), [`engineering/apple_debug_hive_storage.md`](../engineering/apple_debug_hive_storage.md) |
| Auth routing | Global redirect handles app entry; route-level auth gates remain required for protected deep links. | [`apps/mobile/lib/app/router/auth_redirect.dart`](../../apps/mobile/lib/app/router/auth_redirect.dart), [`apps/mobile/lib/app/router/route_auth_policy.dart`](../../apps/mobile/lib/app/router/route_auth_policy.dart) |
| Backend caller auth | Render orchestration uses Firebase caller auth plus a dedicated HF token header; Remote Config is documented as client config, not a secret store. | [`docs/integrations/render_fastapi_chat_demo.md`](../integrations/render_fastapi_chat_demo.md), [`apps/mobile/lib/features/chat/data/render_fastapi_chat_repository_send.part.dart`](../../apps/mobile/lib/features/chat/data/render_fastapi_chat_repository_send.part.dart) |
| Review gate | Security checklist requires denial-path tests and secret scanners when auth/storage/networking/config changes. | [`review/security_checklist.md`](../review/security_checklist.md), [`tool/check_ai_generated_code_smells.sh`](../../tool/check_ai_generated_code_smells.sh) |

## System design prompts

Use these if asked to reason beyond the demo.

| Prompt | Answer shape |
| --- | --- |
| How does the app scale from demos to product modules? | Keep modular monolith until team/deploy boundaries justify split; enforce feature folders, domain purity, DI seams, and route ownership. |
| What fails offline? | Writes persist locally where feature has offline-first support; queue replay is bounded by idempotent operations and conflict policy. Features without offline support must degrade explicitly. |
| How would you debug a production incident? | Classify by `AppErrorCode`, inspect Crashlytics/log context, check sync queue depth, reproduce with integration tier, patch with focused test plus checklist. |
| How do you keep secrets safe in mobile/web? | Never treat client-distributed config as a server secret; prefer server-side secrets or short-lived tokens; avoid logging tokens/payloads; scan tracked files. |
| What would you change before real production traffic? | Finalize backend authorization/RLS, analytics taxonomy, SLO dashboards, remote kill switches, alert routing, and release rollback policy. |

## Proof commands

```bash
# Docs/showcase changes
./bin/checklist-fast --no-reuse

# Architecture boundary proof
bash tool/check_clean_architecture_imports.sh
bash tool/check_feature_modularity_leaks.sh

# Security/config proof
bash tool/check_tracked_secret_literals.sh
bash tool/check_ai_generated_code_smells.sh

# Broad pre-merge proof
./bin/checklist
```

## Boundaries

- Crashlytics is active only when Firebase initializes.
- Product analytics SDKs such as Mixpanel or Sentry are not configured today.
- Remote Config is not a secret store.
- Store deployment needs maintainer credentials and dashboard access.
- Some feature modules are portfolio depth branches, not production-critical
  flows. Use [`interview_showcase.md`](../interview_showcase.md) for the frozen
  spine.
