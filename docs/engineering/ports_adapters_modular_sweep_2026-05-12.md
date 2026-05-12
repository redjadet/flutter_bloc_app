# Ports & adapters sweep — modular plan follow-up (2026-05-12)

Point-in-time inventory of **cross-feature** dependencies that are good candidates for `lib/core/` or `lib/shared/` ports (following `GraphqlCacheClearPort` / `ProfileCacheControlsPort` patterns).

## Data / infra layer

| From | To | Observation |
| ---- | -- | ----------- |
| `chat` | `remote_config` | `render_orchestration_hf_token_provider.dart` reads remote config repositories/services. Candidate: narrow `RemoteConfigStringPort` or reuse `RemoteConfigService` from domain if already abstracted in core. |
| `case_study_demo` | `camera_gallery` | Domain/data import shared camera result types. Candidate: move DTOs/error keys to `shared/` or `core` if reused by multiple features. |
| `case_study_demo` | `supabase_auth` | Auth repository type in presentation. Candidate: depend on `SupabaseAuthRepository` interface re-exported from `core` (if not already). |
| `injector_registrations` | `chart`, `iot_demo`, many features | Expected at composition root; not a leak. |

## Presentation layer

Cross-feature UI imports are listed by `bash tool/modular_metrics.sh --cross-feature-only`. Prefer **app-layer composition** (router builds widgets, passes parameters) per `docs/modularity.md`.

## Next actions (prioritized)

1. Classify each `--cross-feature-only` row: move to app, shared DTO, or core port (document owner in `docs/modularity.md` Phase 1B table when promoting default-deny).
2. Start with **chat → remote_config** if orchestration token path grows further.
3. No code changes in this sweep doc-only pass.
