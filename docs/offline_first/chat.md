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
- `sendMessage`: persist the user bubble immediately, attempt the remote call, and when a failure occurs enqueue the `SyncOperation` and throw `ChatOfflineEnqueuedException`. The cubit treats this as a success state so pending messages stay visible without error banners.

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
- `ChatCubit` must clear any previous errors when it catches `ChatOfflineEnqueuedException`, leave the conversation in a pending state, and allow the coordinator/manual flush to flip messages to synced later on.

## Testing Checklist

- Unit tests: local data source serialization, migrations, and pending queue enqueuing.
- Repository tests:
  - `save` queues pending sends when offline.
  - `processOperation` persists user message before remote call (even when conversation doesn't exist yet).
  - `processOperation` marks messages synced after successful remote response.
  - `pullRemote` merges newer remote data.
- Bloc/widget tests: chat page renders cached history, shows pending pill, and updates when a flush delivers synced messages. `test/chat_cubit_test.dart` now covers the full coordinator-driven flush pipeline, while `test/chat_page_test.dart` exercises `ChatSyncBanner` + pending labels during manual sync. Use these as reference patterns.
- Widget tests: `test/chat_sync_banner_test.dart` covers offline messaging, disabled CTA state, and the manual flush path.
- Use `FakeTimerService` + mock connectivity to cover retry/backoff paths.

## Next Actions

1. **Per-message retry UX** (Priority: Medium)
   - Explore a per-message "retry now" affordance (swipe/long-press) that replays a single pending send without waiting for the full coordinator batch.
   - Add visual feedback when individual message retry is triggered.
   - Ensure retry operations are idempotent and don't create duplicate messages.

2. **Conversation metadata** (Priority: Medium)
   - Surface conversation-level metadata (e.g., "Last synced …", pending count chips) in the history list so users know which threads are current.
   - Add conversation title and last message preview updates on sync.
   - Show sync status indicators in conversation list items.

3. **Observability & telemetry** (Priority: Low)
   - Feed sync metrics/telemetry (queue depth, flush duration, success/failure rates) into `ErrorNotificationService`/analytics so we can monitor chat reliability in the wild.
   - Add debug menu to inspect pending operations and sync queue state.
   - Implement structured logging for sync operations with correlation IDs.
