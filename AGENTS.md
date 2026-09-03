# AGENTS - Project Entry Map

Main entry point for every AI agent working in this repository. Map only;
linked owner docs contain all rules, commands, and details.

## Start

1. Follow the [`context ladder`](docs/ai/context_loading.md) and [`task routing`](docs/ai/skill_routing.md).
2. Read [`project context`](docs/agent_project_context.md) and [`safety contracts`](docs/agent_kb/agent_safety_contracts.md) for non-trivial work.
3. If ownership is unclear, use the [`documentation index`](docs/README.md) and [`code map`](CODEMAP.md).
4. For T1/T2 coding, work through the [`operating manual`](docs/ai/agent_operating_manual.md).

## Task Map

- Architecture: [`clean architecture`](docs/clean_architecture.md), [`feature contract`](docs/architecture/feature_structure_contract.md), [`reference features`](docs/architecture/reference_features.md), [`BLoC`](docs/bloc_standards.md).
- Product and UI: [`product brief`](DESIGN.md), [`design system`](docs/design_system.md), [`platform guidance`](docs/agent_project_context.md).
- Data and reliability: [`offline-first`](docs/offline_first/adoption_guide.md), [`reliability`](docs/reliability_error_handling_performance.md), [`observability`](docs/observability.md).
- Testing and quality: [`testing`](docs/testing_overview.md), [`validation routing`](docs/engineering/validation_routing_fast_vs_full.md), [`quick reference`](docs/agents_quick_reference.md), [`code quality`](docs/CODE_QUALITY.md), [`engineering scorecard`](docs/engineering/engineering_quality_scorecard.md).
- Review and delivery: [`review playbook`](docs/review/code_review_playbook.md), [`automated-change review`](docs/ai_code_review_protocol.md), [`version-control workflow`](docs/git_and_branching_strategy.md), [`changes`](docs/changes/README.md).
- Agent system: [`knowledge base`](docs/agent_knowledge_base.md), [`failure risks`](docs/ai/ai_failure_risks.md), [`harness scorecard`](docs/ai/harness_scorecard.md), [`harness maintenance`](docs/ai/harness_auto_maintenance.md), [`host notes`](docs/agent_host_notes.md).

## Finish

1. Select proof through [`validation routing`](docs/engineering/validation_routing_fast_vs_full.md) and [`quick reference`](docs/agents_quick_reference.md).
2. Review against [`safety contracts`](docs/agent_kb/agent_safety_contracts.md) and the [`review protocol`](docs/ai_code_review_protocol.md).
3. Report through the [`finish gate`](docs/agent_kb/legibility_and_finish_gate.md); maintain environments through [`host maintenance`](docs/agent_kb/host_maintenance_automation.md).
4. Verified reusable agent conclusion: update the [`owning documentation`](docs/agent_kb/operator_preferences_durable.md) or [`lessons`](tasks/lessons.md).
