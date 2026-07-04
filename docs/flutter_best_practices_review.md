# ✅ Flutter + Mobile Best Practices Review

**Scope:** app bootstrap, routing, shared utilities, and representative features (counter, settings, auth, profile, chat). This is a focused engineering review, not an exhaustive audit.

## 🔍 What Was Reviewed

- App bootstrap and DI wiring (`apps/mobile/lib/core/`, `apps/mobile/lib/app/`)
- Navigation and route setup (`apps/mobile/lib/app/router/`)
- Shared UI utilities and responsive helpers (`apps/mobile/lib/shared/`)
- Representative features (`apps/mobile/lib/features/counter/`, `apps/mobile/lib/features/settings/`, `apps/mobile/lib/features/chat/`)

## 💪 Strengths Observed

- Clear domain/data/presentation boundaries across features.
- Offline-first repositories use consistent queueing and sync helpers.
- UI layout uses responsive extensions and adaptive components.
- Async safety patterns are applied (mounted checks, guarded emits).
- Null-safe pattern matching is used to convert optional values to non-null locals (`if (x case final value?)`, `switch` null patterns), which reduces reliance on `!`.
- Custom lint rules and validation scripts help enforce architecture rules.

## ⚠️ Risks and Follow-Ups

- `AppScope.build` triggers DI configuration and sync startup. Side effects in `build()` can repeat during rebuilds or hot reload. Consider moving to `initState` or making the calls explicitly idempotent. See `apps/mobile/lib/app/app_scope.dart`.
- ~~Typography customization appears in a few widgets. If the theme is the single source of truth, consider moving ad-hoc font usage into `apps/mobile/lib/core/app_config.dart` to avoid drift.~~ **RESOLVED**: Created `AppTypography` helper class in `apps/mobile/lib/shared/ui/typography.dart` that uses theme as single source of truth.
- A small number of presentation widgets call into concrete repos for diagnostics. This is acceptable for tooling, but keep it contained to avoid architecture drift.

## ✅ Recent Improvements

- **Layering optimization (2026-06)**: Removed domain→data re-export shims (ai_decision, IAP, chat diagnostics, online_therapy network mode, staff timeclock local store). Presentation reads sync/pending state via cubits; composition roots (`routes_*.dart`, DI) own `getIt` and data impl wiring. `tool/check_feature_modularity_leaks.sh` now fails on domain re-exports of `data/`.
- **DI Organization**: Split `injector_registrations.dart` into feature-specific registration files (`register_chat_services.dart`, `register_profile_services.dart`, etc.) to improve SRP and maintainability.
- **Repository Factory Pattern**: Created generic `createRemoteRepositoryOrNull<T>()` helper to consolidate duplicate error handling in repository factories.
- **Typography Consolidation**: Created `AppTypography` helper class for consistent typography using theme as single source of truth.
- **Input Decoration**: Additional widgets refactored to use shared `buildCommonInputDecoration` helper.
- **ViewStatus Branching**: Additional pages refactored to use `ViewStatusSwitcher` for consistent status handling.

## 📚 Related References

- [UI/UX Guidelines](ui_ux_responsive_review.md)
- [Code Quality](CODE_QUALITY.md)
- [Validation Scripts](validation_scripts.md)
