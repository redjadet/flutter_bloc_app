# Melos / multi-package split feasibility (2026-05-12)

## Recommendation

**Stay single-package** for this app until a concrete second consumer (second app or published SDK) appears. Enforce boundaries with scripts (`tool/check_feature_modularity_leaks.sh`, `tool/modular_metrics.sh`) and composition discipline in `apps/mobile/lib/app/` instead.

## Candidate package map (if splitting later)

| Package | Contents | Notes |
| ------- | -------- | ----- |
| `app_core` | `apps/mobile/lib/core/`, `apps/mobile/lib/shared/` | Shared infra, ports, design system utilities |
| `app_features_*` | Selected stable features (`counter`, `todo_list`, `settings`, `auth`) | One package per feature or grouped “product” slice |
| `app` | `apps/mobile/lib/app/`, `main*.dart`, routers, l10n entry, integration | Composes packages; owns `pubspec` assets |

Demos (`*_demo`) stay in `app` or a separate `app_demos` package to avoid blocking core releases.

## Costs

- **Codegen:** `build_runner`, Freezed, Retrofit per-package `build.yaml`, path imports vs `package:` hygiene.
- **l10n:** `flutter gen-l10n` single arb source vs duplicated synthetic packages.
- **DI:** composition root imports many packages; circular dependency risk if features reference each other.
- **CI:** matrix build order, `melos bootstrap`, stricter version solving.
- **IDE:** jump-to-definition across package boundaries; slower analysis on cold open.

## Benefits

- Hard compile-time forbidden edges (stronger than bash `rg` gates).
- Reuse `app_core` in another Flutter app or headless tool.
- Smaller blast radius for publishes (e.g. internal plugin).

## Trigger conditions (revisit decision)

- Second production app needs the same `core` + `shared` stack, **or**
- Feature count / churn makes script-based enforcement noisier than package graph errors, **or**
- Team commits to dedicated platform/SDK release cadence.

## Validation if migrating

- `melos bootstrap` + `melos run analyze` + existing `./bin/checklist`.
- Prove one feature package builds in isolation (no app imports) before moving a second.
