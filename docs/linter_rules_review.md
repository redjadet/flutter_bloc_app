# Linter Rules Review

This document summarizes the project's static analysis setup and how it aligns with
best practices for AI-assisted Flutter development.

## Current Setup (Summary)

| Layer | Source | Role |
| ----- | ------ | ---- |
| **Baseline** | `package:very_good_analysis/analysis_options.yaml` | VGV rule set (strict, Flutter-oriented) |
| **Language** | `analyzer.language` | `strict-casts`, `strict-inference`, `strict-raw-types` |
| **Severity overrides** | `analyzer.errors` | Key rules promoted to error (e.g. `use_build_context_synchronously`, `prefer_const_constructors`) |
| **Custom preferences** | `linter.rules` | Project overrides (e.g. `lines_longer_than_80_chars: false`, `use_decorated_box: true`) |
| **Plugin** | `file_length_lint` | `file_too_long` at error; max **225** lines (`file_length_lint.max_lines`); default excludes generated/tests/tools; extra `integration_test/**` exclude |
| **Plugin** | `mix_lint` | Mix design-system rules (see `analysis_options.yaml` `plugins.mix_lint.diagnostics`) |

## Strengths

- **Very Good Analysis 10.2.0** is a strong baseline: includes
  `use_build_context_synchronously`, `use_colored_box`,
  `avoid_unnecessary_containers`, `cancel_subscriptions`,
  `no_logic_in_create_state`, `discarded_futures`, `unawaited_futures`,
  `avoid_void_async`, exhaustive cases, and many style/quality rules.
- **Strict analyzer options** improve type safety and catch more bugs at compile time.
- **AI-agent bug guards** promote high-signal diagnostics to errors:
  `unawaited_futures`, `discarded_futures`, `avoid_void_async`,
  `await_only_futures`, `use_build_context_synchronously`,
  `avoid_catches_without_on_clauses`, `avoid_catching_errors`,
  `only_throw_errors`, `document_ignores`, `unnecessary_ignore`, and
  `unnecessary_statements`.
- **Custom overrides** are documented and intentional (e.g.
  `type_annotate_public_apis: true`, `omit_local_variable_types: false`,
  `use_decorated_box: true`).
- **Test config** (`test/analysis_options.yaml`) relaxes only what is needed for
  tests (const, return types, package imports) and uses
  `package:flutter_lints/flutter.yaml`.

## Recommendations

1. **Keep VGV current** - `very_good_analysis` is already at 10.2.0; continue
   upgrading with Dart/Flutter SDK changes so new stable lints are inherited.
2. **Prefer severity overrides over new lint packages** - this repo already has
   VGV, Flutter lints in test/custom packages, and local analyzer plugins.
   Additional broad lint packages would add overlap and noise.
3. **Keep async/error rules strict** - AI agents commonly miss `await`, broad
   `catch`, and `BuildContext` lifetime constraints. These rules should stay
   errors unless a concrete false positive is found.
4. **Keep ignore comments auditable** - `document_ignores` and
   `unnecessary_ignore` should stay errors so generated fixes cannot hide stale
   suppressions.
5. **Line length remains style-only** - `lines_longer_than_80_chars: false`
   keeps generated/API-heavy Flutter code from noisy failures; formatting still
   uses repo `./bin/format`.

## References

- [Very Good Analysis](https://pub.dev/packages/very_good_analysis)
- [Dart Linter Rules](https://dart.dev/tools/linter-rules)
- [Dart Analysis Options](https://dart.dev/tools/analysis)
- [Flutter Lints](https://pub.dev/packages/flutter_lints)
- [Custom Lint Rules Guide](custom_lint_rules_guide.md) (this repo)
