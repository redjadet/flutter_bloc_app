# AI Integration Overview

This app integrates AI chat using the Hugging Face API stack and keeps the
experience resilient through offline-first storage and sync. The binding
transport policy for the planned Supabase proxy flow lives in
[`docs/plans/supabase_proxy_huggingface_chat_plan.md`](plans/supabase_proxy_huggingface_chat_plan.md).
Use this page as the compact implementation summary and keep it aligned with
that plan.

## Overview

The chat feature demonstrates production-ready AI integration with:

- **Offline-first architecture**: Messages queue locally when offline and sync when online
- **Secure storage**: Chat history encrypted using Hive with secure key management
- **Error resilience**: Guarded error handling with retry logic and user-friendly error messages
- **Model flexibility**: Configurable model selection via `SecretConfig`

## Phase 0 Policy Snapshot

These rows satisfy the plan's Phase 0 requirement. If product policy changes,
update this table and
[`docs/plans/supabase_proxy_huggingface_chat_plan.md`](plans/supabase_proxy_huggingface_chat_plan.md)
in the same change set.

| Row | Binding default |
| --- | --- |
| **1. Auth path** | Supabase proxy mode accepts only the current user's **Supabase Auth JWT**. No service-role token, no custom auth bridge, and no client HF secret on the proxy path. If Supabase is configured but no valid session exists, the app may use direct HF only when a client HF key exists and build policy allows direct transport; otherwise it must surface auth-required UX and must not enqueue. |
| **2. Model policy** | Edge owns the effective model. Client `model` is optional and only honored when it matches a server-side allowlist; otherwise Edge pins `HUGGINGFACE_MODEL` and returns a stable validation error or ignores the override per the Edge contract. |
| **3. Failure / fallback policy** | Only **timeout**, **transport/network failure to Edge**, and **Edge 5xx** may fall back to direct HF, and only when online with a client HF key plus build-policy approval. **401/403**, **429**, invalid payload, and missing config are surfaced immediately and do **not** enqueue. Retryable transport failures enqueue only after the request exhausts its allowed transport attempts. |
| **4. Badge semantics** | Offline shows **Offline** chip only. Online with active Edge path shows **Supabase**. Online after successful direct fallback or in direct-only mode shows **Direct**. Pending sends keep the intended transport badge; a successful fallback flips to **Direct** for that request. Transport stickiness is not persisted across restart. |

## Transport Decision Summary

Use the full matrix in the plan for edge cases. These summary rules are the
ones most likely to matter during implementation:

- **Preferred path**: `Supabase configured && session valid && online` -> Edge proxy.
- **Direct-only path**: use direct HF when Supabase is not configured, or when
  Supabase is configured but the session is invalid and build policy still
  allows direct HF.
- **No runnable remote path**: if the app is online but neither Edge nor direct
  transport is allowed/configured, hide the transport chip and surface
  auth/configuration UX immediately.
- **Offline**: never chain Edge then direct while offline; persist locally,
  enqueue once, and rely on shared sync.

## What It Uses

- **Hugging Face API stack**: Direct chat completions today; optional Supabase
  Edge proxy for server-side secret handling
- **Offline-first repository**: `OfflineFirstChatRepository` with queued sync operations
- **Local persistence**: Encrypted Hive storage for chat history
- **Sync coordination**: Background sync coordinator for automatic message replay

## How It Works

### Message Flow

1. **User sends message**: UI calls `ChatCubit.sendMessage()`
2. **Local persistence**: User message saved immediately to encrypted Hive storage
3. **Remote call**: Attempts Supabase Edge or direct HF according to the
   transport rules above
4. **Offline handling**: If offline or retryable transport failure after the
   allowed attempts, message queued in `PendingSyncRepository`
5. **Background sync**: `BackgroundSyncCoordinator` replays queued messages when online
6. **Response handling**: Assistant reply saved and UI updated

### Configuration

- **Model selection**: Direct path reads `SecretConfig.huggingfaceModel`; Edge
  path uses the server-owned model policy from the plan
- **API key**: Direct path uses `SecretConfig.huggingfaceApiKey`; proxy path
  uses `HUGGINGFACE_API_KEY` in Supabase Edge secrets
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
  ├── Composite remote repository (Supabase Edge first, direct fallback per policy)
  └── PendingSyncRepository (offline queue)
```

## Error Handling

- **Retryable transport errors**: Offline, timeout, network failure, and
  allowed 5xx paths queue only after the request exhausts its allowed transport
  attempts
- **Terminal auth/rate-limit/config errors**: Surface immediately and do not
  enqueue
- **API errors**: Edge/direct error bodies must map to stable machine-readable
  codes before UI copy is chosen
- **Validation errors**: Response parsing validates structure before UI update
- **Lifecycle guards**: `CubitExceptionHandler` prevents emit-after-close errors

## Related Documentation

- Offline-first chat contract: [`offline_first/chat.md`](offline_first/chat.md)
- Supabase Edge proxy (authoritative plan):
  [`plans/supabase_proxy_huggingface_chat_plan.md`](plans/supabase_proxy_huggingface_chat_plan.md)
- Error handling patterns: [`CODE_QUALITY.md`](CODE_QUALITY.md)
- Clean architecture: [`clean_architecture.md`](clean_architecture.md)
- Security and secrets: [`README.md`](../README.md) (Security & Secrets section)
