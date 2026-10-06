# REVIEW template

Copy to `docs/ai-sdlc/features/<slug>/REVIEW.md` when the diff is ready for PR.
Pairs with [`docs/ai_code_review_protocol.md`](../../ai_code_review_protocol.md)
and [`docs/review/code_review_playbook.md`](../../review/code_review_playbook.md).

```yaml
status: draft  # draft | ready | addressed
slug: <kebab-slug>
plan: ./plan.md
pr:  # URL when opened
```

## Summary

What changed and why (link intent/spec).

## Checklist

- [ ] Matches accepted intent/spec; no silent scope creep
- [ ] Clean Architecture / feature folder contract respected
- [ ] Cubit/BLoC async lifecycle safe (no emit after close)
- [ ] Offline merge / don’t-overwrite honored (if sync touched)
- [ ] Platform channels typed + stubbed on unsupported hosts (if native)
- [ ] Theme/tokens via design system (no one-off magic colors)
- [ ] Tests cover happy + failure; proof commands recorded
- [ ] Docs/owners updated when behavior/policy changed
- [ ] Secrets absent; security checklist if auth/PII

## Proof executed

| Command | Result |
| --- | --- |
| `./bin/format --changed` | pass / skip |
| `./tool/analyze.sh` | pass |
| `flutter test …` | pass |
| Other gates | … |

## Findings

| Severity | Finding | Resolution |
| --- | --- | --- |
| blocker / major / nit | … | fixed / deferred with reason |

## Human attention

What a human must still judge (product risk, architecture fork, release).

---

### Example — offline sync PR notes

**Summary:** Preserve pending todo mutations across remote refresh.

**Proof:** `flutter test test/features/todo_list/...` +
`bash tool/check_offline_first_remote_merge.sh`.

**Human attention:** Confirm interview Sync diagnostics still demos honest
pending state ([`docs/interview_showcase.md`](../../interview_showcase.md)).
