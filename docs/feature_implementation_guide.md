# Feature Delivery Guide

This document explains how to deliver new features in this repo without
repeating the implementation detail already covered elsewhere. Use it as a
routing document: it tells you where to build, what to update, and which docs
own each concern.

## Definition of done

A new or materially changed feature should usually include:

1. Domain contracts and models under `lib/features/<feature>/domain/`.
2. Data implementations under `lib/features/<feature>/data/`.
3. Cubit, pages, and widgets under `lib/features/<feature>/presentation/`.
4. DI registration under `lib/core/di/`.
5. Route wiring in `lib/core/router/app_routes.dart` and `lib/app/router/`.
6. Tests updated at the right scope.
7. Relevant docs refreshed when behavior, setup, or workflows changed.
8. Validation run through the repo commands, typically `./bin/checklist`.

## Delivery workflow in this repo

| Step | What to do |
| --- | --- |
| Reuse first | Check `lib/shared/`, `lib/core/`, and adjacent features before adding new abstractions. |
| Keep boundaries clean | Stay within `Domain -> Data -> Presentation`. |
| Register dependencies | Use the feature-specific `register_*_services.dart` files or `injector_registrations.dart`. |
| Wire routes intentionally | Add route constants first, then update the route group that owns the flow. |
| Update generated code | Run `build_runner` when touching Freezed, JSON, Retrofit, or related annotations. |
| Add tests | Prefer focused regression coverage close to the changed behavior. |
| Update docs | Refresh the doc that is already the source of truth instead of copying text into multiple places. |

## Source docs by concern

| Concern | Current state | Primary docs | Primary code paths |
| --- | --- | --- | --- |
| App architecture | Implemented | [Clean Architecture](clean_architecture.md), [Architecture Details](architecture_details.md) | `lib/app/`, `lib/core/`, `lib/features/`, `lib/shared/` |
| Feature catalog | Implemented | [Feature Overview](feature_overview.md) | `lib/features/`, `lib/core/router/app_routes.dart` |
| API and HTTP integrations | Implemented | [Authentication](authentication.md), [Tech Stack](tech_stack.md), [Security and Secrets](security_and_secrets.md) | `lib/shared/http/`, `lib/core/di/register_http_services.dart` |
| Firebase setup and usage | Implemented | [Firebase Setup](firebase_setup.md), [Authentication](authentication.md) | `lib/core/bootstrap/`, `lib/features/auth/`, `functions/` |
| Supabase-backed flows | Implemented where configured | [Authentication](authentication.md), [Security and Secrets](security_and_secrets.md) | `lib/features/supabase_auth/`, `lib/features/iot_demo/`, `lib/core/di/register_supabase_services.dart` |
| Offline-first patterns | Implemented | [Offline-First Adoption Guide](offline_first/adoption_guide.md) | `lib/shared/sync/`, feature repositories with `OfflineFirst*` implementations |
| Testing and validation | Implemented | [Testing Overview](testing_overview.md), [Validation Scripts](validation_scripts.md) | `test/`, `integration_test/`, `tool/`, `bin/` |
| Deployment and release | Implemented | [Deployment](deployment.md), [Firebase App Distribution](firebase_app_distribution.md), [Android Play Store Release SOP](android_play_store_release_sop.md) | `fastlane/`, `tool/`, platform folders |
| FCM demo and notification-triggered sync | Implemented | [FCM Demo Integration](fcm_demo_integration.md) | `lib/features/fcm_demo/`, `lib/shared/sync/` |
| Maps | Implemented | [Google Maps Integration](google_maps_integration.md) | `lib/features/google_maps/`, deferred route files |
| AI and GenUI demos | Implemented | [AI Integration](ai_integration.md), [GenUI Demo User Guide](genui_demo_user_guide.md) | `lib/features/chat/`, `lib/features/genui_demo/` |
| Payments | Partially implemented | [Stripe Demo Integration Plan](stripe_demo_integration_plan.md) | `lib/features/in_app_purchase_demo/` |

## Adding a new feature

1. Create `lib/features/<feature>/domain/` for contracts and models.
2. Implement the repositories or services in `data/`.
3. Add cubits and UI in `presentation/`.
4. Register dependencies in `lib/core/di/`.
5. Add or update route constants in `lib/core/router/app_routes.dart`.
6. Wire the page in the correct route group under `lib/app/router/`.
7. Add tests at the smallest correct scope.
8. Update the feature catalog if the feature is user-visible.

## Documentation ownership

When a change lands, update the document that already owns that topic:

- New feature visible in app: [Feature Overview](feature_overview.md)
- New setup requirement or secret: [Security and Secrets](security_and_secrets.md)
- New platform or backend dependency: [Tech Stack](tech_stack.md)
- New validation behavior: [Validation Scripts](validation_scripts.md)
- New integration flow or testing convention: [Testing Overview](testing_overview.md)
- New release step: [Deployment](deployment.md) or
  [Android Play Store Release SOP](android_play_store_release_sop.md)

Avoid copying the same setup or implementation prose into multiple docs.

## Related docs

- [New Developer Guide](new_developer_guide.md)
- [Feature Overview](feature_overview.md)
- [Tech Stack](tech_stack.md)
- [Testing Overview](testing_overview.md)
- [Contributing](contributing.md)
