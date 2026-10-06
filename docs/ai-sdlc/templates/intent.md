# Intent template

Copy to `docs/ai-sdlc/features/<slug>/intent.md`. Proto-spec in the originator’s
words. Human accepts before [`spec.md`](spec.md).

```yaml
status: draft  # draft | accepted | rejected | deferred
slug: <kebab-slug>
author: <role or display name>
created: YYYY-MM-DD
related_aidlc:  # optional path under tasks/{host}/aidlc/...
related_feature:  # apps/mobile/lib/features/<name>/
```

## Problem

What hurts today? Who notices?

## Desired outcome

User-visible result when this is done.

## Why now

Trigger (user request, incident, interview demo gap, tech debt gate).

## Affected users / surfaces

- App routes / features:
- Platforms (iOS / Android / web / desktop):
- Offline / sync / native:

## Constraints

- Must not:
- Performance / battery / privacy:
- Interview showcase / Archive policy:

## Open questions

- [ ] …

## Acceptance signals (draft)

How we will know it worked (tests, demos, CI). Refined in [`spec.md`](spec.md).

---

### Example — offline sync conflict (Flutter)

```yaml
status: accepted
slug: 20261006-todo-offline-merge-guard
author: product owner
created: 2026-10-06
related_feature: apps/mobile/lib/features/todo_list/
```

**Problem:** After airplane mode, a remote refresh can replace newer local todo
edits when sync resumes.

**Desired outcome:** Pending local mutations win until acknowledged; UI shows
stale/sync state honestly.

**Constraints:** Must not invent a new sync engine; reuse Hive + existing merge
invariants ([`docs/offline_first/invariants.md`](../../offline_first/invariants.md)).

**Acceptance signals:** Unit tests for stale-remote overwrite; `bash
tool/check_offline_first_remote_merge.sh` green.
