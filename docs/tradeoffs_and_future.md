# Trade-offs & Future Improvements

Known trade-offs accepted in the current architecture and improvements that
would raise the bar further.

> **Related:**
> [Architecture Details](architecture_details.md) |
> [Clean Architecture](clean_architecture.md) |
> [Code Quality](CODE_QUALITY.md) |
> [Flutter Best Practices Review](flutter_best_practices_review.md) |
> [Future Architecture & Code Quality Improvement Plan](plans/future_architecture_code_quality_improvement_plan.md)

## Accepted Trade-offs

### Architecture & boilerplate

- **Feature-based Clean Architecture adds boilerplate.** Every feature requires
  domain/data/presentation folders, a DI registration file, and a route entry.
  The cost is extra files; the benefit is testability, substitutability, and
  clear ownership. See [ADR 0001](adr/0001-architecture-and-layering.md).
- **get_it (service locator) vs compile-time DI.** `get_it` provides runtime
  resolution, which means missing registrations are caught at test-time rather
  than at compile-time. A compile-time DI solution (e.g. `injectable` +
  `inject`) would catch wiring errors earlier but adds code-generation overhead.

### Auth & security

- **Deep links to non-root routes can bypass auth redirects.** `GoRouter`
  `redirect` runs at the router level; deep links that land on nested routes
  may skip it. Page-level guards are needed for stricter access control.
- **No role/claims-based authorization.** Auth distinguishes authenticated vs
  anonymous only. Role or claims-based guards are deferred until multi-role
  requirements emerge.
- **Non-Firebase HTTP clients do not attach auth headers automatically.** Only
  the shared Dio instance injects Firebase ID tokens via
  `AuthTokenInterceptor`. Third-party SDKs or direct `http` calls must handle
  tokens separately.
- **Biometric gate is permissive.** `BiometricAuthenticator` allows access when
  sensors are unavailable or not enrolled. This keeps the app usable on
  emulators and older devices but is too permissive for high-security flows.

### Storage & offline-first

- **Hive as primary local store.** Hive is lightweight and fast but lacks
  relational queries and automatic migrations. Schema changes require manual
  migration logic. Isar was evaluated (see
  [Isar vs Hive comparison](migration/isar_vs_hive_comparison.md)) but not
  adopted because Hive satisfies current requirements with less overhead.
- **Offline-first repositories can become complex.** Coordinating cache, remote,
  sync queue, and conflict resolution in a single repository risks becoming a
  "god object." The mitigation is to extract collaborators early (e.g.
  `ChatSyncOperationFactory`, `ChatLocalConversationUpdater`).
- **Sync is eventually consistent.** Background sync uses periodic timers, not
  real-time push. Conflicts are resolved with a last-write-wins strategy.
  Applications requiring strict ordering or CRDTs would need a different sync
  layer.

### Performance & bundle size

- **Deferred loading trades cold-navigation latency for smaller initial
  bundle.** Heavy features (Maps, Charts, Markdown, WebSocket) load on first
  navigation, causing a brief loading screen. This saves an estimated 9–17 MB
  in the initial bundle.
- **Route-level cubit creation means cubits are re-created on navigation.**
  Feature cubits created at route scope are disposed when the user navigates
  away. This lowers memory use for unused features but means state is not
  preserved across navigations unless persisted through the repository layer.

### Testing

- **Golden tests are fragile across Flutter upgrades.** Pixel-perfect goldens
  must be regenerated (`flutter test --update-goldens`) after Flutter version
  bumps. This is a known Flutter ecosystem trade-off, not a project-specific
  issue.

## Future Improvements

### High priority

- **Role/claims-based auth and per-route authorization guards** — required
  before multi-role features ship.
- **Route-level auth checks for deep links** — prevent authenticated-only
  screens from being reachable via direct links without auth.
- **Expand token injection** beyond the shared Dio client so third-party SDKs
  also receive valid tokens when needed.

### Medium priority

- **Push-triggered sync (in progress)** — FCM can now request an immediate sync
  via `BackgroundSyncCoordinator.triggerFromFcm(...)`, with duplicate triggers
  coalesced safely. The FCM demo wires foreground/opened/initial message
  delivery to this trigger and supports optional payload hint keys:
  `sync_feature`, `sync_resource_type`, `sync_resource_id`.
- **Compile-time DI** — evaluate `injectable` or a similar code-gen DI solution
  to catch wiring errors at build time.
- **Structured error taxonomy** — replace ad-hoc error strings with a sealed
  error hierarchy (e.g. `NetworkError`, `StorageError`, `AuthError`) that
  cubits can pattern-match on for better UX.

### Low priority / nice-to-have

- **Tighten biometric policy** for sensitive flows (require enrollment, deny
  access if sensor unavailable).
- **Full analyzer plugin** for BLoC-specific lint rules (lifecycle guards,
  state exhaustiveness) — currently documented but not implemented as a plugin.
- **State machine code generation** for complex multi-step flows where explicit
  transition validation would prevent invalid states.
