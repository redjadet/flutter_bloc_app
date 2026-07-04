# Melos monorepo migration — PR-E wave 2c closeout

Date: 2026-07-03  
Branch: `codex/melos-monorepo-build` · PR [#437](https://github.com/redjadet/flutter_bloc_app/pull/437)

## Summary

Continued `packages/design_system` extraction (PR-E wave 2c). Moved package-safe
widgets and helpers; kept l10n- and routing-coupled widgets in the app.

## Moved to `packages/design_system`

- `common_max_width.dart`
- `common_input_decoration_helpers.dart`
- `common_form_field.dart` (`CommonFormField` only)
- `skeleton_card.dart`, `skeleton_list_tile.dart`, `skeleton_grid_item.dart`

## Stayed in app (deferred)

- `CommonSearchField` — default `context.l10n.searchHint` (`common_search_field.dart`)
- `common_error_view`, `common_empty_state`, `common_loading_widget`, `common_dropdown_field`
- `common_app_bar`, `common_page_layout` — GoRouter / l10n

App compatibility barrels remain at prior `apps/mobile/lib/shared/widgets/**` paths.

## Docs

- [`agent_environment_setup.md`](../agent_environment_setup.md) — Melos bootstrap section
- [`engineering/validation_routing_fast_vs_full.md`](../engineering/validation_routing_fast_vs_full.md) — workspace validation routing
- [`feature_implementation_guide.md`](../feature_implementation_guide.md) — `apps/mobile/lib/features` note
- [`clean_architecture.md`](../clean_architecture.md) — package dependency table

## Proof

- `flutter test` canaries: `common_form_field_test`, `skeletons_test`, `common_card_test`
- `./bin/checklist` from repo root

## Next

- PR-E (full) after deferred widgets decouple or plan accepts deferral
- PR-F: `packages/networking`, `packages/storage`
