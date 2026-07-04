# Contracts — AI and feature boundaries

Rules for agents changing APIs, repositories, and feature surfaces. Pilot stubs below; expand after pilots prove useful.

## Global rules

1. **Domain contracts are stable** — breaking changes need migration note + tests.
2. **No cross-feature domain imports** — use `apps/mobile/lib/shared/` ports or events ([`docs/modularity.md`](docs/modularity.md)).
3. **Repositories expose async contracts** — document error types (`Failure` / `Exception`).
4. **Cubit public API** — document events/methods that UI relies on; test state transitions.
5. **Routes** — add constant in `app_routes.dart` before page registration.
6. **Offline-first** — document sync semantics when adding write paths.
7. **Secrets** — never commit; see [`docs/security_and_secrets.md`](docs/security_and_secrets.md).

## Contract template (per feature)

```markdown
### <feature>

**Repository:** `XRepository`
- `Future<Result> load()`
- errors: ...

**Cubit:** `XCubit`
- states: ...
- side effects: ...

**Routes:** ...

**Tests required:** unit / widget / ...
```

## Pilot stubs

### counter

- `CounterRepository`: load/save count; Hive-backed.
- `CounterCubit`: `CounterState`; timer tick semantics documented in tests.

### chat

- `ChatRepository`: send/receive; offline queue when enabled.
- Errors: `ChatRemoteFailureException` family (consolidation tracked ARCH-006).

### auth

- `AuthRepository`: session stream; sign-in/out.
- FirebaseUI integration stays in presentation.

### settings

- Settings repositories: locale/theme persistence.
- Diagnostics routes must stay auth-aware where required.

### todo_list

- Todo repository: offline-first writes + sync.
- Conflict policy: see offline-first adoption guide.

## More

- Link stub only: [`docs/ai/contracts.md`](docs/ai/contracts.md)
- Feature brief: [`docs/plans/FEATURE_TEMPLATE.md`](docs/plans/FEATURE_TEMPLATE.md)
