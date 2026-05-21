# Feature template — brief + AI alignment

Use before non-trivial feature work or cross-layer refactors. Run `bash tool/check_feature_brief_linked.sh` when `lib/features/` changes; add a `docs/changes/*.md` note or set `SKIP_FEATURE_BRIEF=1` for trivial fixes.

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

### Tests (RED first)
- [ ] unit: ...
- [ ] widget: ...
- [ ] integration: ...

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
- Test update included or N/A with reason

Still run narrowest validation script.

## Related

- Delivery: [`docs/feature_implementation_guide.md`](../feature_implementation_guide.md)
- Contracts: [`CONTRACTS.md`](../../CONTRACTS.md)
- Plan: [`PLAN.md`](../../PLAN.md)
