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

Left generated `@freezed` types and Cubit/BLoC state alone. Ordinary function
`final` params stay forbidden; `final` on primary-constructor parameters is
allowed (`avoid_final_parameters` does not apply there).

## Verification

- `./bin/format --changed`
- `./tool/analyze.sh` (no issues)
- Focused DTO/domain/repository tests (93 passed), including GraphQL/todo/chat
  DTO, case-study codec, BLE snapshots, staff punch flags, search cache,
  market snapshot, therapy booking cubit
