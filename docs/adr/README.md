# Architecture Decision Records

Architecture Decision Records (ADRs) capture decisions that constrain multiple
features, shared infrastructure, or long-lived engineering trade-offs. They are
short governance records: enough context to understand the decision, enough
verification to keep it current, and links to the source docs that own daily
implementation detail.

ADRs do not replace architecture guides, feature docs, or validation scripts.
When an ADR and implementation diverge, trust current code and tests first,
then update the ADR or supersede it.

## Index

| ADR | Status | Scope | Decision |
| --- | --- | --- | --- |
| [0001](0001-architecture-and-layering.md) | Accepted | App architecture | Use feature-based Clean Architecture with `Presentation -> Domain <- Data`, BLoC/Cubit state, and `get_it` DI. |
| [0002](0002-offline-first-data.md) | Accepted | Data access and sync | Use offline-first repositories with Hive local stores, `PendingSyncRepository`, and `BackgroundSyncCoordinator`. |
| [0003](0003-deferred-feature-loading.md) | Accepted | Routing and startup | Use deferred imports and `DeferredPage` for heavy or infrequently used routed features. |
| [0004](0004-type-safe-cubit-access.md) | Accepted | Presentation state access | Prefer shared type-safe BLoC/Cubit access helpers and selectors for routine presentation code. |
| [0005](0005-interview-showcase-scope.md) | Accepted | Portfolio curation | Frozen interview spine, doc-only analytics until second consumer, PR smoke aligned to spine. |

## When To Add Or Update An ADR

Add or update an ADR when a change:

- sets policy for more than one feature or team workflow;
- changes dependency direction, persistence strategy, routing policy, or shared
  state-management conventions;
- accepts a lasting trade-off that future contributors should not rediscover;
- supersedes guidance in an existing ADR.

Do not create ADRs for local implementation details, one-off bug fixes, or
decisions already owned by a narrower feature document.

## ADR Format

Use this structure for new records:

1. Metadata table with status, scope, and owner docs.
2. Context and decision drivers.
3. Decision.
4. Alternatives considered.
5. Consequences, split into benefits and costs.
6. Implementation notes.
7. Review triggers.
8. Verification links or commands.

## Status Values

- **Proposed**: under review; not binding yet.
- **Accepted**: current governing decision.
- **Superseded**: replaced by a newer ADR; link to the replacement record.
- **Deprecated**: no longer recommended, but kept for history.
