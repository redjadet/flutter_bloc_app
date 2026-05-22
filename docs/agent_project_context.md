# Agent Project Context

Machine-readable index for project-specific, version-specific facts. Use this
before generic Flutter/Dart memory when task touches architecture, packages,
platform behavior, migrations, performance, or validation.

## Context Rule

Modern models know generic Flutter patterns. This repo's valuable context is:
current constraints, pinned versions, local helpers, package caveats, migration
contracts, known regressions, performance seams, and forbidden patterns.

Also: avoid AI “almost-correct” trap loops; see [`agent_knowledge_base.md#ai-productivity-traps-and-how-this-repo-avoids-them`](agent_knowledge_base.md#ai-productivity-traps-and-how-this-repo-avoids-them).

Ask: "What repo fact would not be in model training data?" Then open
owning source below.

Official Flutter/Dart skills can help with generic mechanics, but this file
adds repo-specific constraints on top. Use narrowest skill for task,
then apply this repo's architecture, package, migration, and validation rules.

## High-Value Sources

| Need | Source of truth |
| --- | --- |
| Toolchain / entrypoints | [`tech_stack.md`](tech_stack.md), [`architecture_details.md`](architecture_details.md) |
| Architecture boundaries | [`clean_architecture.md`](clean_architecture.md), [`CODE_QUALITY.md`](CODE_QUALITY.md) |
| DI / routing / app startup | [`architecture_details.md`](architecture_details.md), [`app_initialization_and_feature_control.md`](app_initialization_and_feature_control.md) |
| UI/design tokens | [`../DESIGN.md`](../DESIGN.md), [`design_system.md`](design_system.md), [`mix_design_system_plan.md`](mix_design_system_plan.md) |
| Validation lanes | [`validation_scripts.md`](validation_scripts.md), [`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md) |
| Testing strategy | [`testing_overview.md`](testing_overview.md), [`ai_code_review_protocol.md`](ai_code_review_protocol.md) |
| Official skill setup | [`agent_environment_setup.md`](agent_environment_setup.md) |
| Runtime reliability/perf | [`reliability_error_handling_performance.md`](reliability_error_handling_performance.md), [`performance_bottlenecks.md`](performance_bottlenecks.md) |
| Offline-first / sync | [`offline_first/adoption_guide.md`](offline_first/adoption_guide.md), [`offline_first/hive_schema_migrations.md`](offline_first/hive_schema_migrations.md) |
| Supabase migrations | [`offline_first/supabase_migrations.md`](offline_first/supabase_migrations.md), [`../supabase/README.md`](../supabase/README.md) |
| Security / secrets | [`SECURITY.md`](SECURITY.md), [`security_and_secrets.md`](security_and_secrets.md) |
| Known caveats / audits | [`audits/README.md`](audits/README.md), [`changes/README.md`](changes/README.md), [`plans/README.md`](plans/README.md) |

## Feature Constraint Packet

Before feature or cross-platform work, identify only the constraints that can
change the implementation: toolchain, allowed existing packages, architecture
boundary, state owner, platform targets, security/env config, offline/sync
behavior, testing lane, CI/deploy impact, and performance limit. Use the source
table above; do not invent a generic checklist when a repo doc or script owns
the answer.

## Current Caveat Shortlist

- Flutter 3.44.0 / Dart 3.12.0 pinned; version-sensitive APIs need official or
  repo-pinned docs before edits.
- Domain layer stays pure Dart; no `package:flutter` imports.
- Shared state lives in Cubit/BLoC; use existing type-safe access/selectors
  before new state patterns.
- GoRouter, DI, l10n, codegen, and route gates are coupled surfaces; update and
  validate together when touched.
- Widget tests: [`testing_overview.md`](testing_overview.md) § Feature-defined
  testing; layout-sensitive sizing per [`testing/widget_test_playbook.md`](testing/widget_test_playbook.md)
  (not repo-wide `WidgetTester.view` until a harness exists). Never deprecated
  `tester.binding.window`.
- Mix/style changes use runtime source first (`AppTheme`, `buildAppMixScope`,
  `AppStyles`, `UI`) and `./tool/run_mix_lint.sh`; local `mix_lint` is pinned
  under `custom_lints/mix_lint` for analyzer 8 / custom_lint 0.8 compatibility.
- UI work should start from real workflow/demo surface, not marketing
  landing page. Check responsive stability, complete states, and no
  text/control overlap at mobile/tablet/desktop widths.
- Hive stored-shape changes are manifest-driven; runtime `getBox()` can run
  `ensureSchema`, but schema changes still require spec, fingerprint,
  migrator, and tests.
- Supabase schema changes: check `list_migrations`, then apply/document repo
  migrations; don't assume remote state from local files alone.
- `firebase_ui_auth` has documented long-display-name overflow caveat; see
  [`firebase_ui_auth_overflow_fix.md`](firebase_ui_auth_overflow_fix.md).
- Feature-scoped DI via `get_it_modular` is not in use; current `get_it` setup
  is global unless compatibility and lifecycle need justify change.
- Interview portfolio spine and proof commands: [`interview_showcase.md`](interview_showcase.md),
  scope in [`adr/0005-interview-showcase-scope.md`](adr/0005-interview-showcase-scope.md).
- Mixpanel, Sentry, and Patrol are **not** in `pubspec.yaml`; doc-only seams in
  [`observability.md`](observability.md) and [`plans/future_observability.md`](plans/future_observability.md).
- `tasks/*` trackers are gitignored (local-only); durable conclusions belong in
  `docs/`, not committed tracker paths.

## Avoid

- Restating broad Flutter best practices when repo doc already owns rule.
- Adding package/dependency advice without checking `pubspec.lock`, owning docs,
  and current package APIs.
- Hiding project caveats in chat, tracker-only notes, or host-only prompts.
- Expanding root [`AGENTS.md`](../AGENTS.md) into handbook; link this index instead.
