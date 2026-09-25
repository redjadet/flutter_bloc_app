# Documentation index

Source-of-truth docs for Flutter BLoC app.

**Outsider 15‑min path:** [`architecture_tour.md`](architecture_tour.md)
→ [`ai/human_ai_collaboration.md`](ai/human_ai_collaboration.md)
→ [`platforms/README.md`](platforms/README.md) (matrices only).

## Start here

Pick the current task below; full catalogs live under **Core docs** and
**Browse by folder**. Thin hubs (link-only; edit targets, not hubs):
[`architecture.md`](architecture.md), [`testing.md`](testing.md),
[`engineering-decisions.md`](engineering-decisions.md),
[`ai-workflow.md`](ai-workflow.md).

| Goal | Open |
| --- | --- |
| First run / onboarding | [`new_developer_guide.md`](new_developer_guide.md) |
| Toolchain pins | [`toolchain_versions.env`](toolchain_versions.env), [`tech_stack.md`](tech_stack.md) |
| Architecture map | [`architecture.md`](architecture.md) → [`clean_architecture.md`](clean_architecture.md) |
| Add or change a feature | [`feature_implementation_guide.md`](feature_implementation_guide.md), [`architecture/reference_features.md`](architecture/reference_features.md) |
| Find implementation ownership | [`CODEMAP.md`](../CODEMAP.md) |
| Develop critical human engineering skills | [`engineering/critical_human_skills.md`](engineering/critical_human_skills.md) — judgment, restraint, and least-surface delivery when agents make typing cheap |
| Review a change | [`review/code_review_playbook.md`](review/code_review_playbook.md) |
| Validation + tests | [`testing.md`](testing.md), [`validation_scripts.md`](validation_scripts.md) |
| Agent harness | [`AGENTS.md`](../AGENTS.md) → [`ai/context_loading.md`](ai/context_loading.md); AIDLC [`ai/aidlc_workflow.md`](ai/aidlc_workflow.md); overview [`ai-workflow.md`](ai-workflow.md) |
| Human–AI collaboration map | [`ai/human_ai_collaboration.md`](ai/human_ai_collaboration.md) |
| Scope / Archive | [`scope_register.md`](scope_register.md), [`feature_overview.md`](feature_overview.md) |
| Native platforms teaching pack | [`platforms/README.md`](platforms/README.md) |
| Choose high-value AI-agent work | [`ai/best_areas_for_ai_agents.md`](ai/best_areas_for_ai_agents.md) |
| Configure integrations safely | [`security_and_secrets.md`](security_and_secrets.md), [`integrations/README.md`](integrations/README.md) |
| Portfolio walk | [`interview_showcase.md`](interview_showcase.md) |
| ≤15 min architecture tour | [`architecture_tour.md`](architecture_tour.md) |
| Flutter fundamentals + production Q&A | [`engineering/flutter_fundamentals_and_production_practices.md`](engineering/flutter_fundamentals_and_production_practices.md) — widgets/state, offline, perf, structure, crash triage with this-repo stories |

## Browse by folder

Root `docs/` contains repository-wide entry hubs and heavily referenced canon.
Focused guidance belongs in an owner folder; do not add new leaf docs at the
root when an existing category applies.

| Category | Owns |
| --- | --- |
| [architecture/](architecture/README.md) | Layering, feature shape, boundaries, rendering contracts |
| [engineering/](engineering/README.md) | Validation, quality controls, operational maintenance |
| [features/](features/README.md) | Feature-specific contracts and demo guides |
| [integrations/](integrations/README.md) | External-service setup, adapters, comparisons |
| [security/](security/README.md) | Privacy, security hardening, certificate guidance |
| [testing/](testing/README.md) | Test strategy, matrices, widget-test guidance |
| [performance/](performance/README.md) | Profiling, memory, performance improvement evidence |
| [review/](review/README.md) | Architecture, BLoC, security, and performance review checklists |
| [ai/](ai/README.md) | Coding-agent operations and governance |
| [contributing/](contributing/README.md) | Contributor guide, FAQ, PR checklist |
| [offline_first/](offline_first/README.md) | Local-first storage, conflict, and sync guidance |
| [platforms/](platforms/README.md) | Native capability/fidelity matrices; iOS/Android/interop teaching |
| [validation_scripts/](validation_scripts/README.md) | Validation catalog, procedures, and targeted guides |
| [plans/](plans/README.md) / [changes/](changes/README.md) / [audits/](audits/README.md) | Local (gitignored) working plans + shipped changes + historical audits |

## Core docs (by concern)

Folder READMEs under **Browse by folder** own the catalogs. Root highlights only
(do not duplicate long lists here):

### Case studies

- [`case_studies/README.md`](case_studies/README.md) — product briefs; dentists brief → Case Study Demo

### Architecture and design

- [`tech_stack.md`](tech_stack.md) · [`../DESIGN.md`](../DESIGN.md) · [`clean_architecture.md`](clean_architecture.md)
- [`bloc_standards.md`](bloc_standards.md) · [`architecture/feature_structure_contract.md`](architecture/feature_structure_contract.md)
- [`architecture/reference_features.md`](architecture/reference_features.md) · [`architecture/reduce_surprise_patterns.md`](architecture/reduce_surprise_patterns.md)
- [`feature_overview.md`](feature_overview.md) · [`design_system.md`](design_system.md) · [`adr/README.md`](adr/README.md)
- Layout contract: [`architecture/flutter_layout_constraints.md`](architecture/flutter_layout_constraints.md)

### Workflow and quality

- [`new_developer_guide.md`](new_developer_guide.md) · [`quick_start.md`](quick_start.md)
- [`agent_knowledge_base.md`](agent_knowledge_base.md) · [`agents_quick_reference.md`](agents_quick_reference.md)
- [`validation_scripts.md`](validation_scripts.md) · [`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md)
- [`testing_overview.md`](testing_overview.md) · [`review/code_review_playbook.md`](review/code_review_playbook.md)
- [`CODE_QUALITY.md`](CODE_QUALITY.md) · [`engineering/engineering_quality_scorecard.md`](engineering/engineering_quality_scorecard.md)
- [`ai/harness_scorecard.md`](ai/harness_scorecard.md) · [`ai/ai_failure_risks.md`](ai/ai_failure_risks.md)
- Performance: [`performance/finding_jank_cause.md`](performance/finding_jank_cause.md) (`bash tool/triage_jank.sh`)
- Integration: [`engineering/integration_test_policy.md`](engineering/integration_test_policy.md), [`engineering/integration_runner_contract.md`](engineering/integration_runner_contract.md)

### Offline-first and local storage

- [`offline_first/adoption_guide.md`](offline_first/adoption_guide.md) · [`offline_first/invariants.md`](offline_first/invariants.md)
- [`offline_first/hive_schema_migrations.md`](offline_first/hive_schema_migrations.md) · [`offline_first/dont_overwrite_guide.md`](offline_first/dont_overwrite_guide.md)

### Setup, secrets, and integrations

- [`security_and_secrets.md`](security_and_secrets.md) · [`SECURITY.md`](SECURITY.md) · [`authentication.md`](authentication.md)
- [`integrations/README.md`](integrations/README.md) · [`integrations/firebase_setup.md`](integrations/firebase_setup.md)
- [`integrations/render_fastapi_chat_demo.md`](integrations/render_fastapi_chat_demo.md) · [`integrations/render_chat_ops.md`](integrations/render_chat_ops.md)

### Feature walkthroughs and demos

See [`features/README.md`](features/README.md) and [`feature_overview.md`](feature_overview.md).

### Release and distribution

- [`deployment.md`](deployment.md) · [`../fastlane/README.md`](../fastlane/README.md)
- Env templates: [`.env.example`](../.env.example), [`docs/envrc.example`](envrc.example)

## Historical context (not source of truth)

- [`PLAN.md`](../PLAN.md)
- [`audits/README.md`](audits/README.md)
- [`changes/README.md`](changes/README.md)
