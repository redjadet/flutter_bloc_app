# Validation scripts — catalog

Router: [`../validation_scripts.md`](../validation_scripts.md).

## Inventory map (disk vs docs)

| Source | What it is |
| --- | --- |
| `tool/check_*.sh` on disk | **93** scripts (excludes `check_helpers.sh`; includes standalone, report-only, and fixture scripts) |
| `CHECK_SCRIPTS` in `tool/delivery_checklist.sh` | **74** scripts in `./bin/checklist` static sweep — auto list: [`checklist_index.md`](checklist_index.md) |
| This catalog | Human-oriented index; one-line purpose + when to run |
| Guide shards | Long-form purpose, examples, suppressions — see [Contents](../validation_scripts.md#contents) |

Sync: `bash tool/validate_validation_docs.sh` requires every on-disk `tool/check_*.sh`
script except `check_helpers.sh` to appear in [`validation_scripts.md`](../validation_scripts.md)
or a `docs/validation_scripts/*.md` shard (not necessarily in this file), and
verifies the documented disk/checklist counts. After `CHECK_SCRIPTS` edits:
`bash tool/fix_validation_docs.sh` then validate.

**Not in `CHECK_SCRIPTS`:** checklist hooks include `check_regression_guards.sh`,
`check_action_bar_layout.sh`, and `check_docs_gardening.sh`; agent/design lanes
use `check_design_md.sh`. See [Supplemental scripts](#supplemental-and-adjacent-scripts)
below.

## Existing Validation Scripts

### Architecture & Dependency Injection

- **`check_flutter_domain_imports.sh`**: Ensures domain layer is Flutter-agnostic (no `package:flutter` imports)
- **`check_clean_architecture_imports.sh`**: Enforces feature/shared import
  boundaries for both `package:` and relative imports/exports. Domain cannot
  import Flutter, SDK/DI/app/data/presentation paths; presentation cannot import
  data; data cannot import presentation; shared cannot import features. Supports
  `--paths` fixture/focused runs and `check-ignore`.
- **`check_feature_folder_contract.sh`**: Enforces feature folder shape:
  cubit/state under `presentation/cubit/` (or legacy `cubits/`); bans
  `application/`, `infrastructure/`, `viewmodels/`, `providers/` top-level
  layers. Legacy drift under `lib/features` warns; `--strict` fails. Supports
  `--paths` fixture runs. Included in `./bin/checklist`.
- **`check_direct_getit.sh`**: Prevents direct `GetIt` access in presentation widgets (should inject via constructors/cubits). Note: demo-only feature folders (`*_demo`) are excluded.
- **`check_no_hive_openbox.sh`**: Prevents direct `Hive.openBox` usage (should use `HiveService`/`HiveRepositoryBase`)
- **`check_unvalidated_base_url_parse.sh`**: Prevents `Uri.parse(...)` directly on dynamic `baseUrl`-like values without validation helper
- **`check_auth_refresh_single_flight.sh`**: Detects auth retry anti-patterns that can cause 401 refresh races (e.g. `refreshToken()` followed by retry `forceRefresh: true`) and ensures serialized refresh gate exists in `AuthTokenManager`
- **`check_solid_presentation_data_imports.sh`**: Prevents presentation importing data-layer types (DIP)
- **`check_solid_data_presentation_imports.sh`**: Prevents data layer importing presentation (layering)
- **`check_feature_brief_linked.sh`**: When `lib/features/**/*.dart` changes vs a git base,
  requires a matching `docs/changes/*.md` note (Feature Brief / change log). Fails
  by default; `FEATURE_BRIEF_CHECK_STRICT=0` warns; `SKIP_FEATURE_BRIEF=1`
  skips. Included in `./bin/checklist`. See [`docs/plans/FEATURE_TEMPLATE.md`](../plans/FEATURE_TEMPLATE.md).
- **`check_feature_modularity_leaks.sh`**: Declarative cross-feature `package:` rules
  (`library_demo` / `scapes`, `settings` / `graphql_demo|profile|remote_config`,
  `remote_config` / `settings`). **Universal failures:** `lib/shared/**` must not
  import `package:flutter_bloc_app/features/`; `lib/features/*/domain/**` must not
  `import` Flutter, `get_it`, Hive, Supabase, Dio, Retrofit, `app/`, `core/di/`, or
  other features’ `presentation/` / `data/` paths (generated `*.g.dart` /
  `*.freezed.dart` / `*.gr.dart` excluded). Without `rg`, domain pattern checks are
  skipped (install ripgrep for full coverage). See [modularity.md](../modularity.md).
  Included in `./bin/checklist`.
- **`check_domain_wire_leaks.sh`**: Warn-only scan for `fromJson`/`toJson` in
  `lib/features/*/domain` (AP-11). Always exit 0; use during DTO/boundary PRs.
  See [`architecture/reduce_surprise_patterns.md`](../architecture/reduce_surprise_patterns.md).
  Not in `./bin/checklist`.
  shared→feature probe, domain→app/di probe, fan-in heuristics, cross-feature import
  report). Usage: `bash tool/modular_metrics.sh` or `--cross-feature-only`.
- **`check_feature_barrel_exports.sh`**: **Report-only** (always exit 0). Summarizes
  `lib/app/**` imports that reach into feature `presentation/`, `data/`, or `domain/`
  (barrel migration backlog). Not in `./bin/checklist` by default.
- **`check_macos_debug_web_guard.sh`**: Ensures macOS debug-only fallbacks that check `defaultTargetPlatform == TargetPlatform.macOS` also include `!kIsWeb`, so Safari/Chrome on macOS do not inherit desktop-only debug behavior. Uses `rg` when available, falls back to `grep`.
- **`check_apple_debug_hive_storage.sh`**: Guards Apple-platform debug Hive +
  secret-storage invariants (`useInMemorySecretStorageInDebug`, `hive_ios_debug`,
  stable `_appleDebugFallbackKey`, iOS debug tests). Prevents Keychain -34018 and
  `Recovering corrupted box.` regressions. See
  [`engineering/apple_debug_hive_storage.md`](../engineering/apple_debug_hive_storage.md).
- **`check_ios_pod_framework_embed.sh`**: After an iOS simulator build,
  verifies `Runner.app/Frameworks` contains every CocoaPods framework from
  `Pods-Runner-frameworks-Debug-input-files.xcfilelist` and every
  `@rpath/*.framework` referenced by `Runner.debug.dylib`. Skips when the
  CocoaPods input list or simulator app is absent unless `--require-built-app`
  is passed; use
  `--self-test` for the no-trailing-newline fixture.
- **`check_runtime_errors.sh`**: Optional local preflight — reads VM runtime
  errors via `dart mcp-server` (`script/mcp_runtime_errors.js`). Skips (exit 0)
  when no DTD or no connected debug app; `--strict` fails in that case. Not in
  `./bin/checklist`. See [`agent_kb/devtools_runtime_errors.md`](../agent_kb/devtools_runtime_errors.md).
- **`check_flutter_layout_overflows.sh`**: Runs a small, high-signal Flutter test
  set under a **global fail-fast overflow guard** (wired in
  `test/flutter_test_config.dart`). Fails the checklist on `RenderFlex` /
  `RenderParagraph` overflow errors that can otherwise slip into manual web QA.
- **`check_agent_knowledge_base.sh`**: Keeps AI-agent map/source-doc/host-template pointers indexed; fails if [`AGENTS.md`](../../AGENTS.md) grows past limit or required progressive-disclosure, memory-compounding, or closed-loop invariants disappear.
- **`check_ai_failure_risk_register.sh`**: Ensures
  [`ai_failure_risks.md`](../ai/ai_failure_risks.md) keeps required Cursor/Codex
  failure IDs and proof commands for prevention, detection, and recovery.
- **`check_design_md.sh`**: Runs Google DesignMD lint for root
  `../DESIGN.md`. Use after visual-brief changes; keep runtime
  values in `AppTheme`, `buildAppMixScope`, `AppStyles`, and `UI` aligned with
  [`design_system.md`](../design_system.md).
- **`check_agent_memory_compounding.sh`**: Safe deterministic guard for memory-compounding automation; ensures reusable conclusions route to durable repo memory, source/host-template pointers stay aligned, and autonomous cron/action guidance still requires explicit user approval.
- **`agent_memory_auto_maintain.sh`**: Safe automatic upkeep — `--verify` (invariants; runs after `sync_agent_assets.sh --apply`), `--if-changed` / `--fix-links` (local-only markdown link normalize on agent-scope paths; invoked from `check_agent_knowledge_base.sh`), and report-only `--codex-memory-health` for `~/.codex/memories` size/automation status. No compress/trim/host-memory writes. Opt-out: `AGENT_MEMORY_AUTO_MAINTAIN=0`; optional local report hook: `AGENT_MEMORY_CODEX_HEALTH=1`.
- **`check_docs_gardening.sh`**: Cheap doc-rot check for agent-facing markdown; verifies backticked `*.md` references best-effort and keeps [`validation_scripts.md`](../validation_scripts.md) aligned with `tool/delivery_checklist.sh`.
- **`check_transcript_budgets.sh`**: Report-only transcript inventory + budget signal to prevent conversation/transcript bloat from silently dominating agent context. Requires `CURSOR_AGENT_TRANSCRIPTS_ROOT` (local-only). Writes inventory JSON under `docs/audits/` (gitignored). Also runs from `./bin/checklist-fast` when the env var is set (never fails the checklist).
- **`validate_task_trackers.sh`**: Validates `tasks/*/todo.md` tracker contract: required headings, non-empty write set, validation command.
- **`run_harness_fixtures.sh`**: Smoke tests harness scripts and negative-case fixtures; runs in `./bin/checklist-fast` and docs/tooling lanes.
- **`check_tracked_secret_literals.sh`**: Scans tracked files for secret-looking literals that GitHub secret scanning commonly flags, including Google API keys, OpenAI-style keys, AWS access keys, and private key blocks. Output names file/line/rule only and never prints the secret value. Does not scan git history; for history scrub after a leak, see [`firebase_setup.md`](../firebase_setup.md#secret-scanning-alerts) and [`tool/firebase_secret_history_replacements.txt`](../tool/firebase_secret_history_replacements.txt).
- **`check_ai_generated_code_smells.sh`**: High-signal AI-code smell scan: secret-looking literals, swallowed exceptions, obvious SQL string interpolation, and risky Supabase Edge `verify_jwt = false`. Uses `check-ignore: <reason>` allowlist and fixtures under `tool/fixtures/ai_generated_code_smells/`.
  - **Limitation (intentional)**: `verify_jwt = false` is enforced via TOML section parsing only (`[functions.<name>]`). It does not detect equivalent behavior in deploy flags/scripts/docs/MCP payloads unless those surfaces are added explicitly.

### Quality theme gates (checklist MVP + promoted warn gates)

Checklist scripts extend `./bin/checklist` with navigation/sync-io/image-cache/cubit-subscription fail gates plus warn-first route/lifecycle gates. Theme labels align with `CHECK_SCRIPT_THEMES` in `tool/delivery_checklist.sh` (use `CHECKLIST_EXPLAIN_THEMES=1` to print mapping).

| Theme (representative) | Existing coverage | New / wired in MVP |
| --- | --- | --- |
| Architecture / layering | domain imports, SOLID imports, modularity | **fail** `check_navigation_outside_presentation.sh` |
| Rebuild / widget trees | context read/watch, widget identity, row overflow | **fail** `file_too_long` via `file_length_lint` plugin (`./tool/run_file_length_lint.sh`); (deferred: bloc rebuild scoping) |
| Blocking main isolate | compute/isolate guards | **fail** `check_sync_io_in_presentation.sh` (presentation only) |
| Images / cache | raw network images, image cache width | **fail** `check_remote_image_cache_hints.sh` |
| State management | cubit isClosed, dynamic list safety | **fail** `check_cubit_subscription_cancel.sh` |
| Async / boundaries | post-async mounted, stream dispose, concurrent modification | existing scripts |
| Navigation | router feature validate (path-triggered from checklist) | checklist hook + `./bin/router_feature_validate`; **fail** `check_deferred_heavy_routes.sh` |
| Memory / lifecycle | memory scripts, lifecycle error handling | **fail** `check_lifecycle_observer_dispose.sh` |
| Background / startup | background sync coordinator test, perf scripts | regression test added; startup gate deferred |

- **`check_navigation_outside_presentation.sh`**: GoRouter / `context.go` etc. only in presentation; scans `lib/features/**/{domain,data}/**` and `lib/shared/**/{domain,data}/**`. `check-ignore` supported. Fixtures: `tool/fixtures/navigation_outside_presentation/`.
- **`check_sync_io_in_presentation.sh`**: Blocking `dart:io` `*Sync` in `lib/**/presentation/**` only (not data-layer `existsSync`). Fixtures under `tool/fixtures/sync_io_in_presentation/presentation/`.
- **`check_remote_image_cache_hints.sh`**: Flags `CachedNetworkImageWidget` with explicit `width`/`height` but no `memCacheWidth`/`memCacheHeight`. Exits 1 on violations (promoted from warn-only, 2026-06-03).
- **`check_cubit_subscription_cancel.sh`**: Heuristics for `StreamSubscription` / `CubitSubscriptionMixin` / `registerSubscription` when `.listen(` is used. Exits 1 on violations (promoted from warn-only, 2026-06-03).
- **`check_lifecycle_observer_dispose.sh`**: Fail-by-default `WidgetsBindingObserver` guard. Scans for `addObserver(this)` without `removeObserver(this)`; use `CHECK_LIFECYCLE_OBSERVER_MODE=warn` to soften locally. Fixtures: `tool/fixtures/lifecycle_observer_dispose/`.
- **`check_deferred_heavy_routes.sh`**: Fail-by-default deferred route import allowlist. Deferred imports must stay in `lib/app/router/route_groups.dart` / `lib/app/router/routes_core.dart`; use `CHECK_DEFERRED_HEAVY_ROUTES_MODE=warn` to soften locally. Fixtures: `tool/fixtures/deferred_heavy_routes/`.
- **`run_file_length_lint.sh`**: Fail when `tool/check_file_length_physical.py` reports `FILE_TOO_LONG` under `lib/` (max 225 **physical** lines from `file_length_lint:` in `analysis_options.yaml`; same policy as the native plugin without whole-repo `dart analyze`). Skipped with `SKIP_FILE_LENGTH_LINT=1` or `CHECKLIST_RUN_FILE_LENGTH_LINT=0`. Plugin diagnostics may still appear in `flutter analyze` when enabled.
- **`run_mix_lint.sh`**: Fail when `dart analyze --format machine lib` reports `mix_*` diagnostics (native `mix_lint` plugin). Scoped to `lib/`, 600s timeout, heartbeat logs; hard-fails plugin/crash output. Skipped with `SKIP_MIX_LINT=1` or `CHECKLIST_RUN_MIX_LINT=0`.
- **`run_file_length_lint_test.py`**: Regression harness for file-length wiring (`python3 tool/run_file_length_lint_test.py`). Probes must use physical newlines (`wc -l` ≥ 226), not many `//` tokens on one line. Checklist auto-runs when `custom_lints/file_length_lint/**`, `analysis_options.yaml`, or the lint scripts change (`CHECKLIST_RUN_FILE_LENGTH_LINT_INTEGRATION_TEST=auto|0|1`).

Baseline counts: [`docs/plans/checklist_quality_gates_baseline.md`](../plans/checklist_quality_gates_baseline.md).

**Deferred / not in MVP:** [`docs/plans/checklist_quality_gates_deferred.md`](../plans/checklist_quality_gates_deferred.md)
(`bloc_lint`, rebuild scoping, context read/watch, startup-in-build,
`CHECK_THEME` filter; lib-wide sync-io **rejected**).

### Integration testing

- **`run_integration_tests.sh`** (entry: `./bin/integration_tests`): iOS simulator
  integration tiers, artifacts under `artifacts/integration/`, selective target
  resolution. Optional CocoaPods fallback: commit **`tool/pod_shim/pod`** (executable);
  enabled when `INTEGRATION_TESTS_ALLOW_POD_SHIM=1` (default) and
  `ios/Podfile.lock` matches `ios/Pods/Manifest.lock`. Contract:
  [`integration_runner_contract.md`](../engineering/integration_runner_contract.md).
- After `flutter build ios --simulator --debug`, run
  `tool/check_ios_pod_framework_embed.sh --require-built-app` to catch missing
  embedded frameworks before simulator launch/dyld failures.

**Router companion inside checklist:** After static checks, `./bin/checklist` may run `./bin/router_feature_validate` when changed files match [`.cursor/rules/router-feature-validation.mdc`](../.cursor/rules/router-feature-validation.mdc) globs (same rules as `tool/check_router_trigger_precision.sh`). Expect extra time when router/auth UI changes. Skip locally: `CHECKLIST_SKIP_ROUTER_VALIDATE=1`.

**Fixture proof (per new gate):**

```bash
# Navigation (fail) — bad=1, suppressed=0
bash tool/check_navigation_outside_presentation.sh --paths tool/fixtures/navigation_outside_presentation/domain/bad.dart
bash tool/check_navigation_outside_presentation.sh --paths tool/fixtures/navigation_outside_presentation/domain/suppressed.dart

# Sync-io presentation (fail) — bad=1, suppressed=0
bash tool/check_sync_io_in_presentation.sh --paths tool/fixtures/sync_io_in_presentation/presentation/bad.dart
bash tool/check_sync_io_in_presentation.sh --paths tool/fixtures/sync_io_in_presentation/presentation/suppressed.dart

# Image cache hints (fail) — bad=1, suppressed=0
bash tool/check_remote_image_cache_hints.sh --paths tool/fixtures/remote_image_cache_hints/presentation/bad.dart
bash tool/check_remote_image_cache_hints.sh --paths tool/fixtures/remote_image_cache_hints/presentation/suppressed.dart

# Cubit subscription (fail) — bad=1, suppressed=0
bash tool/check_cubit_subscription_cancel.sh --paths tool/fixtures/cubit_subscription_cancel/presentation/bad_cubit.dart
bash tool/check_cubit_subscription_cancel.sh --paths tool/fixtures/cubit_subscription_cancel/presentation/suppressed_cubit.dart

# Lifecycle observer (warn by default; fail-mode fixture proof)
CHECK_LIFECYCLE_OBSERVER_MODE=fail bash tool/check_lifecycle_observer_dispose.sh --paths tool/fixtures/lifecycle_observer_dispose/presentation/good.dart
CHECK_LIFECYCLE_OBSERVER_MODE=fail bash tool/check_lifecycle_observer_dispose.sh --paths tool/fixtures/lifecycle_observer_dispose/presentation/bad.dart
CHECK_LIFECYCLE_OBSERVER_MODE=fail bash tool/check_lifecycle_observer_dispose.sh --paths tool/fixtures/lifecycle_observer_dispose/presentation/suppressed.dart

# Deferred heavy routes (warn by default; fail-mode fixture proof)
CHECK_DEFERRED_HEAVY_ROUTES_MODE=fail bash tool/check_deferred_heavy_routes.sh --paths tool/fixtures/deferred_heavy_routes/router/good.dart
CHECK_DEFERRED_HEAVY_ROUTES_MODE=fail bash tool/check_deferred_heavy_routes.sh --paths tool/fixtures/deferred_heavy_routes/router/bad.dart
```

`CHECKLIST_EXPLAIN_THEMES=1 ./bin/checklist` prints `explain|theme|…` per script when the theme array is configured.

### UI/UX Best Practices

- **`check_material_buttons.sh`**: Prevents raw Material buttons (`ElevatedButton`, `OutlinedButton`, `TextButton`) - should use `PlatformAdaptive.*` helpers. Scope: flags widget constructors only (not `*.styleFrom`), excludes demo-only feature folders (`*_demo`).
- **`check_raw_dialogs.sh`**: Prevents raw dialog APIs - should use `showAdaptiveDialog()`
- **`check_raw_network_images.sh`**: Prevents raw `Image.network` usage - should use `CachedNetworkImageWidget`
- **`check_raw_print.sh`**: Prevents raw `print()`/`debugPrint()` usage - use
  `AppLogger` and [`logging.md`](../logging.md) conventions instead.
- **`check_raw_google_fonts.sh`**: Prevents per-widget `GoogleFonts.*` usage - should define fonts in `app_config.dart`
- **`check_ui_regressions.sh`**: Runs focused widget regression tests to catch UI sizing/layout issues early (e.g. web scaling causing oversized icons, unstable controls, clipped text, or overlap)

### Performance

- **`check_perf_shrinkwrap_lists.sh`**: Flags `shrinkWrap: true` lists/grids in presentation code
- **`check_perf_nonbuilder_lists.sh`**: Flags likely dynamic `ListView`/`GridView` `children:` construction that eagerly builds rows. Small static/prebuilt section lists may use `children:` when that preserves stable widget identity.
- **`check_widget_identity.sh`**: Flags common widget identity traps (missing stable `key:` in builder row returns, `ObjectKey` in builder row returns, builder-by-index over prebuilt widget lists, `AnimatedSwitcher` children without explicit keyed identity, and dynamic `children:` lists that instantiate local `TextEditingController`/`FocusNode` owner widgets without keys). Prefer stable domain IDs via `ValueKey('row-$id')`; use `ListView(children: ...)` for static prebuilt widget lists. Suppress only with `// widget_identity:ignore <reason>` on the same or previous line.
- **`check_perf_missing_repaint_boundary.sh`**: Warns when heavy widgets lack `RepaintBoundary`
- **`check_perf_unnecessary_rebuilds.sh`**: Heuristic check for `setState()` calls that might cause unnecessary rebuilds/blinking (warns but doesn't fail)
- **`check_concurrent_modification.sh`**: Detects potential concurrent modification errors when iterating over collections from getters/properties
- **`check_live_state_list_indexing.sh`**: Prevents presentation builders from indexing live `state.items[index]`/`state.items.elementAt(index)` directly. Snapshot state list into local immutable list, use that snapshot for `itemCount`, and guard stale indexes before indexing.
- **`check_select_state_allocating_getters.sh`**: Prevents selectors from reading presentation state list getters that allocate via `.toList()`, which returns a fresh list reference on each emission and defeats selector rebuild filtering. Use value-equality view data, selector-local filtering, or memoization instead.

### Compute/Isolate Usage

- **`check_raw_json_decode.sh`**: Prevents raw `jsonDecode()`/`jsonEncode()` usage - should use `decodeJsonMap()`/`decodeJsonList()`/`encodeJsonIsolate()` for large payloads (>8KB)
- **`check_compute_domain_layer.sh`**: Prevents `compute()` usage in domain layer (domain should be Flutter-agnostic)
- **`check_compute_lifecycle.sh`**: Heuristic check for `compute()` usage in lifecycle methods (`build()`, `performLayout()`) - warns but doesn't fail
- **`check_no_isolate_run_in_presentation.sh`**: Prevents `Isolate.run` under `lib/**/presentation/**`. Closures from `State`/widgets often capture non-sendable Flutter objects and crash with *illegal argument in isolate message*; use `compute(topLevelOrStaticCallback, message)` from `package:flutter/foundation.dart` instead (see `lib/shared/utils/isolate_json.dart`). Suppress with `check-ignore` on same or previous line only for rare, reviewed cases.

### Timing & Services

- **`check_raw_timer.sh`**: Prevents raw `Timer` usage - should use `TimerService` for testability
- **`check_raw_future_delayed.sh`**: Flags `Future.delayed` in production `lib/` - prefer `TimerService.runOnce` where cancellation or test control matters (see [`engineering/delayed_work_guide.md`](../engineering/delayed_work_guide.md))
- **`check_tool_dart_async_main_blocking_io.sh`**: In `tool/**/*.dart` files whose entrypoint is **`main(...) async`**, fails on common blocking dart:io / `FileSystemEntity` `*Sync` calls (`statSync`, `existsSync`, `readAsStringSync`, `readAsLinesSync`, `writeAsStringSync`, `listSync`, `typeSync`, `createSync`, `deleteSync`, `renameSync`, `copySync`, `lastModifiedSync`, etc.). Sync-only codegen CLIs are out of scope. Prefer `await file.readAsString()`, `await file.exists()`, `Directory.list()`, `FileSystemEntity.type()`, etc. Use `--paths PATH...` for fixture/focused checks. Suppress only with `check-ignore` on the same or previous line when intentional.

### Widget Lifecycle

- **`check_side_effects_build.sh`**: Heuristic check for side effects in `build()` method (warns but doesn't fail)
- **`check_dialog_controller_dispose.sh`**: Heuristic check for `TextEditingController` with `showDialog`/`showAdaptiveDialog` and dispose in `finally` (can cause "used after being disposed")
- **`check_dialog_text_controller_lifecycle.sh`**: Flags `final`/`var` locals assigned `TextEditingController(` inside `async` blocks when same file uses dialog APIs (prefer Stateful dialog + `initState`/`dispose`)
- **`check_memory_pressure_centralized.sh`**: Ensures `didHaveMemoryPressure()` handling stays centralized in `lib/app/app_scope.dart` so automatic memory trimming is coordinated through app shell
- **`check_pyright_python.sh`**: Runs **Pyright** via `npx pyright` on `demos/render_chat_api` and repo `tool/` Python. Bootstraps `demos/render_chat_api/.venv` from `requirements.txt` when missing (so CI and fresh clones stay reproducible). Fails if `pyrightconfig.json` nests `venvPath` / `venv` under `executionEnvironments` (invalid; use top-level keys). Keep repo-root `exclude` including `**/.venv` so site-packages are not type-checked. Standalone runs always execute; inside `./bin/checklist`, script auto-skips on local non-Python change sets, but still runs in CI or when Python-related files changed. See [`demos/render_chat_api/README.md`](../../demos/render_chat_api/README.md) for editor setup.
- **`check_inherited_widget_in_create.sh`**: Prevents `context.l10n`/`Theme.of(context)` inside BlocProvider/Provider `create` (see Context & Async Safety below)
- **`check_inherited_widget_in_initstate.sh`**: Prevents InheritedWidget reads (e.g. `context.l10n`, `Theme.of(context)`) in `initState()`; read in `build()` or `didChangeDependencies()` instead.
- **`check_lifecycle_error_handling.sh`**: Snackbar via ErrorHandling, `stream.listen` onError, `context.mounted` after show\*Dialog (see Context & Async Safety below)
- **`check_offline_first_remote_merge.sh`**: Early regression guard ensuring offline-first repos don't overwrite newer state with stale sync data (older remote snapshots, TOCTOU races between merge snapshot and save/delete, or older queued pending replay). Inventory scan also matches `re-checks local before save|deleting` and remote-fetch-failure retention tests. Fails when matching regression test files exist but are not wired into the guard. Standalone runs always execute; inside `./bin/checklist`, script auto-skips on local change sets that don't touch offline-first surfaces, but still runs in CI or when relevant files changed.
- **`check_remote_fetch_failure_fallback.sh`**: Static guard: remote read ops (`fetchAll`, `load`, …) must not use `onFailureFallback` (empty/default fallbacks look like successful empty remotes and can cause offline-first mass-delete on transient errors). See [`offline_first/dont_overwrite_guide.md`](../offline_first/dont_overwrite_guide.md) § Remote fetch failures.

### Context & async safety (checklist; detail in guide shard)

Long-form examples: [`guides_context_async.md`](guides_context_async.md).

- **`check_context_mounted.sh`**: `context.mounted` before `Navigator` / `context.read` / `ScaffoldMessenger` after `await`
- **`check_setstate_mounted.sh`**: `mounted` before `setState` after `await`
- **`check_setstate_async.sh`**: Blocks `setState(() async { ... })` (async setState callbacks)

### Theme, l10n, const (checklist; detail in guide shards)

- **`check_hardcoded_colors.sh`**, **`check_hardcoded_strings.sh`**, **`check_missing_localizations.sh`**: Theme/l10n hygiene — [`guides_theme_l10n.md`](guides_theme_l10n.md)
- **`check_missing_const.sh`**: Heuristic missing `const` on stable widgets — [`guides_performance_lists.md`](guides_performance_lists.md)
- **`check_pubspec_codegen_compat.sh`**: Fails on known-incompatible `pubspec.yaml` / lock combos for `build_runner` + analyzer (e.g. `json_serializable` vs `mix_lint`)

### State, layout, memory (checklist; detail in guide shards)

- **`check_freezed_preferred.sh`**, **`check_cubit_isclosed.sh`**, **`check_unguarded_null_assertion.sh`**, **`check_row_text_overflow.sh`**, **`check_row_action_overflow.sh`**: State/layout guards — [`guides_state_layout.md`](guides_state_layout.md)
- **`check_memory_unclosed_streams.sh`**, **`check_memory_missing_dispose.sh`**: Stream/subscription and dispose heuristics — [`guides_memory_typography.md`](guides_memory_typography.md)

### Supplemental and adjacent scripts

Not listed in `CHECK_SCRIPTS`; run standalone, from checklist hooks, or report-only.

| Script | Typical invocation | Purpose |
| --- | --- | --- |
| `check_regression_guards.sh` | `./bin/checklist` (focused regression lane; subset on local feature diffs; RequestIdGuard/chat/call supersession, stream/cache hardening, and realtime trade-id paths run before coverage when selected); `CHECK_REGRESSION_GUARDS_MODE=auto … --paths FILE` for local repro | Runs fixed widget/unit regression tests for past lifecycle/race and data-integrity bugs |
| `check_action_bar_layout.sh` | `./bin/checklist` when `CHECKLIST_RUN_ACTION_BAR_LAYOUT_TESTS` is `auto` or `1` | Widget tests for action-bar / icon-label row layout regressions |
| `check_docs_gardening.sh` | `./bin/checklist-fast`, docs/tooling lanes | Doc link rot + `validate_validation_docs.sh` |
| `check_design_md.sh` | Design/agent lane | Google DesignMD lint on root [`DESIGN.md`](../../DESIGN.md) |
| `check_router_trigger_precision.sh` | Manual / scorecard | Benchmarks router-feature-validation globs vs `analysis/agent_scorecard/router_trigger_benchmark_v1.json` |
| `check_agent_asset_drift.sh` | `./bin/checklist-fast` when templates exist; via `agent-maintain` | Repo vs managed Cursor/Codex host asset drift |
| `agent_maintain.sh` | `./bin/agent-maintain` | Host upkeep router (`preflight`, scope `closeout`/`docs-sync`, `after-host-edit`, globals); policy [`host_maintenance_automation.md`](../agent_kb/host_maintenance_automation.md) |
| `check_checklist_cli_contract.sh` | Manual / harness | `./bin/checklist` / `checklist-fast` / `agent-maintain` CLI contract smoke |
| `check_bundle_size.sh` | Manual / release | APK/AAB/iOS size vs budgets; writes `.bundle_sizes.json` |
| `check_hive_schema_fingerprints.sh` | Manual / CI opt-in | `generate_hive_schema_fingerprints.dart --check-*`; optional `HIVE_SCHEMA_ENFORCE_INPUTS=true` |
| `check_integration_rollout_threshold.sh` | Integration scorecard | Gates flake/success vs `analysis/agent_scorecard/summaries/integration-baseline.json` |
| `check_delegate_wrapper_contracts.sh` | Manual | Delegate wrapper contract tests |
| `check_continual_learning_index.sh` | Agent memory lane | Continual-learning index invariants |
| `check_skill_budgets.sh` | Manual | Token budgets for skill inventory JSON — [`operations_host_skills.md`](operations_host_skills.md) |
| `audit_vendor_plugin_skills.sh` | Manual | Marketplace plugin skill rollup (`vendor_plugin_inventory_latest.json`) — [`operations_host_skills.md`](operations_host_skills.md) |
| `skill_vendor_plugin_inventory.dart` | Manual | Dart entry for vendor plugin audit — [`operations_host_skills.md`](operations_host_skills.md) |
| `check_todo_keyboard_layout.sh` | Manual | Todo keyboard layout regression lane |
| `check_row_action_overflow_fixtures.sh` | Self-test for `check_row_action_overflow.sh` | Fixture proof only (not a product guard) |
| `check_domain_wire_leaks.sh` | Manual / DTO boundary PRs | Warn-only domain `fromJson`/`toJson` scan (AP-11) |

Report-only / optional (also in Architecture section above): `check_feature_barrel_exports.sh`, `check_transcript_budgets.sh`, `check_domain_wire_leaks.sh`.
