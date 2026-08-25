# Separation of Concerns in flutter_bloc_app

SoC here means applying Clean Architecture layers and modularity at
composition boundaries — not a parallel architecture.

> **Owners (do not duplicate layer prose):**
>
> - [Clean Architecture](../clean_architecture.md) — layer responsibilities and dependency flow
> - [Feature Structure Contract](feature_structure_contract.md) — folder skeleton
> - [Modularity](../modularity.md) — dependency direction and package contracts
> - [Architecture Details](../architecture_details.md) — app shell / DI / routing
> - [SOLID Principles](solid_principles.md) — interface-first design
> - [Code Quality](../CODE_QUALITY.md) — gates overview

## Overview

In this repository, Separation of Concerns means:

- App shell owns startup, routing, and app-scope composition
- Domain types stay Flutter-agnostic
- Data layer owns persistence, networking, and SDK integration
- Presentation owns user flows, rendering, and UI state transitions
- Cross-cutting infrastructure is extracted into shared services
- Composition happens at explicit boundaries through DI and routing

Layer and shell rules: [`clean_architecture.md`](../clean_architecture.md) § Mental
Model / § Layer Responsibilities. Unique SoC examples below show how those
rules show up in concrete collaborators.

## Where SoC Shows Up (examples)

### Orchestration vs Infrastructure

- `BackgroundSyncCoordinator` in `packages/networking/lib/src/sync/background_sync_coordinator.dart`
  coordinates sync cycles, but delegates timing to `TimerService`,
  connectivity to `NetworkStatusService`, queued work to
  `PendingSyncRepository`, and repository participation to
  `SyncableRepositoryRegistry`.
- This keeps the coordinator focused on sync flow rather than absorbing
  storage, scheduling, and transport responsibilities into one class.

### Repository Delegation

- `OfflineFirstChatRepository` in
  `apps/mobile/lib/features/chat/data/offline_first_chat_repository.dart` handles
  orchestration for chat sync, but delegates payload construction to
  `ChatSyncOperationFactory` and local persistence/merge behavior to
  `ChatLocalConversationUpdater`.
- That split matters because offline-first repositories tend to become
  accidental "god objects" unless sync payload mapping, local writes, and
  remote execution are separated deliberately.

### DI as a Composition Boundary

- Feature registrations are split into focused files such as
  `apps/mobile/lib/app/composition/features/register_chat_services.dart` instead of one monolithic
  registration file.
- `get_it` wiring is treated as the composition boundary where concrete data
  implementations are attached to abstract interfaces.
- This keeps feature code explicit about dependencies while avoiding container
  lookups throughout lower-level logic.

### UI Access Patterns

- `package:ilkersevim_type_safe_bloc` centralizes typed cubit and
  state access, keeping widget code focused on rendering instead of provider
  lookup mechanics.
- `apps/mobile/lib/app/utils/bloc_provider_helpers.dart` centralizes common
  `BlocProvider` creation and async initialization patterns so route/page code
  does not repeatedly re-implement setup behavior.

## Guardrails

- `tool/check_flutter_domain_imports.sh` blocks Flutter imports in domain code
- `tool/delivery_checklist.sh` checks for data-layer imports in presentation
  and presentation imports in data
- DI and repository tests rely on fakes and interfaces, which exposes coupling
  early when boundaries start to blur

## Practical Rules

- Put business rules in cubits and domain contracts, not widgets
- Put routing/bootstrap/app-scope composition in the app shell, not inside
  feature repositories or widgets
- Put SDK, storage, and transport code in repositories/services, not cubits
- Keep shared services narrow and focused; do not turn packages into dump bins
- Use DI registration files as composition points, not as hidden service
  locators inside feature logic
- Extract collaborators when a repository or cubit starts handling multiple
  distinct responsibilities

## Review Checklist

Use [`review/architecture_checklist.md`](../review/architecture_checklist.md).
Quick SoC checks: domain free of Flutter; shell stays composition-focused;
presentation depends on interfaces/cubits; data does not import presentation;
orchestration classes delegate mapping/persistence/transport; DI stays
feature-scoped.
