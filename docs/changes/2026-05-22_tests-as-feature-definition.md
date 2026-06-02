# Tests as feature definition (docs)

**Date:** 2026-05-22
**Scope:** Documentation and delivery workflow only. No CI gates, no Dart harness.

## Summary

Adopted the practice that **tests define done** for feature work—not optional cleanup before merge. Tests guard **behaviour contracts** during refactors; compile checks remain `dart analyze` and existing coverage gates.

## What changed

| Doc | Change |
| --- | --- |
| [`plans/FEATURE_TEMPLATE.md`](../plans/FEATURE_TEMPLATE.md) | **Tests** block is an executable contract (behaviour, state, unit, integration, proof command) |
| [`testing_overview.md`](../testing_overview.md) | New § Feature-defined testing (pyramid guidance, P0–P2, non-goals, integration cap) |
| [`testing/widget_test_playbook.md`](../testing/widget_test_playbook.md) | **New** — BLoC widget test how-to |
| [`testing/testing_strategy.md`](../testing/testing_strategy.md) | Brief Tests = done; layout-sensitive viewport wording; link to overview § |
| [`feature_implementation_guide.md`](../feature_implementation_guide.md) | Delivery order: brief → RED tests → implement → prove |
| [`contributing.md`](../contributing.md) | PR bar: regression tests or documented Tests N/A |
| [`README.md`](../README.md) | Playbook link under Workflow and quality |
| [`ai_code_review_protocol.md`](../ai_code_review_protocol.md) | Review maps brief test rows → `test/` paths |
| [`agent_kb/legibility_and_finish_gate.md`](../agent_kb/legibility_and_finish_gate.md) | FEATURE_TEMPLATE Tests before broad impl |
| [`AGENTS.md`](../../AGENTS.md) | Must Keep widget-test pointer → overview § + playbook (replaces blanket `WidgetTester.view`) |
| [`agent_project_context.md`](../agent_project_context.md) | Same viewport guidance as AGENTS |
| [`changes/README.md`](README.md) | Index entry for this note |
| [`plans/README.md`](../plans/README.md) | FEATURE_TEMPLATE index blurb |
| [`agents_quick_reference.md`](../agents_quick_reference.md) | Validation chooser row for feature **Tests** contract |
| Host templates | Codex host sync now copies repo [`AGENTS.md`](../../AGENTS.md); Cursor [`agents-global.mdc`](../../tool/agent_host_templates/cursor/rules/agents-global.mdc), quick-reference skill — aligned with repo [`AGENTS.md`](../../AGENTS.md) |

## Guidance split (not quotas)

~60% unit/cubit · ~30% widget · ~10% integration — priority guidance only.

## Out of scope (backlog)

- CI parser for empty Tests section
- Shared `test/widget_harness.dart`
- Repo-wide `WidgetTester.view` harness
- Auth login-page widget backfill beyond existing register/logged_out tests

## For agents

1. Start from [`FEATURE_TEMPLATE.md`](../plans/FEATURE_TEMPLATE.md) for non-trivial `lib/features/` work.
2. RED tests in the **same change series** as implementation.
3. Widget patterns: [`testing/widget_test_playbook.md`](../testing/widget_test_playbook.md).
