# Agent operating manual integration (2026-06-25)

## Summary

Integrated the Project AI Operating Manual into the agent harness as a thin
router plus shard updates. Quality-over-volume discipline, pre-coding checklist,
response tiers, and verification mapping now have canonical owners.

## What changed

- **Canonical router:** [`docs/ai/agent_operating_manual.md`](../ai/agent_operating_manual.md)
- **Finish gate:** response tiers, planning/closeout shapes, definition of done in
  [`legibility_and_finish_gate.md`](../agent_kb/legibility_and_finish_gate.md)
- **Discovery:** context ladder step 2b, AGENTS Map, README indexes, skill routing
- **Mechanical:** `tool/check_agent_knowledge_base.sh` file/budget/needles
- **Host:** pointer-only echoes in delivery-workflow skill and Cursor rules

## Dedup decisions

- No second Validation Chooser table; verification mapping points to quick ref
- No verbatim source archive; router + changes note only
- Response tiers canonical in finish gate; one-line echo in router
- `## Report Shape` preserved; new sections additive only

## Verification mapping rationale

Manual lists raw `flutter analyze` / `flutter test`; repo canon uses
`./tool/analyze.sh`, `./bin/checklist-fast`, and matrix-driven focused tests.
Router maps manual CLI to repo wrappers.

## Locked decisions

- T0/T1/T2 response tiers; no coverage % in DoD
- Tracker `## Plan` recommended, not required by validate_task_trackers.sh
- Legibility doc 120-line budget enforced in check script
