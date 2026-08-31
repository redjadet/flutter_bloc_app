# Feature: DI usage improvements (Settings analytics + GetIt guard)

## Problem

Settings analytics consent reached into GetIt from presentation, and
`check_direct_getit.sh` reported green while missing nested
`features/<name>/presentation/**` paths (broken `*/presentation/**` glob).

## Scope

- In: explicit constructor DI for Settings analytics; guard repair + self-test;
  composition-root resolve smoke test; architecture/change docs.
- Out: injectable/Riverpod/BlocSignal migration; `BackendAvailability` singleton
  flip; broad GetIt sweeps outside Settings presentation.

## Layers touched

- [x] presentation (Settings)
- [x] DI (composition resolve into `CoreRouteFactory`)
- [x] routes
- [ ] domain
- [ ] data
- [ ] l10n

## Contracts

- Flow: `resolveCoreRouteFactory` → `CoreRouteFactory` → `SettingsPage` →
  `_SettingsView` → `AnalyticsConsentSection`
- Required: `AnalyticsConsentRepository analyticsConsentRepository`,
  `ProductAnalytics productAnalytics`
- No `getIt` in presentation widgets

## Tests (executable contract)

### Behaviour (widget)

- [x] Toggle consent → save + analytics enabled
- [x] External stream update → switch syncs
- [x] Failed save → switch rolls back; analytics unchanged
- [x] Dispose cancels consent stream subscription
- [x] Toggle disabled while save pending (no overlapping mutations)
- [x] Stale in-flight save ignored after repository replacement
- [x] Repository replacement rebinds stream + reloads
- [x] SettingsPage forwards exact analytics instances to section
- Files:
  `test/features/settings/presentation/widgets/analytics_consent_section_test.dart`,
  `test/settings_page_test.dart`, `test/responsive_layout_test.dart`

### Composition

- [x] After `configureDependencies()`, resolve app scope + all typed route
  factories without throw
- File: `test/app/composition/injector_test.dart`

### Tooling

- [x] `check_direct_getit.sh --self-test` flags `getIt<` and `getIt.`; ignores
  comment-only
- [x] Production scan uses `**/presentation/**` under `apps/mobile`

## Risks

- Presentation GetIt regress → guard + checklist
- Lazy demo factory resolve cost in smoke test → already used by router tests

## Rollback

Revert this change note’s write-set; restore optional GetIt fallback only if
product explicitly requires optional analytics (prefer null-object at factory).

## Proof commands

```bash
./bin/format
bash tool/check_direct_getit.sh --self-test
bash tool/check_direct_getit.sh
cd apps/mobile && flutter test \
  test/features/settings/presentation/widgets/analytics_consent_section_test.dart \
  test/settings_page_test.dart \
  test/responsive_layout_test.dart \
  test/app/composition/injector_test.dart
bash tool/check_feature_brief_linked.sh
bash tool/check_clean_architecture_imports.sh
bash tool/check_solid_presentation_data_imports.sh
./bin/router_feature_validate
CHECKLIST_ALLOW_REUSE=0 ./bin/checklist
```
