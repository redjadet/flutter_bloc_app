# Lessons

**Versioned in git** — commit new entries with the change that learned the lesson.
Local per-host trackers stay under `tasks/codex/` and `tasks/cursor/` (gitignored).

Record patterns from user corrections or notable misses so they can be avoided
next time.

Agents must answer **"What did you get wrong, and how did you fix it?"** before filing
here: what went wrong, what fixed it, and what rule prevents recurrence.
Operator pref: [`docs/agent_kb/operator_preferences_durable.md`](../docs/agent_kb/operator_preferences_durable.md)
§ Workflow.

## Template

### YYYY-MM-DD - Short title

- What went wrong:
- How it was fixed:
- Pattern:
- Preventive rule:
- Evidence or affected files:

### 2026-08-17 - material_ui localizations vs flutter_localizations in tests

- What went wrong:
  After `migrate_design_widgets`, tests kept `AppLocalizations.localizationsDelegates`
  (flutter_localizations Material/Cupertino types) or golden_toolkit
  `materialAppWrapper` (`package:flutter/material.dart` MaterialApp). App widgets
  look up `package:material_ui` types. Failures: TR locale warnings, missing
  Cupertino for `de`, dark FAB goldens ~99% pixel mismatch, leftover
  `GlobalWidgetsLocalizations` undefined.
- How it was fixed:
  Shared `appLocalizationDelegates` (`GlobalMaterialLocalizations.delegates` from
  material_ui + app ARB). Goldens wrap with `materialUiAppWrapper`. Therapy
  smoke extra-pumps fake-network timer after `pumpAndSettle`.
- Pattern:
  Standalone design libraries split Type identity for Theme and
  Material/Cupertino localizations. Wrapper package must match widget package.
- Preventive rule:
  Do not use generated `AppLocalizations.localizationsDelegates` or golden_toolkit
  `materialAppWrapper` for `package:material_ui` widgets. Regression:
  `test/l10n/app_localization_delegates_test.dart`.
- Evidence or affected files:
  `apps/mobile/lib/l10n/app_localization_delegates.dart`,
  `apps/mobile/test/helpers/material_ui_app_wrapper.dart`,
  `docs/testing/widget_test_playbook.md`.

### 2026-08-08 - Hive 2.x + Flutter web `--wasm` breaks counter save

- What went wrong:
  GH Pages `--wasm` build linked Hive's stub backend (`dart.library.html` absent
  under dart2wasm). `openBox('counter')` threw `UnimplementedError`; UI showed
  “Failed to save counter” on Increment. Local dart2js debug hid the bug.
- How it was fixed:
  Default `WEB_WASM=0` + `WEB_WASM_FORCE` gate in `tool/build_web_github_pages.sh`;
  always `Hive.init` on web (`hive_web_v1` release).
- Pattern:
  Packages that conditional-import on `dart.library.html` alone break under
  `--wasm`; prefer `dart.library.js_interop` / hive_ce before re-enabling WASM.
- Preventive rule:
  Do not default web deploy to `--wasm` while Hive 2.x is in tree; run
  `tool/test_build_web_github_pages_wasm_guard.sh`.
- Evidence or affected files:
  `tool/build_web_github_pages.sh`, `packages/storage/.../hive_initializer_web.dart`,
  `docs/engineering/workarounds.md` §4, production console logs on Pages.

### 2026-08-05 - Do not adopt permission_handler 13 until Android SDK 37 exists

- What went wrong:
  `permission_handler` ^13 pulls `permission_handler_android` 14, which needs
  `compileSdk` 37 (`CINNAMON_BUN` / `ACCESS_LOCAL_NETWORK`). Local SDK only had
  platforms through 36, so Android integration `assembleDebug` failed.
- How it was fixed:
  Pin `permission_handler: 12.0.3` (android 13.0.1) until `platforms;android-37`
  is installable and the app compileSdk can move with it.
- Pattern:
  Federated plugin major bumps often raise compileSdk before the host SDK ships.
- Preventive rule:
  Before accepting a plugin that raises compileSdk, confirm
  `sdkmanager --list_installed` includes that platform and bump root + plugin
  `compileSdk` together — or pin the prior major.
- Evidence or affected files:
  `apps/mobile/pubspec.yaml`; `pubspec.lock`; Android assemble via
  `./bin/integration_tests`.

### 2026-08-05 - Callable UI must catch `Object`, not only `Exception`

- What went wrong:
  The authenticated Functions diagnostic caught generic failures with
  `on Exception`. A `StateError` from the callable seam bypassed that branch,
  surfaced through the Flutter test binding, and crashed the page instead of
  showing its safe localized error.
- How it was fixed:
  Both callable actions now catch `Object` after the typed
  `FirebaseFunctionsException` branch. Regression tests cover a non-Exception
  error, duplicate tap while pending, and disposal before completion.
- Pattern:
  Dart errors are not all `Exception`; presentation async boundaries that must
  keep sensitive SDK failures out of the UI need a typed-safe branch followed
  by an `Object` fallback.
- Preventive rule:
  For credential-adjacent UI calls, catch the known typed exception first, then
  map every remaining `Object` to a stable localized error. Test an `Error`
  subtype, not only an `Exception` subtype.
- Evidence or affected files:
  `apps/mobile/lib/features/example/presentation/pages/firebase_functions_test_page.dart`;
  `apps/mobile/test/features/example/presentation/pages/firebase_functions_test_page_test.dart`.

### 2026-08-01 - Pause flags must drain in-flight remote-watch writes

- What went wrong:
  A session-cleanup pause prevented future watch merges, but a merge already
  awaiting local Hive `save` could complete after the cleanup clear and restore
  previous-account data.
- How it was fixed:
  Todo and counter track active remote-watch merge futures; their local-clear
  methods wait for the tracked work before clearing. Gated-save tests force the
  exact interleaving.
- Pattern:
  A cancellation/pause flag alone cannot order an operation already past its
  last guard and inside an asynchronous persistence write.
- Preventive rule:
  For destructive cleanup, stop admission and drain tracked in-flight writers
  before clearing shared persistence; test with a save gate, not only a
  pause-before-stream-delivery test.
- Evidence or affected files:
  `apps/mobile/lib/features/{todo_list,counter}/data/offline_first_*`; focused
  repository tests; `tool/check_offline_first_remote_merge.sh`.

### 2026-07-24 - Scorecard markdown must not int()-truncate medians; count all outcomes

- What went wrong:
  Scorecard MD used `int(p50)` so even medians under-reported by 0.5ms.
  Command `count` included cancelled/aborted but ok/failed only — gap of 1
  on `integration_tests`.
- How it was fixed:
  Half-away-from-zero display rounding; track cancelled/aborted/other so
  `count == ok+failed+cancelled+aborted+other`.
- Pattern:
  Never use `int()` or bankers `round()` for duration display of medians;
  every status that increments count must land in an outcome bucket.
- Preventive rule:
  `./tool/build_agent_scorecard_summary.sh --self-test` (harness fixtures).
- Evidence or affected files:
  `tool/build_agent_scorecard_summary.sh`,
  `docs/changes/2026-07-24_agent_scorecard_summary_rounding_and_count.md`

### 2026-07-23 - Pub silent-prod bumps need call-site + lenient-parse regression checks

- What went wrong:
  App PR #605 failed CI after bumping `ilkersevim_async_lifecycle` /
  `ilkersevim_safe_parse`. Websocket used bare `CompleterHelper.reset()` on
  leader-only failure (now completes waiters → unhandled async /
  `StateError`). `parseMapOfMaps` 0.1.3 rethrew `FormatException` from
  `parseItem` even in lenient mode, breaking RTDB todo skip-invalid.
- How it was fixed:
  Publish `safe_parse` 0.1.4 (treat `FormatException` like other parse
  errors when `failOnPartial: false`). Websocket always
  `completeErrorAndReset`, with a leader-only `catchError` sink because
  `Completer.future` is single-subscription.
- Pattern:
  Hardening packages that previously abandoned completers or special-cased
  `FormatException` will surface first in app consumers, not package unit
  tests that never threw `FormatException` from `parseItem`.
- Preventive rule:
  After publishing lifecycle/parse hardenings, run owning app tests for
  `CompleterHelper` call sites and any `parseMapOfMaps`/`FormatException`
  parsers before merge; do not assume caret bump alone is green.
- Evidence or affected files:
  `apps/mobile/lib/features/websocket/data/echo_websocket_repository.dart`;
  `ilkersevim_safe_parse` 0.1.4; PR #605.

### 2026-07-23 - Android IT Chat/IoT “tap flake” was Supabase auth gate

- What went wrong:
  Full suite missed `Conversation history` / `IoT Demo`; focused re-runs
  passed. Spent time on overflow scroll/nudge before checking route gates.
- How it was fixed:
  Integration harness resets/stubs `SupabaseBootstrapService` so Chat/IoT
  `IotDemoAuthGate` stays local-only without a session.
- Pattern:
  Host `SUPABASE_*` (or late bootstrap) + no session → gate redirects →
  page-title finders fail and look like navigation flakes.
- Preventive rule:
  When Chat/IoT IT fails only in full suite, check `IotDemoAuthGate` /
  `isSupabaseInitialized` before blaming PopupMenu scroll.
- Evidence or affected files:
  `apps/mobile/integration_test/test_harness.dart`;
  `docs/changes/2026-07-23_android_it_supabase_gate_play_readiness.md`

### 2026-07-22 - Verify branch before commit after parallel checkout churn

- What went wrong:
  Security fix for firebase-functions npm overrides was committed and pushed
  onto unrelated `chore/bump-ilkersevim-retry-0.1.1` (PR #589) instead of the
  intended `chore/fix-npm-body-parser-brace-expansion` branch after worktree
  remove / parallel branch switches.
- How it was fixed:
  Cherry-picked onto the correct branch, opened #590, then
  `git reset --hard` + `git push --force-with-lease` restored #589 to its
  intended tip (feature branch only; never `main`).
- Pattern:
  Session with multiple local branches + worktree teardown can leave HEAD on
  the wrong topic branch; `git commit` / `git push` silently attach to it.
- Preventive rule:
  Immediately before staging/commit/push: `git branch --show-current` and
  `git status -sb` must match the intended topic branch name. After any
  `git worktree remove` / `git switch`, re-check before the next write.
- Evidence or affected files:
  PRs #589/#590, `backend/firebase/functions/package.json`

### 2026-07-18 - Watch-merge needs worktree remove before local branch delete

- What went wrong:
  `commit_push_pr_watch_merge_cleanup.sh` squash-merged PR #557 and deleted the
  remote branch, then failed deleting local `codex/docs-structure-cleanup`
  because a Cod worktree still checked that branch out (`exit_code=1` after
  successful merge).
- How it was fixed:
  From primary tree: `git worktree remove <path>`, prune, delete local branch,
  then `commit_push_pr_post_merge.sh` / ff-only `main`.
- Pattern:
  `gh pr merge --delete-branch` only drops the remote ref. Topic worktrees still
  pin the local branch.
- Preventive rule:
  Before claiming watch-merge done, `git worktree list`; remove topic worktree
  first, then delete local branch / run post-merge. Prefer
  `gh-watch-merge-pr` cleanup steps over assuming script exit 0 means local
  cleanup finished.
- Evidence or affected files:
  PR #557, `tool/commit_push_pr_watch_merge_cleanup.sh`,
  `tool/commit_push_pr_post_merge.sh`,
  `.codex/worktrees/docs-structure-cleanup`

### 2026-07-18 - Do not let whole-repo format pollute a docs PR

- What went wrong:
  After docs path comment edits in a few Dart files, `./bin/format` reformatted
  unrelated `memory_lint` / memory-leak test files. `git add -A` pulled that
  churn into the docs-move commit (PR #558).
- How it was fixed:
  Follow-up commit restored those paths from `origin/main` before merge.
- Pattern:
  Repo-wide format + blanket stage expands write-set beyond the task.
- Preventive rule:
  Format only the Dart files touched for the task (or restore unrelated format
  diffs before commit). Never `git add -A` after a broad format without
  reviewing the dart write-set.
- Evidence or affected files:
  PR #558, `./bin/format`, `apps/mobile/test/shared/memory_leak_*.dart`,
  `custom_lints/memory_lint/**`

### 2026-07-17 - Idle cursor todo must keep required headings

- What went wrong:
  Reset `tasks/cursor/todo.md` to a short "Idle" note and dropped `## Goal` /
  `## Write-set` / `## Risks` / `## Validation command` / `## Evidence/result`.
  `./bin/agent-maintain closeout` failed tracker validation.
- How it was fixed:
  Restored the required headings with explicit idle placeholders (`Write-set:
  none (idle)`, validation = closeout + AI freshness).
- Pattern:
  Gitignored trackers still run through `validate_task_trackers.sh` on closeout.
- Preventive rule:
  Never strip required headings for "idle"; fill sections with idle/none text.
- Evidence or affected files:
  `tool/validate_task_trackers.sh`
  `docs/engineering/task_tracker_template.md`
  `tasks/cursor/todo.md`

### 2026-07-17 - Full RealtimeMarketPage hangs under leak_tracker

- What went wrong:
  Tagged leak journey mounted `RealtimeMarketPage` + fl_chart; test hung in
  leak finalization (SIGTERM under timeout), not on the assertion.
- How it was fixed:
  Thin `BlocBuilder` surface for watch→emit→teardown; ignore only proven
  harness layers/`TextPainter`. Fake repo `broadcast(sync: true)` so emit is
  visible before the next pump.
- Pattern:
  Chart-heavy pages dominate leak_tracker GC/finalization; async broadcast
  drops look like UI staleness under a single `pump`.
- Preventive rule:
  Prefer minimal product ownership surfaces for `memory_leak` tags; never tag
  full chart pages until finalization is proven bounded; use sync broadcast or
  explicit post-emit pumps in fakes.
- Evidence or affected files:
  `apps/mobile/test/shared/memory_leak_realtime_teardown_test.dart`
  `docs/plans/2026-07-17_memory_quality_deferred.md` (MQ-N05)
  `docs/audits/memory_quality_wave_b1_review_2026-07-17.md`

### 2026-07-17 - Stacked PR dies when base branch is deleted

- What went wrong:
  After B0 `#551` merged and base branch was deleted, B1 `#552` stayed CLOSED
  and could not be reopened or retargeted (`Cannot change the base branch of a
  closed pull request`).
- How it was fixed:
  Opened replacement `#553` from the same head → `main`, then merged.
- Pattern:
  GitHub closes stacked PRs when the base ref disappears; reopen/retarget fails.
- Preventive rule:
  Before deleting a stacked base branch, retarget dependents to `main` (or open
  a replacement PR). Prefer merge order base-first with retarget, not delete-first.
- Evidence or affected files:
  PRs `#552` / `#553`
  `docs/plans/2026-07-17_memory_quality_deferred.md`

### 2026-07-17 - check-ignore must sit on or above the jsonEncode/jsonDecode line

- What went wrong:
  After moving case_study encode helpers into data DTOs, `// check-ignore: small
  payload` sat above the method signature while `jsonEncode(` wrapped onto the
  next line. `tool/check_raw_json_decode.sh` only treats ignore on the match
  line or the immediate previous line, so checklist best-practices failed.
- How it was fixed:
  Put `jsonEncode(` on the same line as the method signature so the ignore
  comment is immediately above the match (same pattern as `encodeList`).
- Pattern:
  Multi-line `=>` / formatter wraps can orphan `check-ignore` from the call.
- Preventive rule:
  After any format or DTO move that touches raw `jsonEncode`/`jsonDecode`, run
  `bash tool/check_raw_json_decode.sh` before claiming checklist-ready; keep
  ignore adjacent to the call expression.
- Evidence or affected files:
  `apps/mobile/lib/features/case_study_demo/data/case_study_draft_dto.dart`,
  `tool/check_raw_json_decode.sh`, commit `e326f4ca`.

### 2026-07-14 - AI report refresh must regenerate its claimed metrics

- What went wrong:
  `refresh_ai_reports.sh` updated report timestamps and `git_head` while leaving
  feature LOC, inventory, and hotspot content stale; strict freshness also
  rejected the normal follow-up metadata-only commit.
- How it was fixed:
  The refresh command now regenerates marker-bounded metric blocks from
  `tool/modular_metrics.sh`; strict freshness accepts the immediate parent only
  when HEAD changed AI snapshot metadata exclusively.
- Pattern:
  A fresh timestamp is not evidence that derived report content is current.
- Preventive rule:
  Regenerated report claims need a bounded source-owned block and a fixture for
  the freshness contract; keep narrative guidance human-maintained.
- Evidence or affected files:
  `tool/refresh_ai_reports.sh`, `tool/check_ai_snapshot_freshness.sh`,
  `tool/run_harness_fixtures.sh`, `ai/reports/dependency_map.md`,
  `ai/reports/context_hotspots.md`, `ai/reports/feature_map.md`

### 2026-07-14 - Format Dart before task finish

- What went wrong:
  Agents could finish Dart-touching tasks without running format, leaving style
  drift for the operator or CI.
- How it was fixed:
  Operator preference: after any `.dart` change, execute `./bin/format` (or
  `dart format .`) before claiming done. Encoded in durable prefs, always-on
  `agent-execution`, finish gate, and delivery-workflow finish steps.
- Pattern:
  Format is a closeout gate, not an optional nicety.
- Preventive rule:
  `.dart` changed → `./bin/format` before finish/report.
- Evidence or affected files:
  `docs/agent_kb/operator_preferences_durable.md`,
  `docs/agent_kb/legibility_and_finish_gate.md`,
  `tool/agent_host_templates/cursor/rules/agent-execution.mdc`,
  `tool/agent_host_templates/shared/skills/agents-delivery-workflow/SKILL.md`,
  `AGENTS.md`

### 2026-07-14 - Coverage pump must keep SyncStatusCubit

- What went wrong:
  `routes_core_part_coverage_test` re-pumped settings QA extras without
  `MultiBlocProvider`, so `SyncDiagnosticsSection` threw
  `ProviderNotFoundException` for `SyncStatusCubit` (and Column overflowed).
- How it was fixed:
  Shared `_coveragePumpTree` with Theme/Locale/Sync providers for both pumps;
  wrap extras in `SingleChildScrollView` + `mainAxisSize: min`.
- Pattern:
  Second `pumpWidget` that rebuilds a subtree still needs the same app-scoped
  cubits the production widget tree assumes.
- Preventive rule:
  Re-pump settings/QA widgets with `SyncStatusCubit` (and peers) provided.
- Evidence or affected files:
  `apps/mobile/test/app/router/routes_core_part_coverage_test.dart`

### 2026-07-13 - Regenerable outputs stay gitignored

- What went wrong:
  Coverage baselines (`lcov.base.info`, `coverage_summary.md`) and some build
  dir patterns were tracked or only partially ignored, so safe disk reclaim
  could hit tracked paths or leave regenerable churn in commits.
- How it was fixed:
  Operator: regenerable files belong in `.gitignore`. Expanded ignore for
  `**/build/`, `**/.dart_tool/`, `__pycache__/`, coverage lcov/summary;
  untracked prior coverage baselines; `./bin/clean-build-caches` aligned.
- Pattern:
  If `clean-build-caches` can delete it, `.gitignore` must cover it. Do not
  re-commit coverage lcov/summary without an explicit new operator request.
- Preventive rule:
  Prefer regenerable → gitignore over “commit the baseline.” Generate locally
  via `bash tool/test_coverage.sh`.
- Evidence or affected files:
  `.gitignore`
  `bin/clean-build-caches`
  `tool/clean_build_caches.sh`
  `docs/agent_kb/operator_preferences_durable.md`

### 2026-07-12 - PR merge left topic worktree alive

- What went wrong:
  After `gh pr merge --delete-branch` on #487, remote head deleted but local
  branch delete failed — worktree
  `flutter_bloc_app-ai-human-review-guide` still checked out
  `codex/ai-human-code-review-guide`.
- How it was fixed:
  `git worktree remove <path>`, then `bash tool/commit_push_pr_post_merge.sh`
  from primary tree on `main`.
- Pattern:
  Merge deletes remote branch only; worktree holds local branch until removed.
- Preventive rule:
  After watch/merge, run `git worktree list`; remove merged-head worktrees
  before claiming closeout. Use skill `gh-watch-merge-pr` /
  `tool/commit_push_pr_watch_merge_cleanup.sh`.
- Evidence or affected files:
  PR #487; `tool/agent_host_templates/shared/skills/gh-watch-merge-pr/SKILL.md`

### 2026-07-12 - Engineering 85% gate vs integration-merged lcov

- What went wrong:
  Closeout `engineering-maintain` failed on filtered **84.46%** with no app-code
  changes. `coverage/lcov.info` had been inflated by an integration merge that
  added uncovered lines; the unit baseline still sat ≥85%.
- How it was fixed:
  Restored `coverage/lcov.info` / `coverage/lcov.base.info` from the Jul 12 unit
  baseline (`apps/mobile/coverage/lcov.base.info` → **85.23%**), refreshed
  `coverage/coverage_summary.md` + README badge, re-ran engineering gate.
- Pattern:
  Integration `--merge-coverage` can leave `lcov.info` below the Engineering
  **85%** claim while `lcov.base.info` (unit-only from `tool/test_coverage.sh`)
  still passes.
- Preventive rule:
  For Coverage=10/10 closeout proof, use unit baseline artifacts. If merge drag
  dips `lcov.info` under 85%, restore from `coverage/lcov.base.info` (or re-run
  `bash tool/test_coverage.sh`); do not lower the 85% gate and do not treat
  merge drag as an app-code defect.
- Evidence or affected files:
  `tool/check_engineering_quality_scorecard_gate.sh`
  `tool/test_coverage.sh`
  `tool/run_integration_tests.sh`
  `docs/engineering/engineering_quality_scorecard.md`

### 2026-07-03 - Integration smoke needs Firebase delegate reset after real auth

- What went wrong:
  `smoke_flows_test.dart` runs guest sign-in with `realFirebaseAuth` then
  mock-auth flows. After real auth, `firebase_core` cached
  `MethodChannelFirebase` in `Firebase.delegatePackingProperty`, so later
  `FirebasePlatform.instance = mock` installs were ignored and mock tests failed
  with `[core/not-initialized]`.
- How it was fixed:
  Set `Firebase.delegatePackingProperty` when installing the mock platform;
  call `resetFirebaseTestDelegate()` in integration tearDown; skip native
  `FirebaseApp.configure()` for placeholder `GoogleService-Info.plist`; use fake
  Remote Config when `Firebase.apps.isEmpty`.
- Pattern:
  `firebase_core` lazily caches the first platform delegate — swapping
  `FirebasePlatform.instance` alone is not enough after real Firebase touched
  the cache.
- Preventive rule:
  Any integration file mixing `IntegrationAuthMode.realFirebaseAuth` with mock
  auth must reset the delegate in tearDown; run smoke tier on iOS simulator
  before claiming integration green.
- Evidence or affected files:
  `apps/mobile/test/test_helpers.dart`
  `apps/mobile/integration_test/test_harness.dart`
  `apps/mobile/ios/Runner/AppDelegate.swift`
  `tool/run_integration_tests.sh`

## Learned User Preferences

### 2026-07-04 - Keep coverage artifacts in commits

- What went wrong:
  Before merge, agent removed `apps/mobile/coverage/lcov.base.info` from the
  commit and added `apps/mobile/coverage/` to `.gitignore`, treating the
  integration baseline as accidental churn.
- How it was fixed:
  Operator preference: keep coverage artifacts in commits. Revert gitignore
  exclusion; restore tracked `apps/mobile/coverage/lcov.base.info`; document in
  [`operator_preferences_durable.md`](../docs/agent_kb/operator_preferences_durable.md).
- Pattern:
  Integration merge staging copies workspace `coverage/lcov.base.info` into
  `apps/mobile/coverage/` — that file is intentional repo state, not ephemeral
  build output to strip pre-push.
- Preventive rule:
  **Superseded 2026-07-13** — regenerable coverage outputs are gitignored again
  by explicit operator request. See top-of-file entry
  `2026-07-13 - Regenerable outputs stay gitignored`.
- Evidence or affected files:
  `apps/mobile/coverage/lcov.base.info`
  `.gitignore`
  `tool/run_integration_tests.sh`
  `docs/agent_kb/operator_preferences_durable.md`

### 2026-07-03 - Firebase forced refresh needs one getIdTokenResult(true)

- What went wrong:
  `TokenRepository.refreshFirebaseAccessToken` called `getIdToken(true)` then
  `_readFirebaseTokenResult(..., forceRefresh: false)`, so the second read could
  return a stale cached token and defeat the forced refresh.
- How it was fixed:
  Use a single `_readFirebaseTokenResult(user, forceRefresh: true)` (backed by
  `getIdTokenResult(true)`) and update auth tests/mocks to match.
- Pattern:
  Forced Firebase refresh must read token + expiry in one forced SDK call; do
  not pair `getIdToken(true)` with `getIdTokenResult(false)`.
- Preventive rule:
  On `TokenRepository` / auth refresh edits, grep for that pair and run
  `tool/check_auth_refresh_single_flight.sh` plus focused auth HTTP tests.
- Evidence or affected files:
  `apps/mobile/lib/core/auth/token_repository.dart`
  `test/core/auth/token_repository_test.dart`
  `tool/check_auth_refresh_single_flight.sh`

### 2026-07-02 - Auth session lifecycle races need focused guard routing

- What went wrong:
  Cursor auth PRs fixed real session lifecycle races, but one regression test
  did not prove concurrent Firebase and Supabase sign-out behavior and failed
  only in the broad CI build.
- How it was fixed:
  Strengthened `SessionLifecycleCoordinator` coverage with registered slow
  Firebase sign-out plus immediate Supabase sign-out, and routed auth session
  lifecycle paths through focused regression guards before coverage.
- Pattern:
  Session invalidation ordering and per-provider in-flight gates are async
  behavior contracts, not just implementation details.
- Preventive rule:
  Changes under `apps/mobile/lib/core/auth/*` or `AppAuthCubit` must run the auth session
  lifecycle focused tests via `tool/check_regression_guards.sh` before broad
  coverage.
- Evidence or affected files:
  `test/app/presentation/cubit/app_auth_cubit_test.dart`
  `test/core/auth/session_lifecycle_coordinator_test.dart`
  `tool/check_regression_guards.sh`

### 2026-04-02 - Isolate.run from video tile captured non-sendable Flutter state

- Correction:
  Replaced `Isolate.run(() => File(path).existsSync())` in `CaseStudyVideoTile`
  with `compute(_caseStudyLocalVideoExists, localPath)` using a top-level helper.
- Pattern:
  `Isolate.run` serializes the closure’s captures; instance-method closures can
  pull in `WidgetsFlutterBinding` / async zones and fail at runtime with
  *illegal argument in isolate message*.
- Preventive rule:
  In presentation code, use `compute` + top-level/static callback only; repo
  checklist includes `tool/check_no_isolate_run_in_presentation.sh`.
- Evidence or affected files:
  `apps/mobile/lib/features/case_study_demo/presentation/widgets/case_study_video_tile.dart`
  `.cursor/rules/flutter-isolate-presentation.mdc`
  `tool/check_no_isolate_run_in_presentation.sh`

### 2026-06-15 - RequestIdGuard supersession after successful mutation

- What went wrong:
  Cubit returned `false` from booking flows when concurrent `refresh()` superseded
  `RequestIdGuard` during post-mutation reload—even after the appointment was
  persisted—blocking navigation and risking duplicate user actions.
- How it was fixed:
  Return success (`true` / bare `return`) when the guard is inactive after a
  successful mutation; add static guard `tool/check_mutation_success_after_guard.sh`
  and regression tests (therapy PR #328 write path, PR #330 reload path).
- Pattern:
  Stale-read supersession is not mutation failure; `return false` surfaces a
  false error UI.
- Preventive rule:
  Never `return false` only because `!_isRequestStillActive`; run
  `tool/check_mutation_success_after_guard.sh` on cubit edits that touch guards.
- Evidence or affected files:
  `apps/mobile/lib/features/online_therapy_demo/presentation/cubit/client_booking_cubit.dart`
  `tool/check_mutation_success_after_guard.sh`
  `docs/changes/2026-06-15_mutation-success-guard.md`

### 2026-06-24 - Coverage delivery ask is not CI gate bump

- What went wrong:
  Operator asked for test coverage at least 80%; agent raised CI `COVERAGE_THRESHOLD` to 80% and updated docs to match.
- How it was fixed:
  Operator clarified CI minimum floor stays 75%; reverted threshold in workflows and `update_coverage_summary.dart`; kept measured rollup improvements (~80.28%).
- Pattern:
  Delivery coverage target ≠ CI enforcement threshold.
- Preventive rule:
  "Coverage at least X%" → add tests/exclusions to raise filtered rollup; keep `COVERAGE_THRESHOLD=75` unless the operator explicitly asks to change the CI gate.
- Evidence or affected files:
  `docs/CODE_QUALITY.md`
  `docs/agent_kb/operator_preferences_durable.md` § Validation
  `.github/workflows/ci.yml`
  PR #375

### 2026-06-24 - Stage new harness/skill paths before commit

- What went wrong:
  Harness/skill delivery left new `agents-regression-capture` files untracked; review flagged them and the operator had to request untracked paths in the commit.
- How it was fixed:
  Staged `tool/agent_host_templates/shared/skills/agents-regression-capture/SKILL.md` and `docs/changes/2026-06-24_agents-regression-capture-skill.md` in the same commit as routing/harness edits.
- Pattern:
  Host-template skill work creates new `??` paths under `tool/agent_host_templates/` and `docs/changes/`.
- Preventive rule:
  Before commit on harness/skill changes, scan `git status` for untracked deliverables and stage them with the routing/sync edits.
- Evidence or affected files:
  `tool/agent_host_templates/shared/skills/agents-regression-capture/SKILL.md`
  commit `04deee32`

### 2026-06-23 - Mix bottom-sheet widget tests need MaterialApp builder scope

- What went wrong:
  `register_country_picker_test` pumped `buildAppMixScope` only under `home`; `showModalBottomSheet` used the navigator overlay context without Mix, so the test failed to find sheet content.
- How it was fixed:
  Wrap via `MaterialApp.builder: (context, child) => buildAppMixScope(context, child: child ?? const SizedBox.shrink())` so overlay routes inherit Mix scope.
- Pattern:
  Widget tests that open modal routes/sheets for Mix-styled pickers need scope on the app builder, not only the home subtree.
- Preventive rule:
  For Mix + `showModalBottomSheet` / `showCountryPicker`, use `MaterialApp.builder` (or an equivalent root scope) before tapping open actions.
- Evidence or affected files:
  `test/features/auth/presentation/widgets/register_country_picker_test.dart`
  `apps/mobile/lib/core/theme/mix_app_theme.dart`

### 2026-06-22 - initState guard missed context.cubit generic form

- What went wrong:
  `check_inherited_widget_in_initstate.sh` matched `context.cubit(` only; therapy and websocket pages using `context.cubit<CallCubit>()` in `initState` passed the guard while still reading InheritedWidget too early.
- How it was fixed:
  Extended the guard for `context.cubit<` and allowed reads inside `addPostFrameCallback`; migrated violating pages to postFrameCallback + `mounted` before cubit calls.
- Pattern:
  Type-safe cubit access uses generics; static guards and audits must include the `<` form.
- Preventive rule:
  When adding `context.cubit<T>()` startup reads, verify the initState guard covers them; defer reads to postFrameCallback unless the guard explicitly allows in-callback access.
- Evidence or affected files:
  `tool/check_inherited_widget_in_initstate.sh`
  `docs/changes/2026-06-22_batch-c-therapy-initstate-call-guard.md`

### 2026-06-22 - Chat resetConversation emitted before persist

- What went wrong:
  `resetConversation` emitted cleared UI before history save finished; persist failure left UI cleared while storage still held prior conversation (`clearHistory` was already persist-first).
- How it was fixed:
  Persist-first via `CubitExceptionHandler`; emit cleared snapshot only after successful save; on failure keep prior state and surface error.
- Pattern:
  Destructive chat/history mutations must persist-before-emit, same as other history actions.
- Preventive rule:
  Any reset/clear path that mutates stored history should mirror `clearHistory` ordering and have a regression test for save failure.
- Evidence or affected files:
  `apps/mobile/lib/features/chat/presentation/cubit/chat_cubit_history_actions.dart`
  `test/chat_cubit_test.dart`

### 2026-06-22 - GraphQL pull-to-refresh did not await cubit

- What went wrong:
  `RefreshIndicator.onRefresh` used `CubitHelpers.safeExecute` with a void callback, so the spinner dismissed before `cubit.refresh()` completed.
- How it was fixed:
  `onRefresh: () => cubit.refresh()` so the returned `Future` is awaited by `RefreshIndicator`.
- Pattern:
  Pull-to-refresh must return the cubit refresh `Future`; void wrapper helpers break the refresh contract.
- Preventive rule:
  For `RefreshIndicator`, pass `() => cubit.refresh()` or an explicit `async` handler that awaits — not void `safeExecute`.
- Evidence or affected files:
  `apps/mobile/lib/features/graphql_demo/presentation/pages/graphql_demo_page.dart`

### 2026-04-17 - Caveman-lite is the default when suitable

- Correction:
  Do not treat caveman mode as opt-in for this repo's normal agent replies.
  Routine commentary and concise summaries should already use caveman-lite when
  it preserves clarity.
- Pattern:
  I answered as if caveman mode had to be manually activated, ignoring the repo
  canon that already sets compressed communication as the default behavior.
- Preventive rule:
  For this repo, assume caveman-lite is on by default for routine updates and
  straightforward answers. Switch back to normal concise prose only when
  precision, ambiguity, or tone makes compression risky.
- Evidence or affected files:
  `AGENTS.md`
  `tasks/lessons.md`

### 2026-03-30 - Do not self-invoke Codex review helper from Codex

- Correction:
  Do not call `./tool/request_codex_feedback.sh` from Codex itself. That helper
  is meant for Cursor or explicit cross-host second-opinion flows.
- Pattern:
  I treated a repo review helper as a generic validation step without checking
  whether the current host was the same system the helper delegates to.
- Preventive rule:
  Before invoking a cross-host or second-opinion helper, confirm whether the
  current host is already that reviewer. If it is, only use the helper when the
  user explicitly asks for a second opinion or cross-host review.
- Evidence or affected files:
  `AGENTS.md`
  `docs/agents_quick_reference.md`
  `docs/ai_code_review_protocol.md`
  `~/.codex/skills/flutter-bloc-app-quick-reference/SKILL.md`
  `~/.codex/skills/flutter-bloc-app-delivery-workflow/SKILL.md`
  `~/.codex/skills/flutter-bloc-app-cross-host-review/SKILL.md`

### 2026-07-30 - Path guards must fail closed after workspace moves

- What went wrong:
  `check_no_isolate_run_in_presentation.sh` still scanned root `lib/` after the
  app moved to `apps/mobile/lib/`; missing search roots produced an empty result
  and a false pass.
- How it was fixed:
  Scan current app/package roots, reject missing focused paths, and add bad/good
  harness fixtures through `--paths`.
- Pattern:
  A static guard that tolerates a missing ownership root can silently stop
  enforcing its contract after a workspace migration.
- Preventive rule:
  Path-dependent guards must use canonical workspace roots, fail closed when
  expected roots are absent, and include a fixture that proves bad input fails.
- Evidence or affected files:
  `tool/check_no_isolate_run_in_presentation.sh`
  `tool/run_harness_fixtures.sh`
  `tool/fixtures/no_isolate_run_in_presentation/`
