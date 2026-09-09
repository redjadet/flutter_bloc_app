## Goal
Fixture goal.

## Write-set
- docs/example.md

## Risks
- fixture only

## Validation command
- bash tool/check_aidlc_artifacts.sh

## Evidence/result
- fixture

## AIDLC

```yaml
aidlc_schema_version: 1
mode: lite
run_status: active
task_type: docs
field: brownfield
current_stage: construction
risk: low
next_gate: construction_approval
operation: not_applicable
operation_reason: "Local docs."
material_change: true
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

gate_events:
  - id: E001
    gate: inception_approval
    action: approve
    actor: implementer
    timestamp: "2026-09-09T12:00:00Z"
    reason: "Approved."
  - id: E002
    gate: inception_approval
    action: continue
    actor: implementer
    timestamp: "2026-09-09T12:01:00Z"
    reason: "Continued."
  - id: E003
    gate: inception_approval
    action: revise
    actor: implementer
    timestamp: "2026-09-09T12:02:00Z"
    reason: "Scope widened."
```
