---
name: agents-canonical-rules
description: Router for canonical coding rules — points to scoped agents-canonical-rules-* skills. Use when implementing or reviewing feature code; open the child skill that matches your change.
---

# Canonical rules (router)

**Principles:** `agents-principles-baseline`. **Pre-flight:** `agents-common-pitfalls`. **Condensed commands:** `agents-quick-reference` (AGENTS.md wins conflicts).

Open **one** child skill for the task:

| Touching | Skill |
| ---------- | ------ |
| Layers, domain purity, cubits vs widgets, DI, Freezed | `agents-canonical-rules-architecture` |
| UI, theme, l10n, Mix, a11y, type-safe BLoC, list/build perf | `agents-canonical-rules-presentation` |
| `emit` after `await`, subscriptions, timers, streams, `mounted`, dialogs | `agents-canonical-rules-async` |
| Hive, Dio, Retrofit, offline-first merge, HTTP errors, parsing, logging | `agents-canonical-rules-platform` |

**Full PR:** architecture first, then presentation / async / platform as diff requires.
