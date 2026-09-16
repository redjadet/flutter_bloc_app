# Quiet `./bin/format` soft-skip noise

`dart format` printed many `Could not format` errors for `tool/fixtures/**`
(and vendored `third_party/**`) then a soft-skip warning. That was noisy even
when exit status was 0.

## Change

1. `bin/format` **omits** `tool/fixtures/**` and `third_party/**` from the
   `dart format` invocation (no stderr spam, no warning).
2. Strip illegal parameter modifiers (`final`/`var` on params) from guard
   fixtures so they parse on Dart 3.13+ / current dart_style.
3. Add `tool/bloc_codegen/analysis_options.yaml` so format no longer warns about
   unresolved `package:very_good_analysis` include from the workspace options.

## Verification

```bash
./bin/format --self-test
./bin/format   # no "Could not format" / soft-skip warning
bash tool/run_harness_fixtures.sh
```
