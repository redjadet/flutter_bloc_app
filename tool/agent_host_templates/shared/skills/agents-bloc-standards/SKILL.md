---
name: agents-bloc-standards
description: Repo BLoC/Cubit standards for Cursor and Codex feature work, state modelling, lifecycle, side effects, and tests.
---

# BLoC standards

Use before creating or reviewing Cubit/BLoC code.

Read: `docs/bloc_standards.md`, then `docs/review/bloc_checklist.md` for review.

Rules:
- Default `Cubit`; use `Bloc` only for event queue/transformer complexity.
- State/domain models prefer Freezed.
- Cubit/Bloc depends on domain/core contracts only.
- Data owns DTO/storage/network/offline sync.
- Widgets render state and callbacks; side effects use listeners/router seams.
- Async emits guarded by `isClosed`, request freshness, or `isAlive`.
- Dispose streams/timers/controllers in `close()`.

Proof: focused `flutter test <paths>` + `./tool/analyze.sh`; escalate per
`docs/engineering/validation_routing_fast_vs_full.md`.
