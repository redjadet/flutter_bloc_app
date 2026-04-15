---
name: 8figures-ai-orchestration
overview: "Build a repeatable, AI-native engineering pipeline aligned to 8FIGURES’ “orchestrator era” expectations: parallel agent execution, strong UX judgment, deterministic verification, and continual learning."
todos:
  - id: canon-docs
    content: Create/refresh build canon + AI review protocol docs used by agents.
    status: pending
  - id: command-gates
    content: Standardize deterministic validation entrypoints (full checklist + targeted checks).
    status: pending
  - id: orchestration-template
    content: Create a reusable task template with lanes, acceptance criteria, owners, risks, and validation steps.
    status: pending
  - id: model-policy
    content: Write a short model selection policy and escalation rule tied to task risk.
    status: pending
  - id: continual-learning-loop
    content: Set up incremental continual-learning process to feed durable corrections back into canon/skills/checklists.
    status: pending
  - id: demo-run
    content: Run one end-to-end demo task using the pipeline and package evidence (spec, diffs, checklist output, learning delta).
    status: pending
isProject: false
---

# AI Orchestration Plan (8FIGURES-aligned)

## Goals

- Ship frontend/mobile features end-to-end with **parallel agent execution** while keeping **UX quality** and **correctness** high.
- Make AI usage **repeatable** (artifacts > memory), **auditable** (checklists/logs), and **cost-aware** (model selection policy).
- Prove “orchestrator era” maturity: spec → delegate → review → verify → learn.

## System artifacts (make agents reliable)

- **Build canon**: one short “how we build here” doc that pins:
  - architecture boundaries (presentation → domain ← data)
  - state mgmt conventions
  - routing/DI patterns
  - error/loading/empty UX requirements
  - performance and accessibility bar
- **Review protocol**: one doc/checklist for reviewing AI output (correctness, edge cases, UX states, logging, tests).
- **Command entrypoints**: a small set of deterministic commands/scripts:
  - full “delivery checklist” command
  - targeted checks (lint/analyze, unit tests, golden/visual checks, integration tests)
- **Task tracker**: single source of truth for non-trivial work (goal, acceptance criteria, slices, owners, risks, validation).

## Orchestration workflow (how work runs)

- **Slice work into lanes** (designed to parallelize):
  - UI/interaction + accessibility
  - state/domain changes
  - data/API contract + error mapping
  - routing/DI wiring
  - tests/guards + regression coverage
  - analytics/telemetry instrumentation
- **Parallel agents with bounded scope**:
  - Explore agent: map touchpoints + list files/symbols.
  - Implementation agents: each owns one lane and must stay inside its seam.
  - Review agent: adversarial edge-case pass (race conditions, lifecycle, offline, auth).
  - Validation agent: runs commands and reports failures with evidence.
- **Merge policy**:
  - accept only after manual diff review + checklist pass
  - avoid “drive-by” changes outside declared lanes

## Model selection policy (cost + reliability)

- **Fast model**: search/mapping, mechanical refactors, formatting, extraction, simple test edits.
- **Strong model**: multi-file changes, concurrency/lifecycle, offline-first merge logic, contract changes, tricky UI flows.
- **Escalation rule**: start fast; escalate only when uncertainty/risk rises; always end with deterministic validation.

## UX review + design fidelity loop (human bar)

- Require for any user-facing change:
  - loading/empty/error states
  - touch targets + platform-native interaction expectations
  - accessibility (labels, focus, contrast)
  - performance sanity (list rendering, rebuild hotspots)
- Add a “UX sign-off” step: screenshot/video or emulator walkthrough notes for changed flows.

## Verification strategy (prove, don’t claim)

- Define “done” as:
  - checklist green
  - targeted tests for changed surface
  - no new warnings/errors
  - acceptance criteria met
- For high-risk changes (routing/auth/offline sync): add a small regression test/guard.

## Continual learning (pipeline compounds)

- After each task:
  - incrementally scan transcripts/logs for **recurring** corrections
  - update only durable rules/skills/checklists
  - keep a small index so only new/changed sessions are processed
- Output: fewer repeated mistakes, consistent style under parallel agents, faster onboarding.

## Interview-ready demonstration (what to show Roman)

- Pick one real backlog-style task and run the loop:
  - 1-page spec with acceptance criteria + risks
  - 2–4 parallel agent lanes
  - manual review notes (what was rejected/why)
  - checklist output (commands + results)
  - a short “learning delta” (one durable rule/skill improvement)

## Metrics (so it’s not hand-wavy)

- Track per task:
  - lead time (spec → merged)
  - agent cost/time vs manual time saved
  - defect rate caught in review vs validation
  - number of repeated corrections trending down
