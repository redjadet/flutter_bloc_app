# Data flow map

High-traffic paths for agents implementing or debugging data behavior. Canon: [`docs/offline_first/adoption_guide.md`](../../docs/offline_first/adoption_guide.md).

## Path 1 — Counter (home, persisted local)

```text
CounterPage → CounterCubit → CounterRepository (contract)
  → HiveCounterRepository / REST adapters
  → Hive box + optional remote sync
```

**Docs:** feature module `lib/features/counter/`, remote config flags in `remote_config`.

## Path 2 — Todo list (offline-first + Realtime DB)

```text
TodoListPage → TodoCubit → OfflineFirstTodoRepository
  → local Hive queue + RealtimeDatabaseTodoRepository
  → PendingSyncRepository / BackgroundSyncCoordinator
```

**Docs:** [`docs/offline_first/adoption_guide.md`](../../docs/offline_first/adoption_guide.md), `lib/shared/sync/`.

## Path 3 — Chat (multi-backend orchestration)

```text
Chat UI → ChatCubit → ChatRepository implementations
  → FastAPI / Hugging Face / Supabase edge (config-driven)
  → failure mappers → user-visible errors
```

**Docs:** [`docs/ai_integration.md`](../../docs/ai_integration.md), plans under `docs/plans/*chat*`.

## Shared sync infrastructure

| Component | Role |
| --- | --- |
| `PendingSyncRepository` | Queue outbound mutations |
| `SyncableRepositoryRegistry` | Register feature repos |
| `BackgroundSyncCoordinator` | Flush on resume / schedule |
| `NetworkStatusService` | Gate remote calls |

Location: `lib/shared/sync/`, wired in bootstrap / `AppScope`.

## Configuration gates

| Backend | Env / setup |
| --- | --- |
| Firebase | [`docs/firebase_setup.md`](../../docs/firebase_setup.md) |
| Supabase | `SUPABASE_URL`, `SUPABASE_ANON_KEY` |
| HTTP / Dio | `lib/shared/http/`, `register_http_services.dart` |

## Agent checklist (data change)

1. Identify contract in `domain/`.
2. Decide offline-first vs remote-only.
3. Register implementation in `lib/core/di/`.
4. Add regression test at repository or cubit level.
5. Update owning doc in `docs/` (not a second copy in `ai/`).
