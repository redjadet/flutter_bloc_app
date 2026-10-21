# Feature: Chat Dart 3 records and patterns

**Date:** 2026-10-21

## Problem

Chat failure classification, payload parsing, and a few presentation branches
used ordered `if` chains. Those branches are harder to scan, and a new sealed
variant can fall through without a compiler error. This refactor keeps the same
chat outcomes and rewrites those branches with Dart 3 records, patterns, and
switch expressions, following
[`engineering/dart_records_and_patterns.md`](../engineering/dart_records_and_patterns.md).

## Scope

- In: chat data mappers, parsers, and local reads; cubit helper/action
  branches; model-label, list-selector, and terminal-sync-failure copy.
- Out: domain entities, Freezed Cubit state, repository ports, DI, routes,
  l10n catalogs, sync merge rules, and any new user-visible chat behavior.

## Layers touched

- [ ] domain
- [x] data
- [x] presentation
- [ ] DI
- [ ] routes / l10n

## Contracts

- Repository: chat repository ports and sync merge behavior are unchanged.
- State: Freezed chat state stays the same. Helpers only change how an existing
  failure is cleared or copied.
- Failure mapping: direct, Render, Hugging Face, and Supabase edge-function
  mappers still emit the same codes, retryable flags, and exception types.
- Parsing: conversation dates, sync string lists, and Hugging Face response
  shapes keep the same fallbacks (empty, missing, and unexpected values).

## Behavior contract (define before implementation)

- Must remain true: a given error, status, or payload still classifies to the
  same code, retryable flag, parsed value, or localized label as before this
  refactor. Owner: chat data mappers and the presentation switches listed below.
- Inputs: existing valid payloads, boundary values (empty lists, missing
  fields, unknown model ids, unparsed dates), and invalid or upstream-failure
  bodies already covered by chat tests.
- Failure/recovery: dependency and HTTP failures still surface as the same
  `ChatRemoteFailureException` / `ChatException` mapping; no new retry or
  recovery path.
- Source of expected results: behavior already locked by the chat suites below.
  This note records a behavior-preserving expression change
  ([#1052](https://github.com/redjadet/flutter_bloc_app/pull/1052)).

## What changed

Data:

- `chat_direct_failure_mapper.dart` — named record
  `({String code, bool retryable})` plus a status-code switch.
- `render_chat_failure_mapper.dart` and
  `supabase_chat_edge_function_exception_mapper.dart` — switch on error,
  status, and detail shape.
- `huggingface_api_client.dart`, `huggingface_response_parser.dart`,
  `huggingface_payload_builder.dart` — response/timeout switches, list
  patterns, and `indexed` record destructure.
- `chat_conversation_dto.dart`, `chat_local_data_source.dart`,
  `chat_sync_operation_factory.dart` — date, raw-value, and string-list
  switches.

Presentation:

- `chat_cubit_helpers.dart` — record switch on `(clearError, error)`.
- `chat_cubit_message_actions.dart` — object patterns on chat exceptions.
- `chat_cubit_selection_actions.dart` — loaded-state record destructure and
  `indexed` history pairing.
- `chat_list_view.dart`, `chat_model_selector.dart`,
  `chat_terminal_sync_failure_text.dart` — selector and label switches.

## Tests (executable contract)

Tests: N/A — behavior-preserving expression refactor; no new scenario. The
existing chat suites stay the executable contract (not modified in this
change):

- Behaviour: `apps/mobile/test/features/chat/presentation/cubit/chat_cubit_send_supersession_test.dart`,
  `apps/mobile/test/features/chat/presentation/pages/chat_page_history_selection_test.dart`,
  `apps/mobile/test/features/chat/presentation/widgets/chat_list_view_test.dart`,
  `apps/mobile/test/features/chat/presentation/widgets/chat_terminal_sync_failure_text_test.dart`
- Unit: `apps/mobile/test/features/chat/data/chat_direct_failure_mapper_test.dart`,
  `apps/mobile/test/features/chat/data/render_chat_failure_mapper_test.dart`,
  `apps/mobile/test/features/chat/data/huggingface_api_client_test.dart`,
  `apps/mobile/test/features/chat/data/chat_local_data_source_test.dart`,
  `apps/mobile/test/features/chat/data/chat_sync_operation_factory_test.dart`,
  `apps/mobile/test/features/chat/data/chat_conversation_dto_approval_test.dart`
- Integration: omitted. Single-feature expression rewrite; no new journey.
- Generated property check: N/A. Classification oracles already live in the
  mapper unit tests above.

### Proof command

- `cd apps/mobile && flutter test test/features/chat/data/chat_direct_failure_mapper_test.dart test/features/chat/data/render_chat_failure_mapper_test.dart test/features/chat/data/huggingface_api_client_test.dart test/features/chat/data/chat_local_data_source_test.dart test/features/chat/data/chat_sync_operation_factory_test.dart test/features/chat/data/chat_conversation_dto_approval_test.dart test/features/chat/presentation/widgets/chat_terminal_sync_failure_text_test.dart test/features/chat/presentation/widgets/chat_list_view_test.dart`

This docs follow-up does not re-run that suite. Dart sources are unchanged
from the refactor commit.

## Docs

- [x] This note, indexed from [`docs/changes/README.md`](README.md)
- [x] Living practice already in
  [`engineering/dart_records_and_patterns.md`](../engineering/dart_records_and_patterns.md)
- [ ] `docs/feature_overview.md` — chat row unchanged

## Risks

A reordered default arm could classify an unknown status differently from the
old `if` chain. Mapper and parser tests above are the check for that drift.
Freezed chat state was left in place on purpose; records are for short
multi-value returns only.

## depends_on

- [x] [`engineering/dart_records_and_patterns.md`](../engineering/dart_records_and_patterns.md)
- [x] Refactor commit on `grokbot/dart-records-patterns` (`3649d47b`)

## blocks

- None.

## merge_order

- Same PR as the chat Dart refactor ([#1052](https://github.com/redjadet/flutter_bloc_app/pull/1052)). The note lands after the code commit.

## rollback

- Revert the refactor commit to restore the `if` chains. This note is
  documentation only and can be reverted with it.

## proof_commands

```bash
bash tool/check_feature_brief_linked.sh --base origin/main
bash tool/check_docs_gardening.sh --paths docs/changes/2026-10-21_chat_dart_records_patterns.md docs/changes/README.md
bash tool/check_ai_change_contract.sh --base origin/main
```
