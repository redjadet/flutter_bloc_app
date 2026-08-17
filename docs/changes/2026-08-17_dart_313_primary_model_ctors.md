# Dart 3.13 primary constructors on hand-written models

Language floor is already `>=3.13.0`. Hand-written DTO/domain field bags still
duplicated constructor parameters and `final` fields.

## Why

Dart 3.13 primary constructors induce those fields, so bags stay shorter
without changing factories, mappers, or equality.

## What

Converted remaining hand-written data bags (DTOs, Equatable records, BLE/therapy
domain snapshots). Named constructors redirect with `: this(...)`. Defaults use
dot shorthands where the type is obvious (`=.none`, `=.disconnected`).

Follow-up after Codex review of #700: remaining DTO primary constructors that
were still non-`const` (`TodoItemDto`, GraphQL DTOs, AI Decision DTOs) are now
`class const`. Additional leftover field bags
(`RemoteCaseStudySummary`/`Detail`, `MockBleDeviceProfile`, todo list
projections, `SettingsOption`, `TodoEditorResult`, `_SimState`,
`SecureProbeFailure`) use the same shortening.

Left generated `@freezed` types and Cubit/BLoC state alone. Ordinary function
`final` params stay forbidden; `final` on primary-constructor parameters is
allowed (`avoid_final_parameters` does not apply there).

## Verification

- `./bin/format --changed`
- Dart MCP `analyze_files` on converted paths — no errors
- `./tool/analyze.sh` (no issues)
- Focused DTO/domain/widget tests (44 passed): GraphQL/todo/AI Decision DTOs,
  market sim feed, mock BLE catalog, case-study history, secure probe,
  todo editor dialog
