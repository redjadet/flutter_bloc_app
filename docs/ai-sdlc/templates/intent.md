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

## Protected invariant and non-goals

- Must remain true (and one example that would violate it):
- Source of this rule (requirement or existing owner doc):
- Explicitly out of scope:

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

- [ ] Decision, human owner, and evidence needed to settle it. Resolve questions
  that change behavior, architecture boundaries, or acceptance before implementation.

## Acceptance signals (draft)

How we will know it worked (tests, demos, CI). Refined in [`spec.md`](spec.md).
Name expected observable results independently of generated code; follow the
[human work loop](../../engineering/critical_human_skills.md#humanai-work-loop-for-one-change).

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

**Desired outcome:** Newer local edits survive older remote snapshots; older
queued mutations cannot overwrite newer remote data. Sync state follows the
existing feature/diagnostics contract.

**Constraints:** Must not invent a new sync engine; reuse Hive + existing merge
invariants ([`docs/offline_first/invariants.md`](../../offline_first/invariants.md)).

**Acceptance signals:** Unit tests for stale-remote merge and stale-queue replay;
`bash tool/check_offline_first_remote_merge.sh` green.
