# Ports & adapters sweep — modular plan follow-up (2026-05-12)

Point-in-time inventory of **cross-feature** dependencies that are good candidates for `apps/mobile/lib/core/` or `apps/mobile/lib/shared/` ports (following `GraphqlCacheClearPort` / `ProfileCacheControlsPort` patterns).

## Data / infra layer

| From | To | Observation |
| ---- | -- | ----------- |
| ~~`chat`~~ | ~~`remote_config`~~ | **Resolved.** `apps/mobile/lib/core/chat/render_orchestration_remote_token_port.dart` (`RenderOrchestrationRemoteTokenPort`) is implemented by `apps/mobile/lib/features/remote_config/data/render_orchestration_remote_token_adapter.dart` and wired in `register_remote_config_services.dart`. `apps/mobile/lib/features/chat/data/render_orchestration_hf_token_provider.dart` no longer imports `package:flutter_bloc_app/features/remote_config/...`. |
| `case_study_demo` | `camera_gallery` | Domain/data import shared camera result types. Candidate: move DTOs/error keys to `shared/` or `core` if reused by multiple features. |
| `case_study_demo` | `supabase_auth` | Auth repository type in presentation. Candidate: depend on `SupabaseAuthRepository` interface re-exported from `core` (if not already). |
| `injector_registrations` | `chart`, `iot_demo`, many features | Expected at composition root; not a leak. |

## Presentation layer

Cross-feature UI imports are listed by `bash tool/modular_metrics.sh --cross-feature-only`. Prefer **app-layer composition** (router builds widgets, passes parameters) per `docs/modularity.md`.

## Next actions (prioritized)

1. Classify each `--cross-feature-only` row: move to app, shared DTO, or core port (document owner in `docs/modularity.md` Phase 1B table when promoting default-deny).
2. ~~Start with **chat → remote_config** if orchestration token path grows further.~~ **Done** — see `RenderOrchestrationRemoteTokenPort` (`apps/mobile/lib/core/chat/`).
3. Next candidate: `case_study_demo → camera_gallery` shared DTO move.
