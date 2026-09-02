# Todo measurement-gated performance

## Context

Selection-only state rebuilt Todo list presentation and recomputed filtered
rows. An unmeasured optimization could add state complexity without improving
the real path. The expensive failure is permanent abstraction cost backed only
by a synthetic success.

## Ownership

Own the measurement question, selector boundary, and falsifiable proof. In an
interview, separate personally authored projection/test/profiling work from
operator device evidence and shared performance tooling.

## Options

1. Keep the wide selector.
2. Add generic memoization or a broader performance abstraction.
3. Split lifecycle, list, and selection projections at the observed boundary.

## Decision

Choose option 3 after establishing the wide-selector baseline. Retain the
synthetic selector harness as regression proof, then exercise real Hive data,
navigation, selection, scrolling, and Flutter Timeline collection.

## Rejected approach

Reject the synthetic harness as sufficient performance evidence. It proves
selector equality and rebuild isolation, not production-path storage,
navigation, scrolling, or frame behavior. Reject a generic abstraction before
another measured consumer exists.

## Trade-off

More projection types and equality contracts reduce unrelated rebuilds but add
presentation maintenance. Scope stays on Todo selection/list rendering; it does
not prove app-wide or cross-device performance.

## Proof and outcome

| Evidence status | Boundary |
| --- | --- |
| Implemented behavior | Todo list and selection use separate projections in the current tree. |
| Repository proof | [`todo_list_page_data.dart`](../../../apps/mobile/lib/features/todo_list/presentation/pages/todo_list_page_data.dart), [rebuild-isolation test](../../../apps/mobile/test/features/todo_list/presentation/pages/todo_list_rebuild_isolation_test.dart), and [Hive-backed Timeline journey](../../../apps/mobile/integration_test/perf/todo_list_hive_selection_profile_test.dart) |
| Historical evidence | [Baseline](../../changes/2026-08-10_todo_list_rebuild_baseline.md) and [remeasure](../../changes/2026-08-10_todo_list_rebuild_remeasure.md); rerun before quoting their device metrics as current. |
| Planned / deferred | No app-wide, cross-device, or current device-profile claim. A fresh profile run is required when making a current runtime claim. |
| Contribution | Individual: personally owned selector, harness, or profiling slice. Team/system: operator device session, integration harness, performance budgets, and review. |

## Reflection

Structural isolation and runtime performance answer different questions. The
first guards intent cheaply; the second tests whether real-path work fits the
owned budget.

## New default

Prove a production-path bottleneck before optimizing. Retain both structural
regression proof and measured runtime evidence after the change.

## Revisit trigger

Revisit when Todo state/projections change, list scale or target devices change,
or fresh traces exceed the owned frame budget.
