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
- For PR triage before this lane, use `upgrade-pr-triage-validate`; keep merge/close/fix
  actions bounded and never merge on unknown checks/mergeability.

Useful env:

- `SKIP_PUB_UPGRADE=1|true|yes|on` skips major-version upgrade and runs `pub get`.
- `SKIP_PUB_UPGRADE=0|false|no|off` runs major-version upgrade.
- `SYNC_AGENT_ASSETS=auto|apply|skip|1|0|true|false|yes|no` controls host asset sync.
