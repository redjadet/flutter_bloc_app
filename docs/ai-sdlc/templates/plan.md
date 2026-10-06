# Plan template

Copy to `docs/ai-sdlc/features/<slug>/plan.md` after spec is **accepted**.
Smallest reversible write-set. Agents implement from this file.

```yaml
status: draft  # draft | accepted | in_progress | done
slug: <kebab-slug>
spec: ./spec.md
```

## Understanding

One paragraph restating the request.

## Steps

Number steps so **each step is independently verifiable** before the next (progressive
prompting). One agent turn ≈ one step: land green proof, then expand.

1. …
2. …
3. Run proof commands from [`../gates.md`](../gates.md)

## Write-set (only)

| Path | Change |
| --- | --- |
| `apps/mobile/lib/features/…` | … |
| `apps/mobile/test/…` | … |
| `docs/…` | … |

Out of scope paths stay untouched.

## Proof plan

| Lane | Command | Required? |
| --- | --- | --- |
| Format | `./bin/format --changed` | if `.dart` |
| Analyze | `./tool/analyze.sh` | yes for Dart |
| Tests | `cd apps/mobile && flutter test <paths>` | yes for behavior |
| Domain gate | e.g. `bash tool/check_offline_first_remote_merge.sh` | if offline |
| Sweep | `./bin/checklist-fast` or `./bin/checklist` | per validation routing |

## Risks + stop rules

- Stop if product/architecture ambiguity <95% confidence.
- Stop for secrets, destructive Git, or deploy without same-turn approval.

---

### Example — cancellation on Cubit close

**Steps:** (1) Add failing cubit test for late emit. (2) Register subscription via
`CubitSubscriptionMixin`. (3) Guard emit with `isClosed` / request id. (4) Prove
with focused test + analyze.

**Write-set:** cubit + test under feature; optional note in
[`engineering/cancellation_and_cache.md`](../../engineering/cancellation_and_cache.md) only if policy changes.

**Skill:** [`cancellation-disposables`](../skills/cancellation-disposables.md).

### Example — offline pending row (BLoC + repository)

Progressive slices for a new “retry sync” action on a pending todo row:

**Steps:** (1) Failing widget or cubit test: tap retry emits `RetryRequested` only.
(2) Cubit calls repository `retryPending(id)`; test with fake repo. (3) Repository
enqueues durable pending mutation (no remote overwrite); prove with
`check_offline_first_remote_merge.sh` + repo unit test. (4) UI loading/error states;
widget test with mocked cubit stream.

**Write-set:** feature cubit + repository + tests only; no unrelated sync engine files.

**Skills:** [`offline-first`](../skills/offline-first.md), then
[`progressive-prompting`](../skills/progressive-prompting.md) for turn boundaries.
