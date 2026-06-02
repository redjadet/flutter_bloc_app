---
name: agents-canonical-rules-architecture
description: Canonical rules — feature layers, domain purity, cubit vs widget roles, DI entrypoints, Freezed. Part of agents-canonical-rules split.
---

# Architecture & state

Slice of **`agents-canonical-rules`**. Detail: `docs/clean_architecture.md`, `docs/feature_implementation_guide.md`.

- No `package:flutter` under `lib/features/*/domain/`.
- Repositories implement domain interfaces; business logic in cubits/blocs.
- DI in `lib/core/di/injector*.dart`.
- Prefer Freezed for new state/domain models; `build_runner` after `@freezed`.
