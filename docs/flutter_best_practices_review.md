# ✅ Flutter + Mobile Best Practices Review

**Scope:** app bootstrap, routing, shared utilities, and representative features (counter, settings, auth, profile, chat). This is a focused engineering review, not an exhaustive audit.

## 🔍 What Was Reviewed

- App bootstrap and DI wiring (`lib/core/`, `lib/app/`)
- Navigation and route setup (`lib/app/router/`)
- Shared UI utilities and responsive helpers (`lib/shared/`)
- Representative features (`lib/features/counter/`, `lib/features/settings/`, `lib/features/chat/`)

## 💪 Strengths Observed

- Clear domain/data/presentation boundaries across features.
- Offline-first repositories use consistent queueing and sync helpers.
- UI layout uses responsive extensions and adaptive components.
- Async safety patterns are applied (mounted checks, guarded emits).
- Custom lint rules and validation scripts help enforce architecture rules.

## ⚠️ Risks and Follow-Ups

- `AppScope.build` triggers DI configuration and sync startup. Side effects in `build()` can repeat during rebuilds or hot reload. Consider moving to `initState` or making the calls explicitly idempotent. See `lib/app/app_scope.dart`.
- ~~Typography customization appears in a few widgets. If the theme is the single source of truth, consider moving ad-hoc font usage into `lib/core/app_config.dart` to avoid drift.~~ **RESOLVED**: Created `AppTypography` helper class in `lib/shared/ui/typography.dart` that uses theme as single source of truth.
- A small number of presentation widgets call into concrete repos for diagnostics. This is acceptable for tooling, but keep it contained to avoid architecture drift.

## ✅ Recent Improvements

- **DI Organization**: Split `injector_registrations.dart` into feature-specific registration files (`register_chat_services.dart`, `register_profile_services.dart`, etc.) to improve SRP and maintainability.
- **Repository Factory Pattern**: Created generic `createRemoteRepositoryOrNull<T>()` helper to consolidate duplicate error handling in repository factories.
- **Typography Consolidation**: Created `AppTypography` helper class for consistent typography using theme as single source of truth.
- **Input Decoration**: Additional widgets refactored to use shared `buildCommonInputDecoration` helper.
- **ViewStatus Branching**: Additional pages refactored to use `ViewStatusSwitcher` for consistent status handling.

## 📚 Related References

- [UI/UX Guidelines](ui_ux_responsive_review.md)
- [Code Quality](CODE_QUALITY.md)
- [Validation Scripts](validation_scripts.md)
