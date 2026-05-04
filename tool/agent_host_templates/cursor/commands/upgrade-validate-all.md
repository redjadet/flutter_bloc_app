---
name: upgrade-validate-all
description: Run repo’s full Flutter/tooling upgrade lane with preflight safety checks and clear stage reporting.
---

# upgrade-validate-all

Run repo’s canonical full upgrade + validation lane.

Heavyweight maintenance lane. May mutate workspace: upgrades, generated
artifacts, docs, agent assets.

Closed-loop: keep going end-to-end; ask only on blockers: `gh` auth, device
readiness, missing tools, dirty worktree without user opt-in.

Start here:

- Read `AGENTS.md`, then `docs/agents_quick_reference.md`.
- Prefer repo script as single execution path:

```bash
./bin/upgrade_validate_all
```

Safety:

- Don’t replace `./bin/upgrade_validate_all` with a hand-written sequence when script exists.
- Don’t clean, reset, stash, discard user changes, change git config, or publish anything.
- In CI/non-local environments, prefer host-asset dry-run unless explicitly opted into asset sync.
