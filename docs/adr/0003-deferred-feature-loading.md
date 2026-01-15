# ADR 0003: Deferred Feature Loading

Status: Accepted

## Context

Some features (maps, charts, markdown editor, websocket demos) add weight to the initial bundle and are not required on first app launch.

## Decision

- Use deferred imports for heavy or infrequently used features.
- Wrap deferred routes with `DeferredPage` and lazy DI registration.
- Keep core and frequently used screens eagerly loaded.

## Consequences

- Additional initialization handling on route entry.
- Smaller initial bundle and faster startup for common flows.
- A need to keep deferred feature boundaries explicit in routing.
