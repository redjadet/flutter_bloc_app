# ADR 0007: BlocSignal Evaluation (Stay on flutter_bloc)

| Field | Value |
| --- | --- |
| Status | Accepted |
| Date | 2026-09-09 |
| Scope | Presentation state management |
| Source docs | [State Management Choice](../architecture/state_management_choice.md), [BLoC Standards](../bloc_standards.md), [Clean Architecture](../clean_architecture.md), [ADR 0001](0001-architecture-and-layering.md), [ADR 0004](0004-type-safe-cubit-access.md) |
| External | [blocsignal.dev](https://blocsignal.dev), [`bloc_signals`](https://pub.dev/packages/bloc_signals), [`bloc_signals_flutter`](https://pub.dev/packages/bloc_signals_flutter) |
| Independent review | Codex CLI (`gpt-5.6-sol`, read-only) 2026-09-09 — **REJECT**, confidence 92/100; evidence below, not ADR circularity |

## Context

[BlocSignal](https://blocsignal.dev) (packages `bloc_signals` / `bloc_signals_flutter`)
bridges classic BLoC/Cubit API shape with Rody Davis’s `signals` v7 primitives.
Claimed wins:

- synchronous `emit` (no Stream microtask queue for state delivery);
- fine-grained reactive subscriptions (`state` as `ReadonlySignal`);
- BLoC-like event concurrency (`droppable` / `sequential` / `restartable`)
  without stream transformers;
- low ceremony from one cubit to many blocs, especially with Dart 3.13 primary
  constructors;
- optional mixins that attach Cubit/Bloc semantics onto existing superclasses;
- interop packages for classic `bloc`, Riverpod, hydrate, DevTools, and tests.

This repo already standardizes on `flutter_bloc` Cubits, GetIt composition,
type-safe access helpers (`context.cubit`, `TypeSafeBlocSelector`),
`CubitExceptionHandler` / request-identity guards, Freezed presentation state,
and a large `bloc_test` surface. An earlier note rejected BlocSignal as a
**DI container**; this ADR evaluates it as a **state-management** alternative.

## Decision Drivers

- Preserve Clean Architecture: presentation owns state; domain/data stay free of
  UI state containers.
- Keep agent and human delivery path stable (skills, checklists, ADR 0004
  helpers, `bloc_test`).
- Prefer maturity and portfolio-proof tooling over early library churn.
- Avoid dual state-management stacks unless a measured problem requires it.
- Capture useful practices from BlocSignal without rewriting the app.

## Decision

**Keep `flutter_bloc` Cubit/BLoC as the only presentation state system.**

Do **not** add `bloc_signals`, `bloc_signals_flutter`, or related packages to
app dependencies without a superseding ADR and a bounded pilot with proof.

Do **not** use `CubitSignalMixin` / `BlocSignalMixin` (or equivalent) on
repositories, controllers, or data types — that collapses presentation state
into data/domain and violates layer ownership.

Clarify prior wording: BlocSignal is primarily a state-management family that
also ships Flutter providers; rejecting it as DI does **not** mean it was fully
evaluated as state management — this ADR does that evaluation and still rejects
adoption for this codebase.

## Alternatives Considered

| Alternative | Why not (here) |
| --- | --- |
| Full migration to BlocSignal | ~60+ Cubits, tens of `bloc_test` suites, ADR 0004 helpers, route-scoped providers, and agent skills all assume `package:bloc` / `flutter_bloc`. Migration cost dominates claimed ceremony savings. |
| Incremental dual-stack via `bloc_signals_bloc` interop | Two mental models, two test helpers, and agent confusion for little measured gain while Stream-based Cubits already meet product needs. |
| New features only on BlocSignal | Splits the portfolio demo’s state story; weakens “one way” agent guidance. |
| Adopt signals only for local UI | Ephemeral UI already uses widget state; Fine-grained rebuilds already use selectors. Extra primitive without a proven hotspot. |
| Stay on flutter_bloc (chosen) | Matches ADR 0001/0004 investment; Cubit-first already minimizes ceremony; Dart 3.13 primary constructors already reduce boilerplate. |
| Bounded Search Cubit pilot | Codex steelman: `restartable()` might replace timer/`RequestIdGuard` mechanics in `search_cubit.dart`. Still rejected now — no unresolved hotspot; pilot still costs a second provider/test/observer path and agent rules. |

## Independent Codex review (decision authority)

Prompt asked Codex to treat this ADR as hypothesis only and re-decide from live
repo evidence. Codex verdict: **REJECT** (keep `flutter_bloc` only).

Evidence Codex cited (re-checkable):

| Signal | Finding |
| --- | --- |
| Cubit / test / helper inventory | ~62 Cubit files; ~38 `bloc_test` suites; dozens of `CubitExceptionHandler` and selector/`buildWhen` call sites; `flutter_bloc` + `bloc_test` in `apps/mobile/pubspec.yaml` |
| Rebuild proof | Todo selector isolation test + physical-device remeasure (~119 FPS, no observed jank) in `docs/changes/2026-08-10_todo_list_rebuild_remeasure.md` |
| Concurrency without streams transformers | Search Cubit already uses `TimerService`, `RequestIdGuard`, lifecycle helpers |
| Package maturity | `bloc_signals*` very new / low adoption vs mature `bloc_test`; recent provider lifecycle / generic-erasure fixes |
| Layering risk | Official `CubitSignalMixin` examples attach state to repositories — conflicts with presentation-only state ownership |

Codex confidence **92/100**. Mind-change gates align with Review Triggers below
(plus sustained pub maturity and tooling parity).

**Final decision (after Codex):** do **not** add BlocSignal packages. Steal
transferable practices only.

## Consequences

### Benefits

- Single state-management story for humans and agents.
- Existing reliability helpers and tests remain the proof path.
- Docs stay honest: evaluate new libraries without silent stack churn.

### Costs

- Forgo synchronous signal propagation and native signal/hooks ergonomics until
  a future review finds a concrete rebuild or latency problem that selectors and
  Cubit discipline cannot solve.
- Must periodically re-check BlocSignal maturity if the ecosystem becomes a
  clear industry default.

## Implementation Notes

Living policy:

- [`state_management_choice.md`](../architecture/state_management_choice.md) —
  Cubit default; no second stack without ADR.
- [`bloc_standards.md`](../bloc_standards.md) — Cubit/BLoC placement and UI
  access.
- [`CODE_QUALITY.md`](../CODE_QUALITY.md) — Dart 3.13 primary constructors for
  hand-written types and optional Cubit shortening (Freezed state unchanged).

Transferable practices **without** adopting BlocSignal:

1. Prefer Cubit over Bloc unless event policy is required (already policy; this
   repo is Cubit-heavy).
2. Prefer selectors / `buildWhen` for fine-grained rebuilds; keep rebuild-count
   regression tests (already ADR 0004).
3. Use primary constructors to cut ceremony on Cubits and DTOs where Freezed is
   not required.
4. Keep state machines in presentation; never hang them on repositories via
   mixins.
5. Make concurrency policy explicit (debounce, latest-wins, droppable,
   sequential, coalesced) via current `TimerService` / `RequestIdGuard` /
   in-flight helpers — not a second state package.
6. Benchmark state-propagation claims only after separating build/layout/raster
   bottlenecks.

## Review Triggers

Re-open this ADR only when **all** of the following are true:

1. A measured presentation performance or rebuild issue is attributed to
   Stream-based Cubit delivery (profile evidence, not anecdote).
2. BlocSignal (or successor) shows stable pub ecosystem adoption and CI-friendly
   test/lint tooling comparable to `bloc_test`.
3. A pilot feature can migrate end-to-end (Cubit, page, tests, DI/route wiring)
   behind a feature flag with rollback.

## Verification

Inventory at decision time (Codex + agent, worktree from `origin/main`):

- Cubit subclasses under `apps/mobile/lib`: ~62; classic `extends Bloc<`
  feature classes: none observed in the same sweep.
- ~38 `bloc_test` suites; substantial selector/`CubitExceptionHandler` use
  (see ADR 0004 and `apps/mobile/test`).
- Independent Codex **REJECT** recorded in metadata table above.

Commands for future re-checks:

```bash
rg -l "extends Cubit" apps/mobile/lib --glob '*.dart' | wc -l
rg -l "extends Bloc<" apps/mobile/lib --glob '*.dart' | wc -l
rg "bloc_signals" apps/mobile/pubspec.yaml packages/*/pubspec.yaml
```
