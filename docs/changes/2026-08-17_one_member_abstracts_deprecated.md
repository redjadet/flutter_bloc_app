# Dart 3.13: drop deprecated `one_member_abstracts` config key

Dart 3.13 marks `one_member_abstracts` deprecated. Listing the rule in
`linter.rules` (including `one_member_abstracts: false`) raised
`deprecated_lint` on `analysis_options.yaml`.

## Why

Single-method abstract ports stay on purpose (ISP/DIP for GetIt and test
doubles). We do not collapse them to top-level functions.

## What

Removed the `linter.rules` key. VGA 10.3.0 still enables the lint, so
`analyzer.errors.one_member_abstracts: ignore` keeps `./tool/analyze.sh` clean
without re-listing the deprecated rule.

## Verification

- `./tool/analyze.sh`
