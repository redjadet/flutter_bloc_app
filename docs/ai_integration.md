# AI Integration Overview

This app integrates AI chat using the Hugging Face Inference API and keeps the
experience resilient through offline-first storage and sync.

## Overview

The chat feature demonstrates production-ready AI integration with:

- **Offline-first architecture**: Messages queue locally when offline and sync when online
- **Secure storage**: Chat history encrypted using Hive with secure key management
- **Error resilience**: Guarded error handling with retry logic and user-friendly error messages
- **Model flexibility**: Configurable model selection via `SecretConfig`

## What It Uses

- **Hugging Face Inference API**: For chat completions (GPT-OSS models)
- **Offline-first repository**: `OfflineFirstChatRepository` with queued sync operations
- **Local persistence**: Encrypted Hive storage for chat history
- **Sync coordination**: Background sync coordinator for automatic message replay

## How It Works

### Message Flow

1. **User sends message**: UI calls `ChatCubit.sendMessage()`
2. **Local persistence**: User message saved immediately to encrypted Hive storage
3. **Remote call**: Attempts to send via Hugging Face API
4. **Offline handling**: If offline/failure, message queued in `PendingSyncRepository`
5. **Background sync**: `BackgroundSyncCoordinator` replays queued messages when online
6. **Response handling**: Assistant reply saved and UI updated

### Configuration

- **Model selection**: Read from `SecretConfig.huggingfaceModel` (build-time configuration)
- **API key**: Managed via `SecretConfig.huggingfaceApiKey` (secure storage)
- **Response parsing**: `HuggingFaceResponseParser` validates and extracts responses
- **Payload building**: `HuggingFacePayloadBuilder` constructs API requests

### Offline-First Implementation

The chat repository implements the `SyncableRepository` interface:

- **Write-first strategy**: Messages saved locally before remote call
- **Conflict resolution**: Handles duplicate messages and sync conflicts
- **Sync metadata**: Tracks `synchronized`, `lastSyncedAt`, and `changeId` per message
- **Queue management**: `PendingSyncRepository` manages offline operations

## Architecture

```text
ChatCubit
  ↓
ChatRepository (interface)
  ↓
OfflineFirstChatRepository
  ├── ChatSyncOperationFactory (sync payload creation)
  ├── ChatLocalConversationUpdater (local persistence)
  ├── HuggingfaceChatRepository (remote API)
  └── PendingSyncRepository (offline queue)
```

## Error Handling

- **Network errors**: Caught and queued for retry
- **API errors**: Parsed and surfaced with user-friendly messages
- **Validation errors**: Response parsing validates structure before UI update
- **Lifecycle guards**: `CubitExceptionHandler` prevents emit-after-close errors

## Related Documentation

- Offline-first chat contract: `docs/offline_first/chat.md`
- Error handling patterns: `docs/CODE_QUALITY_ANALYSIS.md`
- Clean architecture: `docs/clean_architecture.md`
- Security and secrets: `README.md` (Security & Secrets section)
