# Prompt patterns

Short prompts. Fill placeholders; keep validation explicit.

## Implement feature fix

```text
Role: Implementer. Feature: <feature>.
Load ai/CONTEXT_MAP.md. Follow docs/feature_implementation_guide.md.
RED test first. Smallest diff. Run narrowest validation.
```

## Doc-only operability refresh

```text
Role: Documenter. No lib/ or test/ changes.
Update ai/reports from tool/modular_metrics.sh.
If audits change: git add -f docs/audits/ai_*.md.
```

## Architecture refactor

```text
Role: Planner + Implementer. Cite ARCH-###.
Complete docs/plans/FEATURE_TEMPLATE.md.
RED -> GREEN -> REFACTOR.
```

## Review PR

```text
Role: Reviewer. Use docs/ai_code_review_protocol.md.
Check cross-feature imports. If AGENTS touched, verify line count.
```

## Debug failing test

```text
Role: Implementer. Reproduce with single test file.
No production behavior change without product confirmation.
```

## Onboarding

```text
Read AGENTS.md → docs/agent_knowledge_base.md → CODEMAP.md → docs/feature_overview.md.
```
