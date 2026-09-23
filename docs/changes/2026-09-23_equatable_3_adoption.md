# 2026-09-23 — Equatable 3.0 adoption

## Summary

Workspace uses **equatable 3.0.0** (path override) with app/utilities
constraints `^3.0.0`. Call sites adapted for 3.0 `toString` behavior.

## Why a path override

Hosted equatable 3.0 removes `EquatableMixin`. Transitive packages still need it:

- `fl_chart` 1.2.0 ([PR #2120](https://github.com/imaNNeo/fl_chart/pull/2120) pending)
- `firebase_auth_mocks` 0.15.x

Shim: [`third_party/pub/equatable`](../../third_party/pub/equatable) —
Equatable 3.0.0 + deprecated `typedef EquatableMixin = Equatable`.

Living owner + exit checklist:
[`engineering/workarounds.md`](../engineering/workarounds.md) §5 and
[`engineering/DEPENDENCY_UPDATES.md`](../engineering/DEPENDENCY_UPDATES.md)
(unresolvable majors table).

## Follow-up (do not forget)

**Watch** `fl_chart` and `firebase_auth_mocks` releases for Equatable-3 /
no-`EquatableMixin` builds. **When safe**, remove
`third_party/pub/equatable`, point root override (or direct deps) at hosted
`equatable: ^3.0.0`, re-run `dart pub get` + checklist / charts IT, mark
workarounds §5 Resolved.

## Code updates

- `SealedStateMatcher` matches on `runtimeType` name (not `toString()`), so
  classification works when stringify is off (`Instance of '…'`).
- Regression tests for case-study Equatable equality + stringify-off matcher.

## Verification

- Unit: sealed helpers + case_study equatable equality + related cubit tests
- Integration: `smoke_flows_test.dart` + `charts_flow_test.dart` (fl_chart surface)
- Full: `all_flows_test.dart` (selective map forces full for pubspec/`third_party`)
