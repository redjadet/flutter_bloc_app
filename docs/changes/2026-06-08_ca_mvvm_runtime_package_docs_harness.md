# CA skeleton + runtime/package-docs harness

## Why

Agents were guessing from static analysis or training data for active debug
bugs and unfamiliar pub APIs. Architecture docs did not state clearly that
**Clean Architecture** is the feature skeleton and **MVVM** applies only in
presentation (Cubit/BLoC as ViewModel).

## What changed

- **Runtime errors:** [`agent_kb/devtools_runtime_errors.md`](../agent_kb/devtools_runtime_errors.md),
  `script/mcp_runtime_errors.js`, `tool/check_runtime_errors.sh`, Cursor
  `/runtime-errors` command; wired through [`AGENTS.md`](../../AGENTS.md), skill routing, risk
  register, harness fixtures.
- **Package docs MCP:** [`agent_kb/package_docs_mcp.md`](../agent_kb/package_docs_mcp.md),
  Cursor `/package-docs` command; `RISK-STALE-API` pre-flight.
- **Architecture policy:** CA skeleton + presentation-only MVVM in
  [`clean_architecture.md`](../clean_architecture.md),
  [`architecture/feature_structure_contract.md`](../architecture/feature_structure_contract.md),
  host skills (`agents-canonical-rules-architecture`, `agents-feature-delivery`,
  `agents-common-pitfalls`), [`review/architecture_checklist.md`](../review/architecture_checklist.md),
  [`agent_project_context.md`](../agent_project_context.md).

## Proof

```bash
bash tool/check_runtime_errors.sh --self-test
bash tool/check_agent_knowledge_base.sh
bash tool/check_ai_failure_risk_register.sh
bash tool/check_clean_architecture_imports.sh
bash tool/run_harness_fixtures.sh
bash tool/validate_validation_docs.sh
./tool/sync_agent_assets.sh --apply
```

## Not in scope

- `check_runtime_errors.sh` in `./bin/checklist` (optional when no debug session).
- Migrating legacy root-level cubits to `presentation/cubit/`.

## Follow-up (same session)

- **Supported platforms policy:** iOS, Android, Web, Desktop (macOS) in
  [`tech_stack.md`](../tech_stack.md), [`AGENTS.md`](../../AGENTS.md), `RISK-PLATFORM-SCOPE`,
  `flutter-cross-platform-modern`, `agents-principles-baseline`,
  `agents-common-pitfalls`.
- **Reusable widgets for agents:** preview + widget test + design iteration
  contract in [`design_system.md`](../design_system.md),
  [`feature_structure_contract.md`](../architecture/feature_structure_contract.md),
  [`widget_test_playbook.md`](../testing/widget_test_playbook.md),
  `agents-canonical-rules-presentation`, `agents-feature-delivery`,
  `RISK-UI-REGRESSION` prevention row.
- **Responsive layout policy:** avoid fixed sizes; `LayoutBuilder` /
  `MediaQuery` when suitable — [`design_system.md`](../design_system.md),
  [`ui_ux_responsive_review.md`](../review/ui_ux_responsive_review.md),
  `flutter-cross-platform-modern`, `agents-canonical-rules-presentation`.
- **Cross-platform form factors:** mobile, tablet, web, desktop widget policy —
  [`design_system.md`](../design_system.md) § Cross-platform form factors,
  [`ui_ux_responsive_review.md`](../review/ui_ux_responsive_review.md),
  `RISK-PLATFORM-SCOPE` prevention update.
