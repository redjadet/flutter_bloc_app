# Use Case And DTO Policy

Deterministic policy for agents deciding whether to add use cases, DTOs, and
mappers.

## Use Cases

This repo does not require a use-case class for every repository method.

| Situation | Policy |
| --- | --- |
| Simple CRUD/read command with one repository call | Cubit may call domain repository directly |
| Business workflow spans multiple repositories/services | Add a domain use case or narrow domain service |
| Retry, validation, authorization, or merge policy must be reused | Add use case/domain service |
| Workflow is presentation-only, such as sorting visible tabs | Keep in Cubit or presentation helper |
| Data concern, such as DTO parsing, HTTP status mapping, cache merge | Keep in data repository/service |

Use cases live under `apps/mobile/lib/features/<feature>/domain/use_cases/` only when they
remove orchestration from Cubit without pulling data concerns into domain.

## Repository Contracts

- Contracts live in `domain/` and speak domain language.
- Methods return domain models, value objects, or typed domain failures.
- Contracts do not expose DTOs, SDK clients, Hive boxes, Dio responses,
  Firebase snapshots, Supabase rows, or GoRouter locations.
- Watch/stream APIs should document initial emission and error behavior in tests.

## DTOs And Mappers

| Type | Location | Direction |
| --- | --- | --- |
| Local/remote DTO | `data/` | external/storage shape |
| DTO mapper | `data/` | DTO <-> domain |
| Domain model | `domain/` | app business shape |
| View data mapper | `presentation/mappers/` or `core/diagnostics` | state/domain -> UI data |

DTOs are required when external or stored shape can drift independently from
domain shape. DTOs are optional for tiny internal-only maps where a mapper would
add churn without type safety.

## Error Mapping

- HTTP/transport failures map in data/shared utilities.
- Domain failures expose stable, testable semantics.
- Cubit maps domain failure to visible state.
- UI maps visible state to localized copy, retry controls, and diagnostics.

## Forbidden

- DTO in Cubit state.
- SDK exception type in domain contract.
- Use case importing Flutter, Hive, Dio, Firebase, Supabase client, or router.
- Mapper hidden in widget `build()`.
- Repository returning raw `Map<String, dynamic>` when shape is stable enough for
  domain or DTO type.

## Validation

Use focused mapper/repository tests for DTO and error mapping. Run
`./tool/analyze.sh` plus path-specific validation; escalate per
[Validation Routing](../engineering/validation_routing_fast_vs_full.md).
