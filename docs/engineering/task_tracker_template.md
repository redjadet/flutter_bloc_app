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

## Validation command

List the *smallest honest* validation command(s) you actually ran (or will run before reporting):

- `./bin/checklist-fast`
- `./bin/router_feature_validate`
- `./bin/checklist`

If no command is required, state why (rare).

## Evidence/result

What proved it worked? Provide the key outputs (pass/fail) and any important notes. (Maps to **Verification**.)

- `./bin/checklist-fast`: PASS
- Residual risk: <what remains, if any>
