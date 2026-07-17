# Audit — Memory quality Wave B0 dry-run (2026-07-17)

Report-only full-suite leak tracking baseline. **No gate flip.** Default remains
`withIgnoredAll()`. Wave A PR: https://github.com/redjadet/flutter_bloc_app/pull/550

## Run meta

| Field | Value |
| --- | --- |
| Stamp | `wave_b0_full` |
| Command | `flutter test --dart-define=MEMORY_LEAK_TRACKING_DRY_RUN=true` |
| Duration | ~4m35s (`15:50:41Z` → `15:55:16Z`) |
| Result | `+2752 ~4 -49` (`flutter_test` exit 1; dry-run script exit 0) |
| Leak type totals | `notDisposed: 309` (no `notGCed` / `gcedLate` in summary) |
| Artifacts | `tmp/memory_leak_dry_run/wave_b0_full/` (gitignored) |

Reproduce:

```bash
bash tool/run_memory_leak_tracking_dry_run.sh
# or: MEMORY_LEAK_DRY_RUN_STAMP=wave_b0_full bash tool/run_memory_leak_tracking_dry_run.sh
```

## Failure shape

- **49 / 49** failing entries are file-level `(tearDownAll) [E]` leak assertions
- **0** non-leak failures in the dry-run summarizer pass
- Failures cluster where widgets mount `GoRouter` / images / text / controllers
  without suite-level dispose discipline

### Failing file owners (prefix)

| Area | Files |
| --- | ---: |
| `test/features/**` | 25 |
| `test/shared/**` | 5 |
| `test/app/router/**` | 2 |
| Root / misc widget suites | 17 |

Full list: `tmp/memory_leak_dry_run/wave_b0_full/failing_files.txt`

## Leak classes (bucketed)

| Class | Count | Bucket | Notes |
| --- | ---: | --- | --- |
| `GoRouteInformationProvider` | 46 | harness / router | Tests create `GoRouter` / `MaterialApp.router` and omit dispose |
| `GoRouterDelegate` | 46 | harness / router | Same ownership as above |
| `TextPainter` | 47 | framework / text | Common under chat tiles / text-heavy widgets |
| `ImageStreamCompleterHandle` | 31 | framework / image | Example / cached network image surfaces |
| `_LiveImage` | 31 | framework / image | Paired with image completer handles |
| `TextEditingController` | 32 | product / controller | Chat input, forms — Wave B1/B2 candidate |
| `ScrollController` | 13 | product / controller | Chat lists — Wave B1/B2 candidate |
| `ParticleSystem` | 24 | product / demo | Counter particle effect — demo ownership |
| `Tap/Pan/LongPressGestureRecognizer` | 31 | framework / gesture | Chart / InteractiveViewer surfaces |
| `FocusNode` | 3 | product / controller | Sparse; auth refresh path sample |
| `EmailAuthFlow` / `OAuthFlow` | 1 each | product / auth | Rare; auth journey candidate for B1 |
| `ValueNotifier<double>` | 1 | product / notifier | Sparse |
| `TransformLayer` | 2 | framework / layer | Harness noise |

## Triage conclusions

1. **Do not flip global ignore.** ~49 suite tearDownAll failures and 309
   `notDisposed` objects — mostly router/image/text/gesture noise plus a smaller
   controller set.
2. **Harness first:** any future ignore-list promotion must separate
   `GoRouter*` undisposed test ownership from real product leaks.
3. **Product-leaning classes for later waves:** `TextEditingController`,
   `ScrollController`, `FocusNode`, auth flow objects, `ParticleSystem`.
4. **Flakes:** single run only. Pattern is stable (all tearDownAll leak fails);
   second-pass flake matrix deferred (optional re-run of the 49 files).
5. **BLE:** no BLE-tagged suite failures in this baseline — B1 still needs an
   explicit BLE teardown journey seed.
6. **Realtime:** `realtime_market` page tests appear in the failing set — good
   B1 teardown target alongside auth / app-shell.

## Wave sequencing (locked)

| Wave | Action |
| --- | --- |
| **B0** | This audit + dry-run tooling (done) |
| **B1** | Tag stable journeys: auth sign-in/out, app-shell route replacement, realtime/BLE teardown |
| **B2** | Promote only proven product leak classes from ignore list |
| **B3** | AST rules for timers/listeners; defer alias/GetIt/context until FP rate low |

## Suppressions / production fixes

None in B0 (report-only).

## Tooling shipped

- `MEMORY_LEAK_TRACKING_DRY_RUN` dart-define in `flutter_test_config.dart`
- `tool/run_memory_leak_tracking_dry_run.sh` (always exit 0)
- `tool/summarize_memory_leak_dry_run.py`
- Docs: [`../performance/memory_testing.md`](../performance/memory_testing.md),
  [`../performance/memory_ci.md`](../performance/memory_ci.md), catalog entry
