# Linter Rules Review

This document summarizes the project's static analysis setup and how it aligns with best practices.

## Current Setup (Summary)

| Layer | Source | Role |
| ----- | ------ | ---- |
| **Baseline** | `package:very_good_analysis/analysis_options.yaml` | VGV rule set (strict, Flutter-oriented) |
| **Language** | `analyzer.language` | `strict-casts`, `strict-inference`, `strict-raw-types` |
| **Severity overrides** | `analyzer.errors` | Key rules promoted to error (e.g. `use_build_context_synchronously`, `prefer_const_constructors`) |
| **Custom preferences** | `linter.rules` | Project overrides (e.g. `lines_longer_than_80_chars: false`, `use_decorated_box: true`) |
| **Plugin** | `file_length_lint` | Max file length (500 lines), excludes generated |

## Strengths

- **Very Good Analysis** is a strong baseline: includes `use_build_context_synchronously`, `use_colored_box`, `avoid_unnecessary_containers`, `cancel_subscriptions`, `no_logic_in_create_state`, exhaustive cases, and many style/quality rules.
- **Strict analyzer options** improve type safety and catch more bugs at compile time.
- **Custom overrides** are documented and intentional (e.g. `type_annotate_public_apis: true`, `prefer_final_parameters: true`, `use_decorated_box: true`).
- **Test config** (`test/analysis_options.yaml`) relaxes only what’s needed for tests (const, return types, package imports) and uses `package:flutter_lints/flutter.yaml`.

## Recommendations

1. **Package version** – Keep `very_good_analysis` updated (e.g. ^10.0.0 → ^10.2.0 when ready) for latest rules and fixes.
2. **Widget keys** – Consider `use_key_in_widget_constructors: error` so missing keys in list/map widgets are hard errors (currently warning).
3. **Line length** – Documentation recommends "line length ≤80"; the linter has `lines_longer_than_80_chars: false`. Either enable the rule to enforce it or document that the team enforces 80 chars by convention only.
4. **Deprecated rules** – VGV excludes `avoid_null_checks_in_equality_operators` (deprecation planned). If the linter removes it in a future SDK version, drop it from `analyzer.errors` when you upgrade.
5. **Plugin note** – The file-length plugin is documented as "Dart 3.10.7 analyzer plugin"; update the comment if you move to a different analyzer/SDK version.

## References

- [Very Good Analysis](https://pub.dev/packages/very_good_analysis)
- [Dart Linter Rules](https://dart.dev/tools/linter-rules)
- [Custom Lint Rules Guide](custom_lint_rules_guide.md) (this repo)
