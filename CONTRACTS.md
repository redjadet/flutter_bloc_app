# Contracts — AI and feature boundaries

Rules for agents changing APIs, repositories, and feature surfaces. Expand after
pilots prove useful. DI: resolve at composition root; **no `getIt` in router
files or feature presentation pages** (see
[`docs/ai/human_ai_collaboration.md`](docs/ai/human_ai_collaboration.md)).

## Global rules

1. **Domain contracts are stable** — breaking changes need migration note + tests.
2. **No cross-feature domain imports** — use package-owned ports or app-layer composition ([`docs/modularity.md`](docs/modularity.md), [`docs/engineering/SHARED_UTILITIES.md`](docs/engineering/SHARED_UTILITIES.md)).
3. **Repositories expose async contracts** — document error types (`Failure` / `Exception`).
4. **Cubit public API** — document events/methods that UI relies on; test state transitions.
5. **Routes** — add constant in `app_routes.dart` before page registration; gated routes update [`docs/architecture/deep_link_auth_matrix.md`](docs/architecture/deep_link_auth_matrix.md).
6. **Offline-first** — document sync semantics when adding write paths; honor [`docs/offline_first/authority_invariants.md`](docs/offline_first/authority_invariants.md).
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

## Feature contracts

### counter (Spine)

**Repository:** `CounterRepository` / offline-first wrapper  
- load/save count; Hive-backed; remote merge gated by don’t-overwrite.  
- errors: `CounterError` / persistence failures retain local.

**Cubit:** `CounterCubit`  
- states: sealed/`CounterState` + view data; timer tick semantics in tests.  
- side effects: persistence + optional Remote Config surfaces.

**Routes:** `/` (`AppRoutes.counterPath`) — public.

**Tests:** `test/features/counter/**`; offline merge via `check_offline_first_remote_merge.sh`.

### todo_list (Spine)

**Repository:** offline-first todo repository  
- offline writes + sync queue; DTO boundary `TodoItemDto`; domain `todo_merge_policy`.  
- Conflict: newer local wins; TOCTOU re-read before save/delete.

**Cubit:** `TodoListCubit`  
- states: still uses `ViewStatus` bag (**intentional P4 Yellow** — document, don’t copy as gold).  
- Prefer sealed Freezed unions for new spine state (see `profile`).

**Routes:** `/todo-list` — public.

**Tests:** `test/features/todo_list/**`; merge guard inventory.

### chat (Spine)

**Repository:** `ChatRepository` (+ offline-first / composite)  
- send/receive; offline queue when enabled; transport badges (Supabase / direct / Render).  
- errors: `ChatRemoteFailureException` family; non-retryable `auth_required` dead-letters once.

**Cubit:** chat cubits under `presentation/`  
- states: sealed/`ChatFailure` paths (Tier B Green).  
- side effects: sync banners, connectivity gates.

**Routes:** `/chat`, `/chat-list` — public list; send gated by connectivity/state.

**Tests:** `test/features/chat/**`; terminal sync failure text for `auth_required`.

### profile (Spine)

**Repository:** offline-first profile repository  
- cache-first profile; remote merge honesty.

**Cubit:** `ProfileCubit`  
- states: sealed lifecycle + typed `ProfileFailure` (gold).  

**Routes:** `/profile` — **authenticated** (`AppRoutePolicies.profile`).

**Tests:** profile cubit + data tests; auth gate deep-link test.

### remote_config (Spine)

**Repository / services:** remote config stack under `features/remote_config/`  
- cache + runtime flags for Counter/Settings diagnostics.

**Cubit / state:** sealed Freezed state reference (gold layout).  
- **P6 Errors Yellow (intentional):** skip/error paths still thinner than `ProfileFailure` — copy sealed state, not error taxonomy, until a dedicated typed-failure pass.

**Routes:** surfaces via Counter + Settings (not a standalone deep link).

**Tests:** feature unit/widget coverage under `test/features/remote_config/` when present.

### auth (Spine)

**Repository:** `AuthRepository`  
- session stream; sign-in/out; anonymous upgrade.

**Presentation:** FirebaseUI stays in presentation; gates use `AppRouteAuthGate`.

**Routes:** `/auth`, `/register`, `/logged-out`, `/manage-account` (authenticated).

**Tests:** `test/app/router/app_route_auth_gate_test.dart`, `auth_redirect_test.dart`.

### settings (Spine)

**Repositories:** locale/theme persistence; sync diagnostics section (manual interview spine #4).  
- Diagnostics routes must stay auth-aware where required.

**Routes:** `/settings` — **public** (explicit policy).

### native_platform_showcase (Depth)

**Ports:** host-language / telemetry / FFI services behind Clean Architecture.  
**Do not** add net-new native demos without Archive swap (ADR-0005).  
**Tests:** `test/features/native_platform_showcase/`.

### secure_messaging_demo (Depth)

**Repository:** FFI secure core via `packages/secure_core_bridge/`.  
**Cubit:** request-gen guards; sealed failures (P6 Yellow acceptable for demo depth).

## More

- Collaboration / HITL: [`docs/ai/human_ai_collaboration.md`](docs/ai/human_ai_collaboration.md)
- Link stub: [`docs/ai/contracts.md`](docs/ai/contracts.md)
- Feature brief: [`docs/engineering/FEATURE_TEMPLATE.md`](docs/engineering/FEATURE_TEMPLATE.md)
- Gold layouts: [`docs/architecture/reference_features.md`](docs/architecture/reference_features.md)
