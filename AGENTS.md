# AGENTS - Project Entry Map

Main entry for coding agents (tool-agnostic). Map only; owners hold detail.

## Start

1. [`context ladder`](docs/ai/context_loading.md) + [`task routing`](docs/ai/skill_routing.md).
2. Non-trivial: [`project context`](docs/agent_project_context.md) + [`safety contracts`](docs/agent_kb/agent_safety_contracts.md).
3. Unclear ownership → [`docs/README.md`](docs/README.md), [`CODEMAP.md`](CODEMAP.md).
4. T1/T2 coding → [`operating manual`](docs/ai/agent_operating_manual.md); intent→spec→plan→review → [`AI-native SDLC`](docs/ai-sdlc/README.md).

## Prove work (commands)

Use [`agents_quick_reference.md`](docs/agents_quick_reference.md) and
[`docs/ai-sdlc/gates.md`](docs/ai-sdlc/gates.md). Typical Flutter lanes:
`flutter analyze`, `flutter test <paths>` (from `apps/mobile`), format via the
repo format wrapper, docs gardening / integration-preflight / full checklist via
the validation chooser. Prefer the narrowest honest lane in
[`validation routing`](docs/engineering/validation_routing_fast_vs_full.md).

## Conventions + pitfalls

- BLoC / Clean Architecture: [`bloc_standards`](docs/bloc_standards.md), [`feature contract`](docs/architecture/feature_structure_contract.md), [`clean_architecture`](docs/clean_architecture.md).
- Offline / native / cancel: [`offline-first`](docs/offline_first/adoption_guide.md), platform notes in [`project context`](docs/agent_project_context.md), [`cancellation`](docs/engineering/cancellation_and_cache.md).
- Theme tokens: [`DESIGN.md`](DESIGN.md), [`design_system`](docs/design_system.md). Skills: [`docs/ai-sdlc/skills/`](docs/ai-sdlc/skills/README.md).
- Pitfalls before edit: [`ai_failure_risks`](docs/ai/ai_failure_risks.md) Pre-Flight.

## Progressive prompting

Sequence **small** prompts from **green** code (one verifiable slice per turn; land before expanding). Avoid one-shot whole-feature asks — [`progressive-prompting`](docs/ai-sdlc/skills/progressive-prompting.md), [`plan template`](docs/ai-sdlc/templates/plan.md).

## Task Map

- Architecture: clean architecture, feature contract, [`reference features`](docs/architecture/reference_features.md), BLoC.
- Product/UI: [`DESIGN.md`](DESIGN.md), design system, project context.
- Data/reliability: offline-first, [`reliability`](docs/reliability_error_handling_performance.md), [`observability`](docs/observability.md), [`jank triage`](docs/performance/finding_jank_cause.md).
- Testing/quality: [`testing`](docs/testing_overview.md), validation routing, quick reference, [`CODE_QUALITY`](docs/CODE_QUALITY.md), [`engineering scorecard`](docs/engineering/engineering_quality_scorecard.md).
- Review/delivery: [`review playbook`](docs/review/code_review_playbook.md), [`ai_code_review_protocol`](docs/ai_code_review_protocol.md), [`git/branching`](docs/git_and_branching_strategy.md), [`changes`](docs/changes/README.md).
- Agent system: [`knowledge base`](docs/agent_knowledge_base.md), [`AIDLC`](docs/ai/aidlc_workflow.md), [`AI-SDLC kit`](docs/ai-sdlc/README.md), failure risks, [`harness`](docs/ai/harness_scorecard.md), [`harness maintenance`](docs/ai/harness_auto_maintenance.md), [`host notes`](docs/agent_host_notes.md), [`host maintenance`](docs/agent_kb/host_maintenance_automation.md).

## Finish (verify before done)

1. Satisfy the [`agent pre-complete gate`](docs/agent_kb/legibility_and_finish_gate.md#agent-pre-complete-gate-mandatory-before-done) (format + analyze + targeted tests).
2. Select proof via validation routing / quick reference; deterministic gates: [`docs/ai-sdlc/gates.md`](docs/ai-sdlc/gates.md).
3. Review against safety contracts and the review protocol.
4. Report through the [`finish gate`](docs/agent_kb/legibility_and_finish_gate.md).
5. Verified reusable agent conclusion → [`operator_preferences_durable`](docs/agent_kb/operator_preferences_durable.md) or [`tasks/lessons.md`](tasks/lessons.md).
