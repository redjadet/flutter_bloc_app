# Change: Adopt very_good_analysis 11

Date: 2026-09-06

## Problem

Weekly Drift `upgrade_validate_all` bumps `very_good_analysis` to ^11.0.0 and
fails `flutter analyze` on ~1.3k new infos (`unnecessary_type_name_in_constructor`,
`async_return_with_no_await`).

## Scope

- **In:** Pin/upgrade `very_good_analysis` to ^11.0.0; apply Dart primary-constructor
  renames (`new` / unnamed factories) and async-return fixes across app feature code;
  keep small-payload `jsonEncode` ignores valid for checklist; docs/tech_stack note.
- **Out:** Behavior changes, API redesign, Freezed regeneration beyond lint-driven edits.

## Layers touched

- [x] presentation / domain / data (mechanical lint fixes)
- [x] pubspec + analysis docs
- [ ] DI / routes (unchanged behavior)

## Contracts

No product contract changes. Analyzer package bump only.

## Validation

- `flutter analyze` (apps/mobile) — no issues with VGA 11
- `tool/check_raw_json_decode.sh`
- `./bin/checklist` / CI build on this PR
