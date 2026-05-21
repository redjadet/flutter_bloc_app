# Prompt patterns

Reusable agent instructions for this repo.

## Implement feature fix

```text
Role: Implementer.
Load ai/CONTEXT_MAP.md for <feature>.
Follow docs/feature_implementation_guide.md.
RED test first. Smallest diff. Run narrowest validation from docs/agents_quick_reference.md.
```

## Doc-only operability refresh

```text
Role: Documenter.
No lib/ or test/ changes.
Update ai/reports from tool/modular_metrics.sh.
git add -f docs/audits/ai_*.md if audits change.
```

## Architecture refactor

```text
Role: Planner + Implementer.
Cite ARCH-### from docs/audits/ai_architecture_audit.md.
Complete FEATURE_TEMPLATE brief.
Tests required before REFACTOR.
```

## Review PR

```text
Role: Reviewer.
Use docs/ai_code_review_protocol.md.
Check cross-feature imports and AGENTS line count if AGENTS touched.
```

## Debug failing test

```text
Role: Implementer.
Reproduce with single test file.
No production behavior change without product confirmation.
```

## Onboarding

```text
Read AGENTS.md → docs/agent_knowledge_base.md → CODEMAP.md → docs/feature_overview.md.
```
