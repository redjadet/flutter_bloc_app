# Approval tests adoption — 2026-08-07

## Summary

Adopted `approval_tests` (^1.7.1) for complex JSON/text snapshots in mobile
unit tests (Hugging Face payload builder, response-parser happy paths, nested
`ChatConversationDto.toJson`). Complements `golden_toolkit` (pixels), not a
replacement.

## Scope

- Dev dependency + shared strict options helper
  (`apps/mobile/test/helpers/approval_test_options.dart`).
- Commit `*.approved.*`; ignore `*.received.*`.
- Docs: testing overview conventions/layers/commands, tech stack, CODE_QUALITY,
  contributing FAQ.

## Non-goals

- `approval_tests_flutter` for widget/integration UI approvals.
- Replacing focused edge-case `expect`s with approvals.

## Locked behavior

- CI uses `MissingApprovedPolicy.writeReceivedAndFail` (no auto-baseline).
- Test names must not contain `/` or `\` (artifact name segments).
- Local mismatch review: `dart run approval_tests:review` from `apps/mobile`.

## Rollback

`git revert` of the adoption commit(s). Delete unused `*.approved.*` if reverting
tests.

## Validation

```bash
cd apps/mobile && flutter test \
  test/huggingface_payload_builder_test.dart \
  test/huggingface_response_parser_test.dart \
  test/features/chat/data/chat_conversation_dto_approval_test.dart
bash tool/check_docs_gardening.sh --paths \
  docs/tech_stack.md docs/testing_overview.md docs/CODE_QUALITY.md \
  docs/contributing/FAQ.md docs/changes/2026-08-07_approval_tests.md \
  docs/changes/README.md
```

Shipped in #682 (code + baseline docs); this note and remaining cross-links land
as a docs follow-up.
