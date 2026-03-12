# Separation of Concerns in flutter_bloc_app

This codebase applies **Separation of Concerns (SoC)** as a practical rule, not
just an architectural slogan. Features are split so domain logic, data access,
state orchestration, UI composition, and platform integration can evolve
independently.

> **Related Documentation:**
>
> - [Clean Architecture](clean_architecture.md) - Layer responsibilities and dependency flow
> - [Architecture Details](architecture_details.md) - High-level architecture and shared infrastructure
> - [SOLID Principles](solid_principles.md) - Interface-first design and dependency inversion
> - [Compile-Time Safety](compile_time_safety.md) - Type-safe BLoC/Cubit access patterns
> - [Code Quality](CODE_QUALITY.md) - Validation expectations and quality gates

## Overview

In this repository, Separation of Concerns means:

- Domain types stay Flutter-agnostic
- Data layer owns persistence, networking, and SDK integration
- Presentation owns user flows, rendering, and UI state transitions
- Cross-cutting infrastructure is extracted into shared services
- Composition happens at explicit boundaries through DI and routing

The result is a codebase that is easier to test, safer to refactor, and less
likely to accumulate hidden coupling.

## Where SoC Shows Up

### 1. Layer Boundaries

- **Domain** defines contracts and models only. Example: feature repositories
  under `lib/features/*/domain/` expose the API that cubits depend on, without
  importing Flutter or concrete SDKs.
- **Data** implements those contracts and hides storage, HTTP, Firebase,
  Supabase, Hive, and sync details behind repository abstractions.
- **Presentation** manages Cubits, pages, and widgets. It consumes abstractions
  rather than building repositories or talking directly to SDKs.

This is enforced both by convention and by validation scripts such as
`tool/check_flutter_domain_imports.sh`.

### 2. Orchestration vs Infrastructure

- `BackgroundSyncCoordinator` in `lib/shared/sync/background_sync_coordinator.dart`
  coordinates sync cycles, but delegates timing to `TimerService`,
  connectivity to `NetworkStatusService`, queued work to
  `PendingSyncRepository`, and repository participation to
  `SyncableRepositoryRegistry`.
- This keeps the coordinator focused on sync flow rather than absorbing
  storage, scheduling, and transport responsibilities into one class.

### 3. Repository Delegation

- `OfflineFirstChatRepository` in
  `lib/features/chat/data/offline_first_chat_repository.dart` handles
  orchestration for chat sync, but delegates payload construction to
  `ChatSyncOperationFactory` and local persistence/merge behavior to
  `ChatLocalConversationUpdater`.
- That split matters because offline-first repositories tend to become
  accidental "god objects" unless sync payload mapping, local writes, and
  remote execution are separated deliberately.

### 4. DI as a Composition Boundary

- Feature registrations are split into focused files such as
  `lib/core/di/register_chat_services.dart` instead of one monolithic
  registration file.
- `get_it` wiring is treated as the composition boundary where concrete data
  implementations are attached to abstract interfaces.
- This keeps feature code explicit about dependencies while avoiding container
  lookups throughout lower-level logic.

### 5. UI Access Patterns

- `lib/shared/extensions/type_safe_bloc_access.dart` centralizes typed cubit and
  state access, keeping widget code focused on rendering instead of provider
  lookup mechanics.
- `lib/shared/utils/bloc_provider_helpers.dart` centralizes common
  `BlocProvider` creation and async initialization patterns so route/page code
  does not repeatedly re-implement setup behavior.

## Guardrails

Separation of Concerns is reinforced by automated checks:

- `tool/check_flutter_domain_imports.sh` blocks Flutter imports in domain code
- `tool/delivery_checklist.sh` checks for data-layer imports in presentation
- `tool/delivery_checklist.sh` checks for presentation imports in data
- DI and repository tests rely on fakes and interfaces, which exposes coupling
  early when boundaries start to blur

## Practical Rules

- Put business rules in cubits and domain contracts, not widgets
- Put SDK, storage, and transport code in repositories/services, not cubits
- Keep shared services narrow and focused; do not turn `shared/` into a dump
- Use DI registration files as composition points, not as hidden service
  locators inside feature logic
- Extract collaborators when a repository or cubit starts handling multiple
  distinct responsibilities

## Review Checklist

- Domain files remain free of Flutter imports
- Presentation depends on interfaces or cubits, not data-layer implementations
- Data layer does not import presentation code
- Large orchestration classes delegate mapping, persistence, or transport work
- DI files stay feature-scoped and readable
- Shared helpers remove repeated infrastructure setup without taking over
  feature logic
