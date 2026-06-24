---
name: agents-validation-testing
description: >-
  Validation scripts, regression guards, and testing requirements for this repo.
  After non-trivial bug fix, use with agents-regression-capture. Use when
  running checks, adding regression tests, or touching Mix/lifecycle/offline-first.
---

# Validation and testing

## When to use

Running checks, regression tests, Mix/lifecycle/offline-first touches. After a
non-trivial bug fix, run `agents-regression-capture` first (same turn).

## Pointers

Pre-flight: `docs/ai/ai_failure_risks.md` (Minimum proof by task; `RISK-VALIDATION-SHORTCUT`).
Chooser: `docs/agents_quick_reference.md` § Validation Chooser. Routing: `docs/engineering/validation_routing_fast_vs_full.md`. Catalog: `docs/validation_scripts.md` (**C** = in `./bin/checklist`).

## Do not duplicate

- Command table → quick reference § Validation Chooser only
- Regression anchors, lifecycle lists, goldens/coverage → [`docs/testing_overview.md`](../../../../../docs/testing_overview.md)

## Repo-specific (short)

- **Mix:** `app_styles.dart` / `mix_app_theme.dart` → `./tool/run_mix_lint.sh`; tests → `pumpWithMixTheme` (`test/helpers/pump_with_mix_theme.dart`).
- **Guards:** register in `tool/check_regression_guards.sh`; area scripts in validation catalog.
