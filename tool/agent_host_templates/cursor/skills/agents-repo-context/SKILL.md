---
name: agents-repo-context
description: Flutter BLoC app stack snapshot and lib/ layout. Use at task start or when adding features, routes, or shared code.
---

# Repo context

Thin adapter. **Version/pin facts:** `docs/agent_project_context.md`. **Map:** `AGENTS.md`.

**Stack:** Flutter 3.41.9 / Dart 3.11.5; `Presentation -> Domain <- Data`; Cubit/BLoC; `get_it`; GoRouter; offline-first `lib/shared/sync/`.

**Also:** `agents-modularity`, `agents-shared-patterns`, `agents-cursor-integration` (`.cursor/` + host sync).

## `lib/` layout

```text
lib/
├── app/                    # shell, router, deferred pages
├── core/                   # di/, AppRoutes, theme/, supabase/
├── features/<feature>/     # domain/ | data/ | presentation/
├── shared/                 # components, widgets, http, storage, sync, design_system/
└── l10n/
```

**New feature:** `lib/features/<feature>/{domain,data,presentation}/`; DI in `lib/core/di/`; routes in `lib/app/router/` + `lib/core/router/app_routes.dart`.

**After implementing:** narrow validation from `docs/agents_quick_reference.md`; edge cases via `analyze-changes-edge-cases`.
