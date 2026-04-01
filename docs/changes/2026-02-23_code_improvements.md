# Code Improvements — 2026-02-23

## Status

This document is retained as a historical change summary for the confetti,
chat rendering, and WalletConnect cleanup work from 2026-02-23.

The environment warnings in the original version are no longer current:

- `build_runner` baseline was re-verified locally on **2026-03-11**.
- Generated-code workflow is now treated as healthy and part of the normal
  validation story.
- The current authoritative quality roadmap is
  [2026-02-23_code_quality_plan.md](2026-02-23_code_quality_plan.md).

## Historical Change Summary

The original changeset introduced:

- confetti feedback on counter increment
- chat list rendering cleanup around `_ChatListData`
- WalletConnect placeholder comment cleanup

Those changes should now be evaluated against the current repo baseline rather
than the old environment notes that previously appeared in this file.

## Current Guidance

- Use `dart run build_runner build --delete-conflicting-outputs` when touching
  Freezed, Retrofit, or JSON-serializable code.
- Prefer the current validation workflow in [`new_developer_guide.md`](new_developer_guide.md).
- For current quality expectations and gates, see [CODE_QUALITY.md](../CODE_QUALITY.md).
- Do not rely on this file for active rollback, environment, or codegen
  troubleshooting guidance.
