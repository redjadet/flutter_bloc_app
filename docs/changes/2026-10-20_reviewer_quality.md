# Reviewer presentation, responsive sizing, and counter accessibility

## Problem and scope

The README's badge wall hid the app and its evidence. The demo hub opened with
an unrelated network image, equally emphasized navigation buttons with uneven
widths, and internal interview terminology in all six locales.
The counter ignored reduced-motion preferences, exposed outgoing animated values
to assistive technology, and allowed long values to wrap.
Rendered desktop review also found that ScreenUtil enlarged the shared content
and action-bar width caps and navigation icons. Existing layout tests omitted
the responsive shell, so they exercised fallback sizes instead.

Scope: README, Example/Counter presentation, and shared responsive size limits.
Repository, sync, routing, native bridges, and dependency contracts remain
outside this change.

## Behavior contract

- The README leads with the app, four review paths, and existing evidence links.
  All 44 badges remain visible in purpose-based groups, and all 33 captured
  screenshots appear inline in the root README with their captions and alt text.
- The demo hub's initial content works without an image request. Navigation uses
  aligned, full-width outlined buttons; existing routes and callbacks remain
  available.
- A counter change exposes one current numeric value to assistive technology,
  including during the visual transition. No English-only prefix is injected.
- Reduced motion disables the counter's value, status, and color transitions.
- Long numeric values remain on one visible line within the available width.
- With the real responsive shell on desktop, content stays within the 840 logical
  pixel cap, action bars within 900, and navigation icons at their breakpoint size.

## Tests and reproduced failures

The tests below were added and run against the original behavior before each
fix. All six failed, then passed with the implementation.

- [`counter_display_accessibility_test.dart`](../../apps/mobile/test/features/counter/presentation/widgets/counter_display_accessibility_test.dart):
  the outgoing value remained in semantics during a 7-to-8 transition; a
  15-digit value wrapped onto eight lines in a narrow, large-text layout; and
  reduced motion left a 220 ms animation enabled.
- [`responsive_shell_regression_test.dart`](../../apps/mobile/test/shared/responsive_shell_regression_test.dart):
  at a 1440 logical pixel viewport, the real responsive shell produced a
  1203.69 pixel content card, a 1440 pixel action bar, and an 88.62 pixel icon.
  The tests now enforce the existing content/bar caps and a proportionate icon.

Existing Example callback, disabled-action, localization, and responsive tests
also pass. No data/domain unit tests were added: behavior changes are confined
to presentation. Both new files are registered in the regression guard router.

The first full suite also found the loading-screen golden captured the old
width/icon behavior. Its phone and tablet images were inspected against the
rendered results, then regenerated with the existing golden test. Only those
two baselines changed; other counter baselines are preserved.

## Verification

| Lane | Command or surface | Result |
| --- | --- | --- |
| Localization | `flutter gen-l10n` from `apps/mobile` | Pass; generated outputs regenerated from ARB sources |
| Format | `./bin/format --changed` | Pass |
| Analyze | `./tool/analyze.sh --no-pub` | Pass; Flutter analysis, Mix lint, and file-length lint |
| Design system | `flutter analyze --no-pub` from `packages/design_system` | Pass |
| Focused tests | `flutter test --no-pub` for the two new files, counter chip/actions, responsive layout, Example page/body/therapy entry, and localization delegates/session message | Pass; 28 tests across ten files |
| Counter goldens | `flutter test --no-pub test/counter_page_golden_test.dart` | Pass; all eight tests, after inspecting and regenerating the two loading-state baselines |
| Web inspection | Example and counter widgets in a local fixture; mobile/desktop, English/Turkish/Arabic, dark mode, and 2x text | Pass; final hot reload succeeded and no runtime errors were reported |
| Full checklist | `./bin/checklist --no-reuse` | Pass; 85 static checks, 44 regression guard files, layout checks, 11 leak tests, and the full suite: 3,122 passed, one intentional SnackBar demo skip |
| Coverage | Full checklist's `tool/test_coverage.sh` and engineering scorecard gate | Pass; filtered line coverage 85.69% (20,625/24,070), app-shell coverage 79.88% (1,667/2,087); both scorecard floors met |
| Closeout | `./bin/agent-maintain closeout` | Pass; documentation gardening and scorecard checks, rerun after the README follow-up |
| README follow-up inventory | Compare badge markup against `HEAD`, gallery content against [`features/screenshots.md`](../features/screenshots.md), and resolve local targets | Pass; all 44 original badges, all 33 unique screenshot assets with captions/alt text, and 42 local README link targets |
| README follow-up gates | Generated badge checks, harness/engineering gates, docs gardening, AIDLC artifacts, task trackers, and `git diff --check` | Pass; the engineering scorecard evidence link remains on its required standalone line |
| README follow-up rendering | Local Markdown preview in the browser | Pass; visible badge groups and inline screenshot tables inspected |
| README follow-up runtime lanes | Dart formatting, analysis, and Flutter tests | N/A; this follow-up changes Markdown only, with application code unchanged since the full checklist above |

The README follow-up preserves all 44 badge labels, image URLs, and link targets.
It restores all 33 screens from the standalone gallery to the root README,
preserving image paths, captions, and alt text. Generated harness badge checks
remain enabled. The follow-up changes documentation only; the application proof
above comes from the completed full checklist before that follow-up.
No new reusable concept — mechanical task. No additional runtime regression
test is needed for the README layout; inventory and documentation checks cover
the preservation contract.

The final full-checklist log is `/tmp/reviewer-quality-checklist-final.log`.
The first failed run is retained at `/tmp/reviewer-quality-checklist-first.log`;
the reviewed golden rerun is `/tmp/reviewer-quality-counter-goldens.log`.
The README follow-up closeout log is `/tmp/reviewer-quality-readme-closeout.log`.
The coverage figures apply to the repository's documented filtered test scope;
they are not a claim of device or backend integration coverage.

## Files changed

| File | Change |
| --- | --- |
| [README.md (repository root)](../../README.md) | Put app/evidence entrypoints first, group all 44 visible badges by purpose, and include all 33 screenshots inline. |
| `apps/mobile/lib/features/counter/presentation/widgets/counter_actions.dart` | Remove the obsolete ScreenUtil scaling explanation from the icon-bound comment. |
| `apps/mobile/lib/features/counter/presentation/widgets/counter_display/counter_display.dart` | Follow changes to the reduced-motion preference. |
| `apps/mobile/lib/features/counter/presentation/widgets/counter_display/counter_value_text.dart` | Expose only the current count and fit long values on one line. |
| `apps/mobile/lib/features/example/presentation/widgets/example_page_body.dart` | Remove the unused network-image import. |
| `apps/mobile/lib/features/example/presentation/widgets/example_page_body_content.part.dart` | Remove the decorative hero and align navigation; retain the filled isolates action and its callback/key contract. |
| `apps/mobile/lib/l10n/app_en.arb` | Use workflow-oriented demo headings and description; update translator metadata. |
| `apps/mobile/lib/l10n/app_ar.arb` | Localize the revised demo headings and description. |
| `apps/mobile/lib/l10n/app_de.arb` | Localize the revised demo copy and Todo/Chat labels. |
| `apps/mobile/lib/l10n/app_es.arb` | Localize the revised demo copy and Todo/Chat labels. |
| `apps/mobile/lib/l10n/app_fr.arb` | Localize the revised demo copy and Todo/Chat labels. |
| `apps/mobile/lib/l10n/app_tr.arb` | Localize the revised demo copy and Todo/Chat labels. |
| `apps/mobile/lib/l10n/app_localizations.dart` | Regenerate the localization API documentation. |
| `apps/mobile/lib/l10n/app_localizations_ar.dart` | Regenerate Arabic strings. |
| `apps/mobile/lib/l10n/app_localizations_de.dart` | Regenerate German strings. |
| `apps/mobile/lib/l10n/app_localizations_en.dart` | Regenerate English strings. |
| `apps/mobile/lib/l10n/app_localizations_es.dart` | Regenerate Spanish strings. |
| `apps/mobile/lib/l10n/app_localizations_fr.dart` | Regenerate French strings. |
| `apps/mobile/lib/l10n/app_localizations_tr.dart` | Regenerate Turkish strings. |
| `packages/design_system/lib/src/responsive/responsive_layout.dart` | Keep shared maximum widths in logical pixels. |
| `packages/design_system/lib/src/responsive/responsive_typography.dart` | Select icon sizes by breakpoint without viewport magnification. |
| `apps/mobile/test/features/counter/presentation/widgets/counter_display_accessibility_test.dart` | Add semantics, reduced-motion, and long-value regressions. |
| `apps/mobile/test/shared/responsive_shell_regression_test.dart` | Test desktop content, bar, and icon bounds with the real responsive shell. |
| `apps/mobile/test/goldens/counter_page_loading.phone.png` | Refresh the reviewed phone baseline for corrected icon sizing. |
| `apps/mobile/test/goldens/counter_page_loading.tablet_portrait.png` | Refresh the reviewed tablet baseline for logical width caps and icon sizing. |
| `tool/check_regression_guards.sh` | Register both regression files and their changed-path routes. |
| `ai/CONTEXT_MAP.md` | Refresh canonical source-revision metadata. |
| `ai/README.md` | Update the canonical refresh date. |
| `ai/reports/README.md` | Record the refreshed snapshot source revision and date. |
| `ai/reports/architecture_overview.md` | Refresh canonical source-revision metadata. |
| `ai/reports/data_flow_map.md` | Refresh canonical source-revision metadata. |
| `ai/reports/dependency_map.md` | Regenerate feature line counts and source metadata. |
| `ai/reports/feature_map.md` | Regenerate feature inventory provenance. |
| `ai/reports/context_hotspots.md` | Regenerate file-size hotspots, feature line total, and source metadata. |
| `ai/reports/anti_patterns.md` | Refresh canonical source-revision metadata. |
| `ai/reports/ai_recommendations.md` | Refresh canonical source-revision metadata. |
| [docs/changes/README.md](README.md) | Index this change note. |
| [docs/changes/2026-10-20_reviewer_quality.md](2026-10-20_reviewer_quality.md) | Record scope, contracts, failures, fixes, and verification. |

## What we learned

Yes — I know more than I did before it started.

- Layout tests must include the responsive bootstrap. Fallback constants hid
  ScreenUtil magnification in the existing tests.
- Animated values need a stable semantics owner outside the visual transition;
  outgoing widgets can remain mounted after the displayed state changes.

## Limits and follow-up

The initial browser fixture renders the actual Example and counter widgets with
backend initialization disabled. It does not prove authenticated backend flows
or native iOS/Android/macOS behavior. The initial review did not run native
builds, devices, hosted CI, or deployment; subsequent hosted proof is recorded
in the PR. Very long navigation labels still use the existing ellipsis
behavior at narrow widths and large text sizes. This pass does not assert that
every demo or localization has been audited.

Follow-up actions: none required for the implementation. The PR records delivery
status and hosted verification. Human acceptance remains with the maintainer;
the primary checkout's unrelated local work is preserved.

Review: medium risk because shared responsive tokens affect multiple screens.
The final diff retains existing routes and callbacks, adds no dependencies,
and weakens no existing assertions. All six reproduced failures are resolved;
the code and rendered fixture were reviewed against the behavior contract above.

## Delivery review (2026-10-21)

The pending patch was reviewed against its callers, platform-adaptive buttons,
responsive bootstrap, localization sources/generated output, existing tests,
golden changes, regression routing, and README inventories. No additional
runtime correction was required; existing regression tests remain the behavior
guards, and no assertions were weakened. The branch integrated `origin/main` at
`ac25900c` without conflicts; its only upstream change was Gradle wrapper 9.8.2.

Fresh checks passed: formatting (16 files, no changes), app analysis and Mix lint,
design-system analysis, localization generation, and 33 focused tests across
nine files, including all eight counter goldens. README verification preserved
all 44 upstream badges, all 33 screenshot assets with alt text, and 42 local
link targets. The fresh `./bin/checklist --no-reuse` passed all 85 static checks,
44 regression guard files, layout checks, 11 leak tests, and 3,122 full-suite
tests with one intentional SnackBar demo skip. Filtered coverage is 85.69%
(20,625/24,070 lines); app-shell coverage is 79.88% (1,667/2,087 lines).
Closeout also passed. Fresh delivery logs are
`/tmp/reviewer-quality-delivery-{format,analyze,design-system-analyze,l10n,targeted,checklist,closeout}.log`.

An additional strict source-revision audit found that eight pre-existing AI
discovery snapshots referenced an older source revision. After committing the
reviewed source as `1bca0946b397a880f58b2768e811f8076c3eb4f1`,
`bash tool/refresh_ai_reports.sh` regenerated the ten canonical discovery
documents. The generated diff changes source metadata, dates, and measured
feature/file counts only. `bash tool/check_ai_snapshot_freshness.sh --strict-head`
passed against that source commit. The generated-only follow-up uses scoped
documentation checks; the runtime proof above remains applicable. No validator
was weakened. Scoped documentation gardening, task/AIDLC checks, badge and
scorecard gates, README inventory, tracked-secret scanning, whitespace, and
closeout passed. Refresh log:
`/tmp/reviewer-quality-delivery-snapshot-refresh.log`.

The user explicitly authorized pre-commit corrections, commit, push, and merge
after validation. The original implementation and README follow-up performed no
external actions; delivery actions and hosted proof belong to the PR record.
