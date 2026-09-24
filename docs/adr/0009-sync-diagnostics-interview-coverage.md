# ADR 0009: Sync Diagnostics Interview Coverage

| Field | Value |
| --- | --- |
| Status | Accepted |
| Date | 2026-09-24 |
| Scope | Settings sync diagnostics vs automated PR-smoke |
| Source docs | [ADR 0005](0005-interview-showcase-scope.md), [`interview_showcase.md`](../interview_showcase.md) §3, [`sync_diagnostics_section.dart`](../../apps/mobile/lib/features/settings/presentation/widgets/sync_diagnostics_section.dart) |

## Context

Interview spine step 4 is **Settings → Sync diagnostics** (manual). Automated
PR-smoke does **not** cover that surface. Phase 3 asked whether to add fake
PR-smoke, a real scripted proof, or keep documenting the gap.

## Decision Drivers

- Do not invent green PR-smoke that does not exercise sync honesty.
- Keep offline-first merge guards (`tool/check_offline_first_remote_merge.sh`)
  as the automated honesty proof.
- Preserve ADR 0005 manual demo for diagnostics UI.

## Decision

**Document the gap; do not add fake PR-smoke for sync diagnostics.**

| Proof | Role |
| --- | --- |
| Manual Settings sync diagnostics | Interview spine visibility (queue/flush) |
| `tool/check_offline_first_remote_merge.sh` | Automated stale-sync honesty |
| Optional future | Real PR-smoke **or** script only when interview need + human trigger |

## Alternatives considered

| Option | Why not |
| --- | --- |
| Fake PR-smoke asserting “diagnostics visible” only | Theater; no sync honesty |
| Expand PR-smoke now | Scope creep without product/interview trigger |

## Consequences

### Benefits

- Honest automation boundary; spine stays demoable.
- Offline-first merge guards remain the automated honesty proof.

### Costs

- Interviewers must be told diagnostics UI is manual (not PR-smoke covered).

## Review triggers

- Human requests scripted diagnostics proof for interviews.
- PR-smoke gains a real sync-flush assertion with fixture data.

## Verification

- [`interview_showcase.md`](../interview_showcase.md) §3 still marks sync
  diagnostics as live/manual.
- No new PR-smoke claiming diagnostics coverage without this ADR supersession.
