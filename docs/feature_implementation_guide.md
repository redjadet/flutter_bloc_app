# Feature Delivery Guide

This document explains how to deliver new features in this repo without
repeating the implementation detail already covered elsewhere. Use it as a
routing document: it tells you where to build, what to update, and which docs
own each concern.

**App package layout:** feature code lives under `apps/mobile/lib/features/`
until an explicit extraction PR. Validation scripts still use APP_ROOT-relative
`lib/**` shorthand (resolved via `tool/workspace_paths.sh` → `apps/mobile`).

Non-trivial features should start from the Feature Brief and AI alignment
checklist in [`docs/plans/FEATURE_TEMPLATE.md`](plans/FEATURE_TEMPLATE.md).
`./bin/checklist` runs `tool/check_feature_brief_linked.sh`, which fails by
default for feature Dart changes without a `docs/changes/` note. Use
`SKIP_FEATURE_BRIEF=1` only for documented trivial fixes.

## Definition of done

A new or materially changed feature should usually include:

1. Domain contracts and models under `apps/mobile/lib/features/<feature>/domain/`.
2. Data implementations under `apps/mobile/lib/features/<feature>/data/`.
3. Cubit, pages, and widgets under `apps/mobile/lib/features/<feature>/presentation/`.
4. DI registration under `apps/mobile/lib/app/composition/`.
5. Route wiring in `apps/mobile/lib/app/router/app_routes.dart` and `apps/mobile/lib/app/router/`.
6. Tests from the Feature Brief **Tests** contract (RED with implementation, not a follow-up-only PR).
7. Relevant docs refreshed when behavior, setup, or workflows changed.
8. Validation run through the repo commands, typically `./bin/checklist`.

## Delivery workflow in this repo

| Step | What to do |
| --- | --- |
| Brief + contract | Copy [`FEATURE_TEMPLATE.md`](plans/FEATURE_TEMPLATE.md); fill **Tests** (behaviour, state, unit, integration as needed). |
| Reuse first | Check existing packages, `apps/mobile/lib/app/`, and adjacent features before adding new abstractions. |
| Place files | Follow [`architecture/feature_structure_contract.md`](architecture/feature_structure_contract.md); copy live layout from [`architecture/reference_features.md`](architecture/reference_features.md). |
| Keep boundaries clean | Stay within `Presentation -> Domain <- Data`. |
| Use cases / DTOs | Apply [`architecture/use_case_dto_policy.md`](architecture/use_case_dto_policy.md). |
| Model state | Apply [`bloc_standards.md`](bloc_standards.md) before adding or changing Cubit/BLoC code. |
| Domain / data | RED unit or cubit tests for contracts; minimal implementation to green. |
| Register dependencies | Use the feature-specific `register_*_services.dart` files or `injector_registrations.dart`. |
| Wire routes intentionally | Add route constants first, then update the route group that owns the flow. |
| Presentation | RED widget tests for behaviour + state where P0/P1 applies; then UI. |
| Update generated code | Run `build_runner` when touching Freezed, JSON, Retrofit, or related annotations. |
| Prove | `bash tool/check_feature_folder_contract.sh`; `flutter test <paths>` from the brief; pick validation lane in [`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md). |
| Update docs | Refresh the doc that is already the source of truth instead of copying text into multiple places. |

## Source docs by concern

| Concern | Current state | Primary docs | Primary code paths |
| --- | --- | --- | --- |
| App architecture | Implemented | [Clean Architecture](clean_architecture.md), [Architecture Details](architecture_details.md) | `apps/mobile/lib/app/`, `apps/mobile/lib/features/`, `packages/*/` |
| Feature catalog | Implemented | [Feature Overview](feature_overview.md) | `apps/mobile/lib/features/`, `apps/mobile/lib/app/router/app_routes.dart` |
| API and HTTP integrations | Implemented | [Authentication](authentication.md), [Tech Stack](tech_stack.md), [Security and Secrets](security_and_secrets.md) | `packages/networking/lib/src/`, `apps/mobile/lib/app/composition/features/register_http_services.dart` |
| Firebase setup and usage | Implemented | [Firebase Setup](integrations/firebase_setup.md), [Authentication](authentication.md) | `apps/mobile/lib/app/bootstrap/`, `apps/mobile/lib/features/auth/`, `functions/` |
| Supabase-backed flows | Implemented where configured | [Authentication](authentication.md), [Security and Secrets](security_and_secrets.md) | `apps/mobile/lib/features/supabase_auth/`, `apps/mobile/lib/features/iot_demo/`, `apps/mobile/lib/app/composition/features/register_supabase_services.dart` |
| Offline-first patterns | Implemented | [Offline-First Adoption Guide](offline_first/adoption_guide.md) | `packages/storage/lib/src/sync/`, feature repositories with `OfflineFirst*` implementations |
| Testing and validation | Implemented | [Testing Overview](testing_overview.md), [Validation Scripts](validation_scripts.md) | `test/`, `integration_test/`, `tool/`, `bin/` |
| Deployment and release | Implemented | [Deployment](deployment.md), [Firebase App Distribution](integrations/firebase_app_distribution.md), [Android Play Store Release SOP](engineering/android_play_store_release_sop.md) | `fastlane/Fastfile`, `tool/fastlane.sh`, `tool/release_both_stores.sh`, `tool/release_android_play.sh` |
| FCM demo and notification-triggered sync | Implemented | [FCM Demo Integration](integrations/fcm_demo_integration.md) | `apps/mobile/lib/features/fcm_demo/`, `packages/storage/lib/src/sync/` |
| Maps | Implemented | [Google Maps Integration](integrations/google_maps_integration.md) | `apps/mobile/lib/features/google_maps/`, deferred route files |
| AI and GenUI demos | Implemented | [AI Integration](integrations/ai_integration.md), [GenUI Demo User Guide](features/genui_demo_user_guide.md) | `apps/mobile/lib/features/chat/`, `apps/mobile/lib/features/genui_demo/` |
| Payments | Partially implemented | [Stripe Demo Integration Plan](integrations/stripe_demo_integration_plan.md) | `apps/mobile/lib/features/in_app_purchase_demo/` |

## Adding a new feature

1. Create `apps/mobile/lib/features/<feature>/domain/` for contracts and models.
2. Implement the repositories or services in `data/`.
3. Add cubits and UI in `presentation/`.
4. Register dependencies in `apps/mobile/lib/app/composition/`.
5. Add or update route constants in `apps/mobile/lib/app/router/app_routes.dart`.
6. Wire the page in the correct route group under `apps/mobile/lib/app/router/`.
7. Add or extend tests per the brief **Tests** section (same change series as implementation).
8. Update the feature catalog if the feature is user-visible.

## Documentation ownership

When a change lands, update the document that already owns that topic:

- New feature visible in app: [Feature Overview](feature_overview.md)
- New setup requirement or secret: [Security and Secrets](security_and_secrets.md)
- New platform or backend dependency: [Tech Stack](tech_stack.md)
- New validation behavior: [Validation Scripts](validation_scripts.md)
- New integration flow or testing convention: [Testing Overview](testing_overview.md)
- New release step: [Deployment](deployment.md) or
  [Android Play Store Release SOP](engineering/android_play_store_release_sop.md)

Avoid copying the same setup or implementation prose into multiple docs.

## Related docs

- [New Developer Guide](new_developer_guide.md)
- [Feature Overview](feature_overview.md)
- [Tech Stack](tech_stack.md)
- [Testing Overview](testing_overview.md)
- [Testing Matrix Required By Change](testing/matrix_required_by_change.md)
- [Feature Structure Contract](architecture/feature_structure_contract.md)
- [Use Case And DTO Policy](architecture/use_case_dto_policy.md)
- [BLoC Standards](bloc_standards.md)
- [Architecture Review Checklist](review/architecture_checklist.md)
- [BLoC Review Checklist](review/bloc_checklist.md)
- [Contributing](contributing/contributing.md)
