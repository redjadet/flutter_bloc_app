# AIDLC artifact contract

Machine-checkable schemas for repo-native AIDLC. Semantics owner:
[`../ai/aidlc_workflow.md`](../ai/aidlc_workflow.md). Schema version: `1`.

## Shared fields

Required on Lite YAML and full aidlc-state (markdown):

| Field | Values / notes |
| --- | --- |
| `aidlc_schema_version` | `1` |
| `mode` | `lite` or `full` |
| `run_status` | `active`, `blocked`, `superseded`, `complete` |
| `current_stage` | `inception`, `construction`, `operation` |
| `task_type` | `docs`, `feature`, `bugfix`, `refactor`, `operations` |
| `field` | `brownfield` (this repo) |
| `risk` | `low`, `medium`, `high`, `unknown` |
| `next_gate` | string gate id |
| `operation` | `not_applicable` or authorized op label |
| `operation_reason` | required when `not_applicable` |
| `extensions` | map; every known key present |
| `gate_events` | list; see below |

When `run_status: blocked`, also require `blocker`, `blocker_owner`,
`unblock_condition`. Full mode also requires `run_id`.

### Known extension keys

`user_story`, `architecture`, `testing`, `security`, `resilience`,
`ui_platform`, `operations`, `documentation`, `property_based_testing`.

Each entry:

```yaml
testing:
  status: selected  # or skipped
  reason: "Non-empty concrete reason."
```

### gate_events

```yaml
gate_events:
  - id: E001
    gate: inception_approval
    action: approve  # approve|continue|invalidate|block|resume|validate|complete|supersede
    actor: implementer
    timestamp: "2026-09-09T12:00:00Z"
    reason: "…"
    # supersedes: E000  # optional
```

IDs monotonic (`E001`, `E002`, …). Free-form Markdown outside YAML is
non-authoritative for validators.

Privacy: no secrets, tokens, cookies, full transcripts, hidden reasoning, or
default email. Actor = role + optional display name only.

## T1 Lite

Location: `tasks/{host}/todo.md` section `## AIDLC` (one YAML fence).
No `tasks/{host}/aidlc/` directory.

Minimal valid shape:

```yaml
aidlc_schema_version: 1
mode: lite
run_status: active
task_type: docs
field: brownfield
current_stage: inception
risk: low
next_gate: inception_approval
operation: not_applicable
operation_reason: "Local docs/tooling; no release/deploy."
extensions:
  user_story: { status: skipped, reason: "No user-visible capability." }
  architecture: { status: skipped, reason: "No boundary/DI/schema change." }
  testing: { status: selected, reason: "Doc/harness proof required." }
  security: { status: skipped, reason: "No auth/secret/PII boundary." }
  resilience: { status: skipped, reason: "No async/offline change." }
  ui_platform: { status: skipped, reason: "No UI/native change." }
  operations: { status: skipped, reason: "No deploy/release." }
  documentation: { status: selected, reason: "Docs are the deliverable." }
  property_based_testing: { status: skipped, reason: "Deterministic checks suffice." }
gate_events: []
```

Optional lists: `material_questions`, `deferred_units`,
`documentation_reconciliation`.

## T2 full bundle

Path: `tasks/{host}/aidlc/{run-id}/` with `run-id` = `YYYYMMDD-{kebab-slug}`.

```text
aidlc-state.md
questions.md
audit.md
artifacts.md
```

Tracker pointer YAML must include `mode: full`, `run_id`, `run_status`,
`current_stage`.

- questions (markdown): `Q001`… append-only; corrections reference superseded id
- audit (markdown): same event fields as `gate_events` (+ `create` / `revise`);
  monotonic ids
- artifacts (markdown): pointers only; never copy owner-doc prose

## Scaffold CLI

```text
tool/scaffold_aidlc_run.sh \
  --host codex|cursor \
  --mode lite|full \
  [--slug KEBAB | --run-id YYYYMMDD-KEBAB] \
  [--replace-active] \
  [--dry-run | --apply]
```

Default `--mode lite`. Writes require `--apply`. Full requires `--slug` or
`--run-id`. `--replace-active` supersedes the prior active run before write.

## Rule IDs

Findings: `path:line:rule-id:message`.

| ID | Meaning |
| --- | --- |
| AIDLC001 | Missing schema version |
| AIDLC002 | Unknown enum value |
| AIDLC003 | Unknown risk in construction or while complete |
| AIDLC004 | Extension missing status/reason or incomplete key set |
| AIDLC005 | Approve without later continue for required gate |
| AIDLC006 | Continue without prior approve for same gate |
| AIDLC007 | Scope/revise without invalidate of downstream approvals |
| AIDLC008 | Complete without proof pointer / validation event |
| AIDLC009 | Operation without authority / missing not_applicable reason |
| AIDLC010 | Full mode missing bundle files |
| AIDLC011 | Non-monotonic or duplicate event ids |
| AIDLC012 | More than one active run per host |
| AIDLC013 | Blocked missing blocker fields |
| AIDLC014 | gate_events entry missing required fields |

## Active-run rule

Exactly one `run_status: active` per host. `blocked` is not active.
`complete` and `superseded` are terminal.
