# Chat Offline-First Contract

This document defines how the chat feature will adopt the shared offline-first stack so engineers can implement and test it without re-triaging requirements.

## Goals

- Persist chat conversations/messages locally so the chat UI boots instantly without network.
- Allow composing/sending while offline by queueing pending sends and reconciling when connectivity returns.
- Surface sync state to the UI (pending sends, offline banner, retry) while keeping logic in cubits/repos.

## Storage Plan

- Boxes: `chat_conversations`, `chat_messages`, `chat_pending_messages`.
- Data shapes:
  - `ChatConversationDto` with `conversationId`, `title`, `lastMessagePreview`, `lastChanged`, `lastSyncedAt`, `synchronized`.
  - `ChatMessageDto` with `messageId`, `conversationId`, `role`, `text`, `createdAt`, `clientMessageId`, `lastSyncedAt`, `synchronized`.
  - Pending: reuse `ChatMessageDto` plus `idempotencyKey` to match `SyncOperation.payload`.
- Encryption: use `HiveService`/`HiveRepositoryBase`; never open Hive boxes directly.

## Repository Wiring

- Add `ChatLocalDataSource` (Hive-backed) handling read/write/watch for conversations/messages/pending sends.
- Add `OfflineFirstChatRepository` composing:
  - `ChatRemoteRepository` (HuggingFace) for actual inference calls.
  - `ChatLocalDataSource` for persistence.
  - `PendingSyncRepository` for enqueueing outgoing messages as `SyncOperation`s.
- DI: register `ChatLocalDataSource` as the `ChatHistoryRepository` implementation (GetIt), and wire the offline-first repository into the sync registry once built.
  - Sync payload: include `conversationId`, `prompt`, `pastUserInputs`, `generatedResponses`, `model`, `clientMessageId`, `createdAt`. Processing should call remote, then persist reply + update conversation metadata (`lastSyncedAt`, `synchronized`, `changeId`).
- Implement `SyncableRepository`:
  - `entityType`: `chat_message`.
  - `processOperation`:
    - **Important**: Persist user message locally BEFORE attempting remote call to prevent data loss if sync fails.
    - Send pending message to remote, persist server response, mark local message `synchronized: true`, stamp `lastSyncedAt`.
    - If user message doesn't exist locally yet, create conversation and add user message first, then attempt remote call.
  - `pullRemote`: refresh conversations/messages list and merge into local when remote is newer.
  - Register in `SyncableRepositoryRegistry`.

## Conflict Resolution

- Client generates `clientMessageId` and `idempotencyKey` per send to dedupe retries.
- On remote response:
  - Match by `clientMessageId`; if found, update message with server echo and mark synced.
  - If server returns a message for a deleted conversation, mark conversation `resurrected` flag to prompt the user.
- Ordering: sort by `createdAt`; if ties, prefer server `messageId`.

## UI Integration

- Hydrate chat cubit from local store first, then trigger `pullRemote`.
- Show pending-send indicator per message (`synchronized == false`) and an offline/sync banner driven by `SyncStatusCubit`.
- The reusable `ChatSyncBanner` widget (added under `lib/features/chat/presentation/widgets/`) displays the offline/sync/pending copy, shows queued counts, and wires the `syncStatusSyncNowButton` CTA to `SyncStatusCubit.flush()` so users can manually retry when back online.

## Testing Checklist

- Unit tests: local data source serialization, migrations, and pending queue enqueuing.
- Repository tests:
  - `save` queues pending sends when offline.
  - `processOperation` persists user message before remote call (even when conversation doesn't exist yet).
  - `processOperation` marks messages synced after successful remote response.
  - `pullRemote` merges newer remote data.
- Bloc/widget tests: chat page renders cached history, shows pending pill, and updates when a flush delivers synced messages. `chat_cubit_test.dart` now asserts that offline enqueued sends avoid error states while leaving messages marked as pending.
- Widget tests: `test/chat_sync_banner_test.dart` covers offline messaging, disabled CTA state, and the manual flush path.
- Use `FakeTimerService` + mock connectivity to cover retry/backoff paths.

## Next Actions

1) Add bloc/widget coverage that pending chat messages flip to synced after `BackgroundSyncCoordinator.flush()` processes the queue (pending labels disappear, assistant reply shows as synced).
2) Add a ChatPage widget test to validate `ChatSyncBanner` + pending message labels together.
3) Explore a per-message “retry now” affordance once replay coverage is in place (e.g., long-press action that queues a retry).
