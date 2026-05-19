---
name: agents-modularity
description: Dependency direction and feature composition. Use for shared/core changes, cross-feature deps, auth/theme contracts.
---

# Modularity

Narrative: `docs/modularity.md`. Paths: `agents-references`.

## Rules

1. **`lib/shared/` never imports `lib/features/`.** Shared concepts live in `shared/` or `core/`; features import down.
2. **No feature → feature** domain/presentation imports. Compose in **app layer** (router, scope, params).
3. **Core/shared contracts** for cross-cutting concepts (auth user, tokens); app/router depend on contract only.
4. **Capabilities, not concrete classes:** reusable widgets/services receive narrow callbacks, domain/core ports, or tiny interfaces instead of full cubits/repositories/view models.
5. **No vague buckets:** avoid new `Utils`, `Helper`, `Manager`, `Base*`; name behavior and owner.

## Checks

- `grep -r "import.*features/" lib/shared` → empty
- Route/DI changes → `./bin/router_feature_validate`

**Touchpoints:** `lib/core/auth/*`, `lib/shared/design_system/epoch_theme_extension.dart`, `lib/features/features.dart` (barrel for app/tests only).
