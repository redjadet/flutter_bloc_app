# Docs: BlocSignal evaluation (stay on flutter_bloc)

## Problem

BlocSignal ([blocsignal.dev](https://blocsignal.dev)) markets BLoC rigor with
signals-speed sync propagation and low ceremony. Repo docs only rejected it as
a **DI container**, so agents could still treat it as an open state-management
option or confuse the prior wording.

## Scope

- In: ADR 0007; state-management choice table of transferable practices;
  clarify Clean Architecture / BLoC standards / ADR 0001 alternatives.
- Out: package adoption, code migration, dual-stack interop pilot.

## Decision

Stay on `flutter_bloc` Cubit/BLoC. Steal practices (Cubit-first, selectors,
primary constructors, presentation-only state); do not add `bloc_signals*`.

Final authority for this branch: independent Codex CLI review
(`gpt-5.6-sol`, read-only sandbox) returned **REJECT** at 92/100 from live
inventory, Todo rebuild proof, Search concurrency helpers, and package-maturity
risk — treating ADR 0007 as hypothesis, not circular proof.

## Evidence

- Cubit-heavy presentation (~62 Cubits; no classic feature `Bloc<` classes in
  inventory sweep); ~38 `bloc_test` suites; heavy selector /
  `CubitExceptionHandler` use.
- Todo rebuild isolation + ~119 FPS remeasure; Search already has
  debounce/latest-wins without BlocSignal.
- Clean Architecture forbids repository/data state containers (rejects
  CubitSignalMixin-on-repository pattern).
- `bloc_signals*` very new / low adoption vs mature `bloc_test`.

## Owners

- [`docs/adr/0007-blocsignal-evaluation.md`](../adr/0007-blocsignal-evaluation.md)
- [`docs/architecture/state_management_choice.md`](../architecture/state_management_choice.md)
