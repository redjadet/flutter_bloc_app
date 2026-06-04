# Agent host maintenance automation (`agent-maintain`)

## What changed

- New unified entry: `./bin/agent-maintain` → `tool/agent_maintain.sh` (presets:
  `preflight`, scope-based `closeout` / `auto`, `docs-sync`, `after-host-edit`,
  `routine`, `host-full`, plus low-level forwards).
- Policy canon: [`docs/agent_kb/host_maintenance_automation.md`](../agent_kb/host_maintenance_automation.md)
  (when agents run commands, drift strict vs warn, doc-closeout scope; see
  [Not changed by design](../agent_kb/host_maintenance_automation.md#not-changed-by-design)).
- `tool/fix_validation_docs.sh` refreshes checklist index block and catalog/overview
  count claims; wired into `docs-sync` / `closeout`.
- Contract tests in `tool/check_checklist_cli_contract.sh` (PLAN_ONLY scope plans;
  empty scope must not plan `after-host-edit`).
- Cursor template: `/agent-maintain` command; host rules/skills point agents at
  `closeout` before finish.

## Why

Agents were documenting host upkeep (`sync`, globals, validation doc sync) but not
running it reliably. One router reduces ad-hoc shell chains, gates host mutation
(`--apply`, scope), and keeps CI safe (no live `sync --apply` in contract smoke).

## Verification

Docs/tooling only. Proof lane:

```bash
bash tool/check_checklist_cli_contract.sh
bash tool/check_agent_knowledge_base.sh
bash tool/validate_validation_docs.sh
bash tool/run_harness_fixtures.sh
./bin/agent-maintain help
```

## Rollback

Remove `bin/agent-maintain`, `tool/agent_maintain.sh`, and
[`docs/agent_kb/host_maintenance_automation.md`](../agent_kb/host_maintenance_automation.md);
revert AGENTS/quick-reference/delivery-workflow anchors; drop contract-test blocks and
`fix_validation_docs` count sync if unused.
