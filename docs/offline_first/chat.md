# Chat Offline-First Contract

This document defines how the chat feature uses the shared offline-first stack. **Remote inference** is selected by a **`CompositeChatRepository`** (Supabase Edge `chat-complete` when initialized + valid session, otherwise direct **`HuggingfaceChatRepository`** when a client key is allowed). See [`plans/supabase_proxy_huggingface_chat_plan.md`](../plans/supabase_proxy_huggingface_chat_plan.md) for transport rules, fallback (**online** only, eligible Edge codes), and badge semantics. The offline-first shell and local persistence below are unchanged.

## Goals

- Persist chat conversations/messages locally so the chat UI boots instantly without network.
- Allow composing/sending while offline by queueing pending sends and reconciling when connectivity returns.
- Surface sync state to the UI (pending sends, offline banner, retry) while keeping logic in cubits/repos.

## Storage plan

- Boxes: `chat_conversations`, `chat_messages`, `chat_pending_messages`.
- Data shapes:
  - `ChatConversationDto` with `conversationId`, `title`, `lastMessagePreview`, `lastChanged`, `lastSyncedAt`, `synchronized`.
  - `ChatMessageDto` with `messageId`, `conversationId`, `role`, `text`, `createdAt`, `clientMessageId`, `lastSyncedAt`, `synchronized`.
  - Pending: reuse `ChatMessageDto` plus `idempotencyKey` to match `SyncOperation.payload`.
- Encryption: use `HiveService`/`HiveRepositoryBase`; never open Hive boxes directly.

## Repository wiring

- `ChatLocalDataSource` (Hive-backed) handles read/write/watch for conversations/messages/pending sends.
- `OfflineFirstChatRepository` composes:
  - A **`ChatRepository`** implementation for remote inference (the composite: Edge-first, optional direct HF fallback when online and policy allows).
  - `ChatLocalDataSource` / `ChatHistoryRepository` for persistence.
  - `PendingSyncRepository` for enqueueing outgoing messages as `SyncOperation`s.
- DI: register local history and wire the offline-first repository into the sync registry (`lib/core/di/register_chat_services.dart`).
  - Sync payload: include `conversationId`, `prompt`, `pastUserInputs`, `generatedResponses`, `model`, `clientMessageId`, `createdAt`. Processing should call remote, then persist reply + update conversation metadata (`lastSyncedAt`, `synchronized`, `changeId`).
- Implement `SyncableRepository`:
  - `entityType`: `chat_message`.
  - `processOperation`:
    - **Important**: Persist user message locally BEFORE attempting remote call to prevent data loss if sync fails.
    - Send pending message to remote, persist server response, mark local message `synchronized: true`, stamp `lastSyncedAt`.
    - If user message doesn't exist locally yet, create conversation and add user message first, then attempt remote call.
  - `pullRemote`: refresh conversations/messages list and merge into local when remote is newer.
  - Register in `SyncableRepositoryRegistry`.
- `sendMessage`: persist the user bubble immediately, attempt the remote call. On **retryable** remote failures, enqueue the `SyncOperation` and throw `ChatOfflineEnqueuedException`. On **`ChatRemoteFailureException` with `retryable == false`** (auth, rate limit, invalid payload, missing config), **do not enqueue**—rethrow so the cubit can show the right copy. The cubit treats offline enqueue as a non-error pending state.

**Supabase Edge proxy (when enabled):** flush replays via the same composite (refreshed JWT). **`processOperation`** drops the pending op (marks completed, no assistant reply) on **non-retryable** `ChatRemoteFailureException` so the background runner does not spin on 401/403 forever; user-visible recovery is sign-in / policy, not unbounded retries.

## Conflict resolution

- Client generates `clientMessageId` and `idempotencyKey` per send to dedupe retries.
- On remote response:
  - Match by `clientMessageId`; if found, update message with server echo and mark synced.
  - If server returns a message for a deleted conversation, mark conversation `resurrected` flag to prompt the user.
- Ordering: sort by `createdAt`; if ties, prefer server `messageId`.

## UI integration

- GoRouter entries **`/chat`** and **`/chat-list`** wrap the chat UI in the same Supabase session gate as other Supabase-backed demos: if Supabase is configured (`SupabaseAuthRepository.isConfigured`) and there is no Supabase user, the app sends the user to **`/supabase-auth`** first with a safe redirect back to the requested path after sign-in. If Supabase is not configured, chat routes behave as before (no Supabase session required at the route layer).
- Hydrate chat cubit from local store first, then trigger `pullRemote`.
- Show pending-send indicator per message (`synchronized == false`) and an offline/sync banner driven by `SyncStatusCubit`.
- The reusable `ChatSyncBanner` widget (`lib/features/chat/presentation/widgets/`) displays offline/sync/pending copy, queued counts, and wires `syncStatusSyncNowButton` to `SyncStatusCubit.flush()` for manual retry.
- `ChatCubit` must clear any previous errors when it catches `ChatOfflineEnqueuedException`, leave the conversation in a pending state, and allow the coordinator/manual flush to flip messages to synced later on.

## Testing checklist

- Unit tests: local data source serialization, migrations, and pending queue enqueuing.
- Repository tests:
  - `save` queues pending sends when offline.
  - `processOperation` persists user message before remote call (even when conversation doesn't exist yet).
  - `processOperation` marks messages synced after successful remote response.
  - `pullRemote` merges newer remote data.
- Bloc/widget: `test/chat_cubit_test.dart`, `test/chat_page_test.dart`, `test/chat_sync_banner_test.dart`; use `FakeTimerService` + mock connectivity for retry/backoff.

## Next actions (backlog)

1. **Per-message retry UX** (medium): replay a single pending send; idempotent.
2. **Conversation metadata** (medium): last synced, pending chips in list.
3. **Observability** (low): queue metrics, structured logging with correlation IDs.

For shared offline-first patterns, see [`offline_first_plan.md`](offline_first_plan.md) and [`adoption_guide.md`](adoption_guide.md).
