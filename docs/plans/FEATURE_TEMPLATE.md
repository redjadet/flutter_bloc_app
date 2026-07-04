# Feature template — brief + AI alignment

Use before non-trivial feature work or cross-layer refactors. Run `bash tool/check_feature_brief_linked.sh` when `apps/mobile/lib/features/` changes; add a `docs/changes/*.md` note or set `SKIP_FEATURE_BRIEF=1` for trivial fixes.

## Feature Brief (copy per feature)

```markdown
## Feature: <name>

### Problem
<user-visible outcome>

### Scope
- In: ...
- Out: ...

### Layers touched
- [ ] domain
- [ ] data
- [ ] presentation
- [ ] DI
- [ ] routes / l10n

### Contracts
- Repository: ...
- State: ...

### Tests (executable contract — RED first)

Write these **before or with** the first implementation commit in this change series. A test-only follow-up needs a one-line reason in `docs/changes/`.

#### Behaviour (widget and/or cubit)
- [ ] Scenario: <user action> → <observable outcome>
- [ ] Files: `test/...`

#### State (widget — seed cubit/state)
- [ ] Scenario: <loading | success | error | empty> → <UI assertion>
- [ ] Files: `test/...`

#### Unit (domain / data)
- [ ] Scenario: <pure logic or repository rule>
- [ ] Files: `test/...`

#### Integration (only if cross-screen / journey)
- [ ] Journey: <J1–J5 from integration_journey_map> — tier: <smoke | standard>
- [ ] Omit if single-screen; justify in Risks if skipping after prior production bug

#### Proof command
- [ ] `flutter test <paths>` (and `./bin/integration_tests <target>` if integration row checked)

**Examples in repo:** `test/features/auth/presentation/pages/register_page_test.dart` (validation + submit); `test/features/auth/presentation/pages/logged_out_page_test.dart` (stateful shell); `test/features/calculator/presentation/pages/calculator_payment_page_test.dart` (rendering).

### Docs
- [ ] docs/feature_overview.md
- [ ] owning doc under docs/

### Risks
...
```

## AI alignment checklist

Before implementation:

1. Read [`ai/CONTEXT_MAP.md`](../../ai/CONTEXT_MAP.md) (or add a row in [`ai/reports/feature_map.md`](../../ai/reports/feature_map.md)).
2. Confirm no new cross-feature domain imports ([`docs/modularity.md`](../modularity.md)).
3. Link offline-first guide if syncing ([`docs/offline_first/adoption_guide.md`](../offline_first/adoption_guide.md)).
4. Pick validation lane ([`docs/agents_quick_reference.md`](../agents_quick_reference.md)).
5. If ARCH-### applies, cite ID from [`docs/audits/ai_architecture_audit.md`](../audits/ai_architecture_audit.md).

## Trivial-fix quick path

Skip full brief when **all** true:

- ≤2 files, one layer
- No route/DI/schema change
- Tests row filled: at least one named `test/...` path **or** `Tests: N/A — <reason>` (cannot silently skip all test rows)

Still run narrowest validation script.

## Related

- Delivery: [`docs/feature_implementation_guide.md`](../feature_implementation_guide.md)
- Testing policy: [`docs/testing_overview.md`](../testing_overview.md) § Feature-defined testing
- Widget how-to: [`docs/testing/widget_test_playbook.md`](../testing/widget_test_playbook.md)
- Contracts: [`CONTRACTS.md`](../../CONTRACTS.md)
- Plan: [`PLAN.md`](../../PLAN.md)
