# Cubit ↔ Riverpod mapping (JD “Riverpod or similar”)

This app keeps **Cubit/BLoC** as the presentation-state stack
([ADR 0001](../adr/0001-architecture-and-layering.md),
[state management choice](state_management_choice.md)). When a role description
lists Riverpod (or “similar”), use this mapping—do **not** migrate.

| Concern | Riverpod-shaped reading | This repo |
| --- | --- | --- |
| UI state holder | `Notifier` / `AsyncNotifier` | Cubit (default) or BLoC when events matter |
| Async value packing | `AsyncValue.data/loading/error` | Explicit Cubit state fields / Freezed unions |
| DI / overrides | `Provider` / `ProviderScope` overrides | GetIt composition root + test overrides |
| Scoped rebuilds | `ref.watch` select | `BlocBuilder` / `BlocSelector` / `buildWhen` |
| Side effects | `ref.listen` | `BlocListener` / stream subscriptions in Cubit |
| Repository boundary | injected via provider | domain port + data impl registered in DI |
| Offline + sync | usually custom | Hive + `BackgroundSyncCoordinator` (see EVIDENCE) |
| Tests | `ProviderContainer` | `bloc_test` + fake repositories |

Mapping is **conceptual** for JD readers. It does **not** claim lifecycle
equivalence with Riverpod. No Riverpod packages, providers, or codegen.

## Why Cubit stays

- Existing investment: type-safe Cubit helpers, custom lints, thousands of
  Cubit tests, offline-first demos already on Cubit.
- Clean Architecture already separates DI (GetIt) from state (Cubit)—the same
  separation Riverpod often conflates into one provider graph.
- Migration cost would erase portfolio signal without changing the product
  surface reviewers care about.

## Carrier line demo

[`carrier_line_demo`](../features/carrier_line_demo.md) is the thin JD-facing
surface: Cubit orchestrates local activity watch, simulated realtime, and line
status cards. Shared `FcmMessagingService` is composed for P1 push UI. A
Riverpod rewrite would be a different stack; this repo keeps Cubit.
