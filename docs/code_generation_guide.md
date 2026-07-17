# Code generation — current contract

## Freezed / json_serializable / Retrofit

Primary codegen path for models, states, and Retrofit APIs:

```bash
cd apps/mobile && dart run build_runner build --delete-conflicting-outputs
```

Prefer Freezed for immutable domain/presentation models. See
[`freezed_usage_analysis.md`](freezed_usage_analysis.md) and
[`compile_time_safety.md`](compile_time_safety.md).

## Sealed-switch helper (optional)

Script: `tool/generate_sealed_switch.dart`

```bash
dart run tool/generate_sealed_switch.dart <path-to-sealed-state.dart>
```

Use only when a sealed hierarchy needs generated `when`-style helpers and
Freezed `when`/`map` is not already in play.

## Guards

- `tool/check_freezed_preferred.sh` — prefer Freezed over Equatable for new
  models
- Feature briefs / tests: [`plans/FEATURE_TEMPLATE.md`](plans/FEATURE_TEMPLATE.md)

## Related

- [`bloc_standards.md`](bloc_standards.md)
- [`architecture/use_case_dto_policy.md`](architecture/use_case_dto_policy.md)
