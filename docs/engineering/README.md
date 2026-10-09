# Engineering documentation

Operational quality, delivery controls, and technical maintenance. Start with
[engineering decisions](../engineering-decisions.md) for cross-cutting context.

| Need | Read |
| --- | --- |
| BuildContext scope and lifetime | [build_context_deep_dive.md](build_context_deep_dive.md) |
| Critical human engineering skills | [critical_human_skills.md](critical_human_skills.md) — judgment, restraint, architecture/intent/edge-cases triad, stakes spectrum (vibe → agentic), least surface when agents make typing cheap |
| Widget/state fundamentals + production stories | [flutter_fundamentals_and_production_practices.md](flutter_fundamentals_and_production_practices.md) — Stateless/Stateful, widget tree, Element identity (`canUpdate` / keys), setState vs Cubit/BLoC, Cubit-first async load/refresh/stale guards, hot reload/restart; offline, perf, team structure, unreproducible crashes with repo evidence |
| Widget composition / rebuild boundaries | [widget_composition_and_rebuild_boundaries.md](widget_composition_and_rebuild_boundaries.md) — intentional widgets vs file splits; widgets over `_build*` helpers; split by change locality; cross-links to fundamentals keys/`canUpdate` + design-system leaf contract |
| Focus / keyboard input | [focus_and_keyboard_input.md](focus_and_keyboard_input.md) — focus tree vs hit-test; `FocusNode` / scope / `FocusManager`; TextInput vs focus; Shortcuts/Actions; Todo Next + dispose anchors |
| Dart records / patterns | [dart_records_and_patterns.md](dart_records_and_patterns.md) — multi-return records, switch expressions, Freezed vs records; when not to mass-refactor |
| Validation lane | [validation_routing_fast_vs_full.md](validation_routing_fast_vs_full.md) — full `./bin/checklist` keeps analyze + tests; agent closeout: [pre-complete gate](../agent_kb/legibility_and_finish_gate.md#agent-pre-complete-gate-mandatory-before-done) |
| Engineering proof | [engineering_quality_scorecard.md](engineering_quality_scorecard.md) |
| Lint posture | [linter_rules_review.md](linter_rules_review.md) |
| Custom lint authoring | [custom_lint_rules_guide.md](custom_lint_rules_guide.md) |
| Code generation | [code_generation_guide.md](code_generation_guide.md) |
| Platform workarounds | [workarounds.md](workarounds.md) |
| Logging / localization | [logging.md](logging.md), [localization.md](localization.md) |
| CI automation | [ci_automation.md](ci_automation.md) |
| Dependency updates | [DEPENDENCY_UPDATES.md](DEPENDENCY_UPDATES.md) |
| Shared utilities | [SHARED_UTILITIES.md](SHARED_UTILITIES.md) |
| Cancellation and cache (reviewer) | [cancellation_and_cache.md](cancellation_and_cache.md) — Cubit close, RequestIdGuard, CancelToken, Hive vs HTTP vs image cache |
| Anti-patterns | [flutter-anti-patterns.md](flutter-anti-patterns.md) |
| Integration testing | [integration_test_policy.md](integration_test_policy.md) |
| Play Store release SOP | [android_play_store_release_sop.md](android_play_store_release_sop.md) |
| Delayed or background work | [delayed_work_guide.md](delayed_work_guide.md) |

Put focused operations, quality controls, and maintenance guidance here. Keep
repository-wide entry hubs at `docs/` root.
