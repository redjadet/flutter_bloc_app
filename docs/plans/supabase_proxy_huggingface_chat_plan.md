# Supabase → Hugging Face chat proxy — contract

**Status:** Shipped. Normative behavior for agents changing chat transport.

Living offline shell: [`offline_first/chat.md`](../offline_first/chat.md).
Secrets: [`security_and_secrets.md`](../security_and_secrets.md).
Edge deploy notes: [`supabase/README.md`](../../supabase/README.md).
Policy mirror: [`ai_integration.md`](../ai_integration.md).

## Transport matrix (normative)

| Connectivity | Supabase + session | Edge result | Direct key + policy | Behavior |
| --- | --- | --- | --- | --- |
| Offline | Any | n/a | Any | One fail → enqueue; Offline chip; no transport chip |
| Online | Yes | Healthy | Any | Edge only; Supabase chip |
| Online | Yes | Timeout / transport / 5xx | Yes | Edge then direct; Direct chip on success |
| Online | Yes | Timeout / transport / 5xx | No | Enqueue retryable; Supabase chip |
| Online | Yes | 401 / 403 / 429 | Any | Surface immediately; **do not** enqueue or fall back |
| Online | No / no session | n/a | Yes | Direct only when policy allows |
| Online | No / no session | n/a | No | Auth/config surface; no enqueue |

## Queue / error classification (normative)

| Condition | Enqueue? | Direct fallback (online)? |
| --- | --- | --- |
| Offline | Yes | No |
| Edge timeout / network / 5xx | Yes if direct unavailable/fails | Yes if key + policy |
| Edge 401 / 403 / 429 | No | No |
| Direct timeout / network / 5xx | Yes | No further |
| Direct 401 / 403 / 429 / invalid / missing key | No | No |

## Binding defaults

1. Proxy path uses **user Supabase JWT** only (no service-role in client).
2. Edge owns effective **model** (allowlist or pin `HUGGINGFACE_MODEL`).
3. Fallback allowlist: timeout, transport, Edge 5xx only — online only.
4. Badges: Offline chip offline; online shows Supabase or Direct; no persisted
   Direct stickiness across restart.

## Code entrypoints

- `supabase/functions/chat-complete/`
- `apps/mobile/lib/app/composition/features/register_chat_services.dart`
- `CompositeChatRepository` / `OfflineFirstChatRepository` / chat UI badges
