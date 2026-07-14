# Complex feature README template

Use only for platform, backend, async-heavy, or multi-integration features
where [`feature_overview.md`](../feature_overview.md) cannot hold the wiring
details. Keep ≤40 lines.

```markdown
# <Feature name>

## Purpose
<one sentence user-visible outcome>

## Entry points
- Route: `<AppRoutes...>`
- Barrel: `apps/mobile/lib/features/<name>/`
- DI: `apps/mobile/lib/app/composition/features/<registrar>.dart`

## Integrations
- Platform / backend / offline-first notes (bullets)

## Tests
- Primary: `apps/mobile/test/features/<name>/...`
- Proof: `flutter test apps/mobile/test/features/<name>/`

## Gotchas
- <non-obvious constraint agents must not miss>
```

Catalog: mark `complexity: high` in [`ai/reports/feature_map.md`](../../ai/reports/feature_map.md).

Existing co-located READMEs: `native_platform_showcase`, `library_demo`, `iot`.
