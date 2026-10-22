# Feature: BuildContext guidance gaps and MediaQuery aspect lookups

**Date:** 2026-10-22

## Problem

An audit against the Flutter "BuildContext under the hood" material found no
BuildContext lifecycle bugs: `use_build_context_synchronously` is an error, no
ignores exist, and the context guard scripts pass. The living guide
[`engineering/build_context_deep_dive.md`](../engineering/build_context_deep_dive.md)
still missed several rules reviewers rely on, and three keyboard-aware sheets
used `MediaQuery.of(context).viewInsets` where an aspect lookup fits.

## Scope

- In: deep-dive doc sections (non-listening lookups, read/watch/select
  placement, modal `BlocProvider.value`, root-navigator dialogs,
  `ScaffoldMessenger`/`Overlay`, MediaQuery aspects, `State.mounted` vs
  `context.mounted`, lifecycle, lint blind spots); three
  `MediaQuery.viewInsetsOf` call sites.
- Out: Cubits, repositories, routes, l10n, new lint or guard scripts.

## Layers touched

- [ ] domain
- [ ] data
- [x] presentation
- [ ] DI
- [ ] routes / l10n

## Contracts

- Sheet layout: bottom margin still equals the keyboard inset.
- Rebuilds: sheets now depend only on `viewInsets`, not on every
  `MediaQueryData` field.

## Behavior contract (define before implementation)

- Must remain true: the todo date picker sheet, the shared Cupertino picker
  sheet, and the design-system picker sheet keep their bottom margin equal to
  `MediaQuery.viewInsetsOf(context).bottom`. Owner: those three widgets.
- Inputs: keyboard shown/hidden; other MediaQuery changes no longer rebuild
  the sheet on their own.
- Failure/recovery: none; same value from the same inherited `MediaQuery`.
- Source of expected results: Flutter `MediaQuery` API docs.

## What changed

Presentation:

- `apps/mobile/lib/features/todo_list/presentation/widgets/todo_list_date_picker_dialog.part.dart`
- `apps/mobile/lib/app/utils/platform_adaptive_sheets.part.dart`
- `packages/design_system/lib/src/platform_adaptive/platform_adaptive_impl.part.dart`

Docs:

- [`engineering/build_context_deep_dive.md`](../engineering/build_context_deep_dive.md) — lookup table, Provider/BLoC
  placement, mounted/lint gaps, lifecycle, overlays/routes/MediaQuery, sources.

## Tests (executable contract)

Tests: N/A — value-equivalent lookup swap; no new scenario. Existing suites
covering these sheets stay the contract:

- `apps/mobile/test/` todo list and platform adaptive sheet/dialog tests
- `packages/design_system/test/` platform adaptive tests

### Proof command

- `./bin/checklist`

## Docs

- [x] This note, indexed from [`docs/changes/README.md`](README.md)
- [x] Living practice in
  [`engineering/build_context_deep_dive.md`](../engineering/build_context_deep_dive.md)
- [ ] [`feature_overview.md`](../feature_overview.md) — unchanged

## Risks

None expected. `viewInsetsOf` reads the same `MediaQueryData.viewInsets`.

## depends_on

- None.

## blocks

- None.

## merge_order

- Single PR.

## rollback

- Revert the commit.

## proof_commands

```bash
bash tool/check_feature_brief_linked.sh --base origin/main
bash tool/check_docs_gardening.sh --paths docs/changes/2026-10-22_buildcontext_guidance.md docs/changes/README.md docs/engineering/build_context_deep_dive.md
```
