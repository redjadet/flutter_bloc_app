# Live feature artifacts

Committed home for the **intent → spec → plan → REVIEW** chain on non-trivial
feature work. Keep one folder per slug; do not invent parallel rule books.

## Path

```text
docs/ai-sdlc/features/<YYYYMMDD-kebab-slug>/
  intent.md
  spec.md
  plan.md
  REVIEW.md          # fill before / with PR
  notes.md           # optional scratch; prefer deleting before merge
```

Copy from [`../templates/`](../templates/).

## Naming

- `slug`: short kebab feature id (`offline-todo-reorder`, `ble-scan-cancel`).
- Prefix with UTC date `YYYYMMDD` when multiple runs may collide.
- Same slug may appear in AIDLC as `tasks/{host}/aidlc/{run-id}/` for
  machine-checked state — cross-link both ways in the first paragraph of
  the live intent file (see [`../templates/intent.md`](../templates/intent.md)).

## When to create a folder

| Create | Skip |
| --- | --- |
| Offline sync / conflict / Hive schema | Typo / comment-only |
| Platform channel / FFI / PlatformView | Pure doc typo with no behavior |
| New Cubit surface or cross-feature DI/routes | Mechanical lint fix |
| Explicit user request for the artifact loop | T0 obvious one-liner |

## Relationship to AIDLC and feature briefs

| Concern | Owner |
| --- | --- |
| Human+agent readable intent/spec/plan/review | This folder |
| Machine-checked `run_status` / gates | [`../../ai/aidlc_workflow.md`](../../ai/aidlc_workflow.md) |
| Tests contract before implementation | [`../../engineering/FEATURE_TEMPLATE.md`](../../engineering/FEATURE_TEMPLATE.md) |
| Shipped rationale | [`../../changes/`](../../changes/README.md) |

Do not duplicate long architecture prose here — link
[`../../architecture/reference_features.md`](../../architecture/reference_features.md)
and the feature README under `apps/mobile/lib/features/`.

## Example (illustrative only)

See filled template bodies under [`../templates/`](../templates/) (offline sync,
platform channel, Cubit cancellation). Copy those sections into a live folder
when starting real work; do not leave unfinished live folders on `main`
without `status: deferred` in the live intent file.
