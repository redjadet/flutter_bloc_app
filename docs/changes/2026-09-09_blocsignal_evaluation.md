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

## Evidence

- Cubit-heavy presentation (~60 Cubits; no classic feature `Bloc<` classes in
  inventory sweep).
- Existing ADR 0004 helpers and `bloc_test` suites.
- Clean Architecture forbids repository/data state containers (rejects
  CubitSignalMixin-on-repository pattern).

## Owners

- [`docs/adr/0007-blocsignal-evaluation.md`](../adr/0007-blocsignal-evaluation.md)
- [`docs/architecture/state_management_choice.md`](../architecture/state_management_choice.md)
