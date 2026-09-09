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
current_stage: inception
risk: low
next_gate: inception_approval
operation: not_applicable
operation_reason: "Local docs."
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
```
