# Code generation — current contract

## Freezed / json_serializable / Retrofit

Run from the repository root. The subshell keeps the cleanup command at
the root after app generation:

```bash
(cd apps/mobile && dart run build_runner build --delete-conflicting-outputs) &&
  bash tool/strip_freezed_dart_313_params.sh
```

For changes spanning workspace packages with `build_runner`, use the root
Melos script instead, then run the same cleanup:

```bash
dart run melos run build_runner && bash tool/strip_freezed_dart_313_params.sh
```

Dart 3.13 language forbids `final` on ordinary constructor parameters.
Current Freezed still emits `final` on hidden-field constructors and similar
parameters, so re-run `tool/strip_freezed_dart_313_params.sh` after codegen
until Freezed is 3.13-safe. The strip keeps field `final` and locals such as
`final _that = this;` and `final value = ...`.

Prefer Freezed for immutable domain/presentation models. See
[`freezed_usage_analysis.md`](../architecture/freezed_usage_analysis.md) and
[`compile_time_safety.md`](../architecture/compile_time_safety.md).

## Sealed-switch helper (optional)

Script: `tool/generate_sealed_switch.dart`

```bash
dart run tool/generate_sealed_switch.dart "<path-to-sealed-state.dart>"
```

Use only when a sealed hierarchy needs generated `when`-style helpers and
Freezed `when`/`map` is not already in play.

## Guards

- `tool/check_freezed_preferred.sh` — prefer Freezed over Equatable for new
  models
- Feature briefs / tests: [`engineering/FEATURE_TEMPLATE.md`](FEATURE_TEMPLATE.md)

## Related

- [`bloc_standards.md`](../bloc_standards.md)
- [`architecture/use_case_dto_policy.md`](../architecture/use_case_dto_policy.md)
