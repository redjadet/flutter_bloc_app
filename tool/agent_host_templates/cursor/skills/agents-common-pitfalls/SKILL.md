---
name: agents-common-pitfalls
description: Pre-flight checklist of frequent agent mistakes. Use before writing or reviewing code.
---

# Common pitfalls

Pre-flight scan. **Full rules:** `agents-canonical-rules` (+ matching `agents-canonical-rules-*`). **Table:** [`docs/CODE_QUALITY.md`](../../../../../docs/CODE_QUALITY.md) + `agents-common-pitfalls` skill triggers.

Top misses: Flutter in `domain/`; `context.read` (use `type-safe-bloc-access`); emit/`mounted` after `await`; offline remote-over-local; direct `Hive.openBox`/ad-hoc Dio; `print` vs `AppLogger`; hardcoded colors/strings.
