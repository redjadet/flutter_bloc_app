---
ai_snapshot:
  generated_at: "2026-07-14T15:22:45Z"
  git_head: "d6b5625039cbfce21e4b26e615aaca344e3449b7"
  app_root: "apps/mobile"
  canon_links:
    - docs/architecture_details.md
    - CODEMAP.md
    - docs/feature_overview.md
---



# Data flow map

High-traffic paths for agents implementing or debugging data behavior. Canon: [`docs/offline_first/adoption_guide.md`](../../docs/offline_first/adoption_guide.md).

## Path 1 — Counter (home, persisted local)

```text
CounterPage → CounterCubit → CounterRepository (contract)
  → HiveCounterRepository / REST adapters
  → Hive box + optional remote sync
```

**Docs:** `apps/mobile/lib/features/counter/`, remote config flags in `remote_config`.

## Path 2 — Todo list (offline-first + Realtime DB)

```text
TodoListPage → TodoCubit → OfflineFirstTodoRepository
  → local Hive queue + RealtimeDatabaseTodoRepository
  → PendingSyncRepository / BackgroundSyncCoordinator
```

**Docs:** [`docs/offline_first/adoption_guide.md`](../../docs/offline_first/adoption_guide.md), `apps/mobile/lib/app/sync/`, `packages/storage/`.

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

Location: `apps/mobile/lib/app/sync/` and `packages/storage/`, wired in bootstrap / `AppScope`.

## Configuration gates

| Backend | Env / setup |
| --- | --- |
| Firebase | [`docs/firebase_setup.md`](../../docs/firebase_setup.md) |
| Supabase | `SUPABASE_URL`, `SUPABASE_ANON_KEY` |
| HTTP / Dio | `apps/mobile/lib/app/http/`, `apps/mobile/lib/app/composition/features/register_http_services.dart` |

## Agent checklist (data change)

1. Identify contract in `domain/`.
2. Decide offline-first vs remote-only.
3. Register implementation in `apps/mobile/lib/app/composition/features/`.
4. Add regression test at repository or cubit level under `apps/mobile/test/`.
5. Update owning doc in `docs/` (not a second copy in `ai/`).
