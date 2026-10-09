# Dart records and patterns guidance

**Date:** 2026-10-09

## Summary

- Added [`docs/engineering/dart_records_and_patterns.md`](../engineering/dart_records_and_patterns.md):
  decision table for records vs Freezed/sealed, multi-return records, switch
  expressions / guards / exhaustiveness, repo anchors, agent guardrails.
- Linked from engineering README, [`CODE_QUALITY.md`](../CODE_QUALITY.md), and
  [`compile_time_safety.md`](../architecture/compile_time_safety.md).
- Small clarity cleanups (no domain rewrite):
  - `syncBannerTitleAndMessage` → record + switch expression with `when` guard
  - `LogRedaction` map loops → `MapEntry(:key, :value)` object patterns
- Unit test for sync banner helper title/message cases.

Triggered by a Medium “Dart records and patterns” guide; article body was
Cloudflare-blocked, so teaching is grounded in dart.dev Records / Patterns /
Pattern types / Switch expressions for the pinned Dart **3.13.5** /
Flutter **3.47.6** SDK.

## Verification

- `./bin/format` on touched Dart paths
- `dart analyze` `packages/app_shared_flutter/.../log_redaction.dart` → No issues found
- `flutter test` `packages/app_shared_flutter/test/utils/log_redaction_test.dart` → 8 passed
- `flutter test` `apps/mobile/test/app/sync/sync_banner_helpers_test.dart` → 5 passed
  (local native-assets lock/codesign workaround on Lacie volume; CI is the
  authoritative mobile lane)
