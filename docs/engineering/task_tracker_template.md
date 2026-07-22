# Task tracker template (canonical)

Use this template for non-trivial work trackers under `tasks/*/todo.md`.

Matches planning response shape in [`legibility_and_finish_gate.md`](../agent_kb/legibility_and_finish_gate.md) § Planning response shape.

Keep it short. Enforce clarity (write-set + proof), not style.

## Goal

One sentence. What outcome is being delivered? (Maps to **Understanding**.)

## Write-set

Explicit files/dirs you intend to change. Update as scope changes. (Maps to **Files to modify**.)

- `path/to/file.dart`
- `docs/<some_doc>.md`

## Plan

3–5 implementation bullets. (Maps to **Plan**.)

- Step one
- Step two

## Risks

Bullets of concrete risk / edge cases / regressions to watch.

- async lifecycle / mounted / isClosed
- routing reachability / guards
- offline-first merge ordering
- auth/retry/replay safety

## Accountability

- Detection signal: observable evidence that this change is wrong
- Blast radius: affected users, systems, or data if it is wrong
- Acceptance verdict: approve / revise / block, with named decision owner
- Scope discovered during execution: `None` or findings kept inside this write-set
- Deferred findings: `None` or separately owned follow-up

## Validation command

List the *smallest honest* validation command(s) you actually ran (or will run before reporting):

- `./bin/checklist-fast`
- `./bin/router_feature_validate`
- `./bin/checklist`

If no command is required, state why (rare).

## depends_on

- [ ] task/issue/doc placeholder

## blocks

- downstream work blocked by this task

## merge_order

- e.g. T1 before T2

## rollback

- revert plan or feature flag steps

## proof_commands

- `./bin/checklist-fast`

### Example (filled)

```markdown
## depends_on
- [ ] docs/validation_scripts/ai_snapshot_freshness.md (T1 refresh)

## blocks
- T2 snapshot freshness gate wiring

## merge_order
- T1 → T2 → T3

## rollback
- Revert ai/ snapshot edits; re-run refresh from prior commit

## proof_commands
- `bash tool/check_ai_snapshot_freshness.sh`
- `./bin/checklist-fast`
```

## Evidence/result

What proved it worked? Provide the key outputs (pass/fail) and any important notes. (Maps to **Verification**.)

- `./bin/checklist-fast`: PASS
- Residual risk: note what remains, if any
