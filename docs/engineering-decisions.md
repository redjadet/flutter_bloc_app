# Engineering decisions (entry hub)

> **Do not duplicate** — this page links to canonical docs. Edit the targets, not this hub.

Governance and lasting trade-offs. For feature-local decisions, prefer feature docs or a new ADR when scope is cross-cutting.

## Start here

- [adr/README.md](adr/README.md) — architecture decision records (when to add/update)
- [adr/0001-architecture-and-layering.md](adr/0001-architecture-and-layering.md) — Clean Architecture + Cubit
- [adr/0002-offline-first-data.md](adr/0002-offline-first-data.md) — offline-first + sync queue
- [adr/0005-interview-showcase-scope.md](adr/0005-interview-showcase-scope.md) — frozen interview spine
- [architecture/use_case_dto_policy.md](architecture/use_case_dto_policy.md) — when cubits call repos vs use cases
- [authentication.md](authentication.md) — Firebase vs Supabase vs WalletConnect (dual-auth)
- [reliability_error_handling_performance.md](reliability_error_handling_performance.md) — errors, retries, performance guards
- [flutter-anti-patterns.md](flutter-anti-patterns.md) — AP-01–AP-10 (canonical; agents stub in `ai/reports/`)
- [failure-notebook.md](failure-notebook.md) — symptom → cause → fix entries
