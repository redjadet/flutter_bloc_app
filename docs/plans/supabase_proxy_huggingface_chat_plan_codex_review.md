# Codex review: Supabase proxy Hugging Face chat plan

**Source:** Cross-host delegation via `~/.cursor/skills/cursor-codex-delegate/scripts/delegate_to_codex.sh`
**Model:** `gpt-5.4`
**Profile:** `balanced`
**Reviewed artifact:** [`supabase_proxy_huggingface_chat_plan.md`](supabase_proxy_huggingface_chat_plan.md) (full file contents at time of review)

**Prompt summary (verbatim intent):** Review the planning document for a Flutter BLoC app. Audience: all AI coding agents. Propose improvements for actionability and agent operability. Return markdown in `final` JSON with sections: Executive gaps, Recommended edits, Risk register, Cold-agent checklist. Be specific; do not restate the entire plan.

---

## Executive gaps

- No authoritative decision matrix exists for `build flavor × Supabase config × auth session × connectivity × Edge result × direct key presence`; an agent still has to infer transport, enqueue, and badge behavior from scattered prose.
- Error handling is not fully operable yet: the plan says `401/403` are special, but it does not define the exact `retryable`/terminal mapping each layer must implement for `sendMessage`, queued replay, and banner/copy behavior.
- The Edge API contract is still underspecified for implementation handoff: request shape, response shape, stable error codes, idempotency fields, timeout budget, and model-policy enforcement need one canonical section.
- Ownership is fuzzy for multi-agent execution: there is no explicit split for Edge, Flutter data/domain, Flutter UI/l10n, docs, and verification, so parallel work risks overlap and drift.
- The plan references many likely files but not a concrete file map or expected new types/classes; a cold agent still has to inspect and guess naming and insertion points.
- `[P0]` decisions are overloaded; several are really blockers, but the document does not separate “must resolve before any code” from “can be decided during implementation.”
- Validation is described, but there is no stage-gated acceptance matrix tying each phase to required tests, codegen, and repo scripts.
- Offline-first contract alignment is directionally strong. No change.

## Recommended edits

- Add a new section after `## Terminology` named `## Authoritative decision matrix`.
  - Add a table with columns: `Connectivity`, `Supabase configured`, `Supabase session valid`, `Edge healthy`, `Direct HF key present`, `Allowed direct by policy`, `Transport attempted`, `Fallback allowed`, `Queue or surface`, `Badge state`.
  - Add a lead bullet: `If a scenario is not listed in this table, implementation must stop and request a product/policy decision rather than infer behavior.`
- Rename `### Runtime: Supabase failure → direct (when online)` to `### Fallback policy (authoritative)`.
  - Add bullets with exact wording like: `Direct fallback is allowed only for timeout, network transport failure, and HTTP 5xx unless Phase 0 records a narrower rule.`
  - Add: `Direct fallback is not allowed for HTTP 401/403 unless a human owner explicitly records that policy in Phase 0.`
  - Add: `HTTP 429 defaults to no direct fallback; surface busy/backoff UX unless Phase 0 overrides this.`
- Under `## Do this first (Phase 0 — blocking)`, add two deliverables.
  - `3 | Failure policy matrix — exact fallback/no-fallback rules by status/error type, queue behavior, and user-visible copy.`
  - `4 | Badge semantics — authoritative rule for Offline vs Supabase vs Direct during pending, success, replay, and restart.`
- Split `## [P0] Open decisions` into two sections.
  - New `## Blocking decisions before implementation` for auth path, model policy, usable-for-chat rule, fallback-trigger policy, terminal-vs-retryable mapping, and connectivity source of truth.
  - Keep a smaller `## Deferred product decisions` for chip row layout, stickiness polish, optional tap affordance, and “last transport” display.
- Add a new section `## Implementation slices and ownership` before `## Work sequence`.
  - Include bullets: `Edge/API slice`, `Flutter remote/composite slice`, `Offline-first/error-classification slice`, `UI/l10n slice`, `Docs/security slice`, `Validation slice`.
  - Add: `Only one agent owns each slice at a time; shared files require explicit handoff notes.`
- Expand `## Code touchpoints` with a `### File map` subsection.
  - List likely files to add/update, not just directories, for example: `lib/features/chat/data/...`, `lib/features/chat/domain/...`, `lib/core/di/register_chat_services.dart`, `lib/features/chat/presentation/pages/chat_page.dart`, `lib/features/chat/presentation/widgets/...`, `supabase/functions/<name>/index.ts`, `supabase/config.toml`, [`supabase/README.md`](../../supabase/README.md).
  - Add: `If implementation chooses different filenames, update this plan before coding to keep handoffs deterministic.`
- Add a new section `## Edge API contract` under `## Approach (short)`.
  - Include concrete bullets: `Request fields`, `Response fields`, `Error body shape`, `schemaVersion`, `idempotency key`, `auth header source`, `model field policy`, `timeout budget`, `retryability field semantics`.
  - Add exact wording: `Flutter and Edge must share the same error-code vocabulary; do not invent UI-only strings in the repository layer.`
- Under `## Offline-first integration note`, add `### Queue/error classification`.
  - Add a table mapping `offline`, `timeout`, `5xx`, `401`, `403`, `429`, `invalid payload`, `missing config` to `enqueue?`, `retryable?`, `surface copy owner`, `direct fallback allowed?`.
- Add a new section `## Validation gates by phase` before `## Verify (when shipping)`.
  - Phase 1: Edge curl/JWT/negative auth checks.
  - Phase 2: targeted Dart tests, l10n/codegen if touched, `./bin/router_feature_validate` if DI/routes change.
  - Phase 3: docs/security updates and final acceptance checks.
- Delete repetition by collapsing duplicated badge/fallback caveats into the new authoritative matrix and queue/error table.
  - Add one note: `All prose examples are illustrative; the matrix and classification table are normative.`
- `## Non-goals`: No change.

## Risk register

- Multi-agent ownership collision: `register_chat_services.dart`, `OfflineFirstChatRepository`, and `chat_page.dart` are likely shared hotspots; without declared ownership, parallel edits will conflict.
- Spec drift between Edge and Flutter: request/response/error bodies can diverge if the API contract is not frozen before implementation.
- Stale link risk: the plan references specific widgets/patterns; if those files move, agents may follow broken examples unless there is a “preferred current pattern” note.
- P0 overload: too many unresolved items can cause one agent to implement assumptions while another treats them as blocked.
- Queue-behavior ambiguity: different agents may encode different `enqueue vs surface immediately` rules, producing subtle offline regressions.
- Test-gap risk: current tests listed are good, but there is no explicit regression target for `401/403 during replay`, `restart after sticky-direct`, and `badge state after queued flush`.
- Validation drift: docs mention targeted validation, but no one owner is assigned to l10n/codegen/security-doc follow-through.
- Docs-only plan handoff risk: if [`ai_integration.md`](../ai_integration.md) is updated without back-linking and copying the authoritative decisions, agents may implement against outdated assumptions.

## Cold-agent checklist

1. Read [`AGENTS.md`](../../AGENTS.md), [`agents_quick_reference.md`](../agents_quick_reference.md), [`ai_code_review_protocol.md`](../ai_code_review_protocol.md), [`offline_first/chat.md`](../offline_first/chat.md), and this plan.
2. Confirm [`ai_integration.md`](../ai_integration.md) contains the Phase 0 auth and model decisions; if not, stop and request them.
3. Confirm all blocking decisions are recorded in the plan; do not infer missing fallback or queue policy from prose.
4. Create/update [`tasks/codex/todo.md`](../../tasks/codex/todo.md) with task scope, implementation plan, open questions, and intended validation.
5. Inspect the current chat stack: `ChatRepository`, `HuggingfaceChatRepository`, `OfflineFirstChatRepository`, DI registration, `SyncStatusCubit`, and `ChatSyncBanner`.
6. Build a one-page transport matrix for the exact scenarios you will implement; if any row is ambiguous, resolve it before coding.
7. Freeze the Edge API contract: request fields, response fields, error codes, retryability semantics, auth header, and idempotency inputs.
8. Decide file ownership for Edge, Flutter data/domain, Flutter UI/l10n, and docs; avoid multi-writer edits on the same file without a handoff note.
9. Write the targeted test list first: composite behavior, queue/error classification, replay/auth expiry, and badge semantics.
10. Check whether l10n, codegen, DI, and route validation will be affected, and note the exact commands required.
11. Implement one vertical slice at a time, proving each slice against the agreed matrix rather than broad prose intent.
12. Before claiming completion, verify tests and repo scripts match the touched scope and that the plan/docs reflect any naming or contract changes made during implementation.

---

*This file is archival verbatim output from Codex (structured `final` payload). The living plan may have diverged; trust [`supabase_proxy_huggingface_chat_plan.md`](supabase_proxy_huggingface_chat_plan.md) for current intent.*
