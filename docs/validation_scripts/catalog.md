# Validation scripts — catalog

Router: [`../validation_scripts.md`](../validation_scripts.md).

## Existing Validation Scripts

### Architecture & Dependency Injection

- **`check_flutter_domain_imports.sh`**: Ensures domain layer is Flutter-agnostic (no `package:flutter` imports)
- **`check_direct_getit.sh`**: Prevents direct `GetIt` access in presentation widgets (should inject via constructors/cubits). Note: demo-only feature folders (`*_demo`) are excluded.
- **`check_no_hive_openbox.sh`**: Prevents direct `Hive.openBox` usage (should use `HiveService`/`HiveRepositoryBase`)
- **`check_unvalidated_base_url_parse.sh`**: Prevents `Uri.parse(...)` directly on dynamic `baseUrl`-like values without validation helper
- **`check_auth_refresh_single_flight.sh`**: Detects auth retry anti-patterns that can cause 401 refresh races (e.g. `refreshToken()` followed by retry `forceRefresh: true`) and ensures serialized refresh gate exists in `AuthTokenManager`
- **`check_solid_presentation_data_imports.sh`**: Prevents presentation importing data-layer types (DIP)
- **`check_solid_data_presentation_imports.sh`**: Prevents data layer importing presentation (layering)
- **`check_feature_brief_linked.sh`**: When `lib/features/**/*.dart` changes vs a git base,
  requires a matching `docs/changes/*.md` note (Feature Brief / change log). **Warn**
  by default (exit 0); `FEATURE_BRIEF_CHECK_STRICT=1` fails; `SKIP_FEATURE_BRIEF=1`
  skips. Not in `./bin/checklist` by default. See [`docs/plans/FEATURE_TEMPLATE.md`](../plans/FEATURE_TEMPLATE.md).
- **`check_feature_modularity_leaks.sh`**: Declarative cross-feature `package:` rules
  (`library_demo` / `scapes`, `settings` / `graphql_demo|profile|remote_config`,
  `remote_config` / `settings`). **Universal failures:** `lib/shared/**` must not
  import `package:flutter_bloc_app/features/`; `lib/features/*/domain/**` must not
  `import` Flutter, `get_it`, Hive, Supabase, Dio, Retrofit, `app/`, `core/di/`, or
  other features’ `presentation/` / `data/` paths (generated `*.g.dart` /
  `*.freezed.dart` / `*.gr.dart` excluded). Without `rg`, domain pattern checks are
  skipped (install ripgrep for full coverage). See [modularity.md](../modularity.md).
  Included in `./bin/checklist`.
- **`modular_metrics.sh`**: Read-only modular baseline (per-feature LOC, barrels,
  shared→feature probe, domain→app/di probe, fan-in heuristics, cross-feature import
  report). Usage: `bash tool/modular_metrics.sh` or `--cross-feature-only`.
- **`check_feature_barrel_exports.sh`**: **Report-only** (always exit 0). Summarizes
  `lib/app/**` imports that reach into feature `presentation/`, `data/`, or `domain/`
  (barrel migration backlog). Not in `./bin/checklist` by default.
- **`check_macos_debug_web_guard.sh`**: Ensures macOS debug-only fallbacks that check `defaultTargetPlatform == TargetPlatform.macOS` also include `!kIsWeb`, so Safari/Chrome on macOS do not inherit desktop-only debug behavior. Uses `rg` when available, falls back to `grep`.
- **`check_agent_knowledge_base.sh`**: Keeps AI-agent map/source-doc/host-template pointers indexed; fails if [`AGENTS.md`](../../AGENTS.md) grows past limit or required progressive-disclosure, memory-compounding, or closed-loop invariants disappear.
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

### Quality theme gates (checklist MVP, May 2026)

Four scripts extend `./bin/checklist` with navigation/sync-io fail gates and warn-only hygiene scans. Theme labels align with `CHECK_SCRIPT_THEMES` in `tool/delivery_checklist.sh` (use `CHECKLIST_EXPLAIN_THEMES=1` to print mapping).

| Theme (representative) | Existing coverage | New / wired in MVP |
| --- | --- | --- |
| Architecture / layering | domain imports, SOLID imports, modularity | **fail** `check_navigation_outside_presentation.sh` |
| Rebuild / widget trees | context read/watch, widget identity, row overflow | (deferred: bloc rebuild scoping) |
| Blocking main isolate | compute/isolate guards | **fail** `check_sync_io_in_presentation.sh` (presentation only) |
| Images / cache | raw network images, image cache width | **warn** `check_remote_image_cache_hints.sh` |
| State management | cubit isClosed, dynamic list safety | **warn** `check_cubit_subscription_cancel.sh` |
| Async / boundaries | post-async mounted, stream dispose, concurrent modification | existing scripts |
| Navigation | router feature validate (path-triggered from checklist) | checklist hook + `./bin/router_feature_validate` |
| Memory / lifecycle | memory scripts, lifecycle error handling | existing scripts |
| Background / startup | background sync coordinator test, perf scripts | regression test added; startup gate deferred |

- **`check_navigation_outside_presentation.sh`**: GoRouter / `context.go` etc. only in presentation; scans `lib/features/**/{domain,data}/**` and `lib/shared/**/{domain,data}/**`. `check-ignore` supported. Fixtures: `tool/fixtures/navigation_outside_presentation/`.
- **`check_sync_io_in_presentation.sh`**: Blocking `dart:io` `*Sync` in `lib/**/presentation/**` only (not data-layer `existsSync`). Fixtures under `tool/fixtures/sync_io_in_presentation/presentation/`.
- **`check_remote_image_cache_hints.sh`**: Warn-only; flags `CachedNetworkImageWidget` with explicit `width`/`height` but no `memCacheWidth`/`memCacheHeight`. Always exit 0.
- **`check_cubit_subscription_cancel.sh`**: Warn-only; heuristics for `StreamSubscription` / `CubitSubscriptionMixin` / `registerSubscription`. Always exit 0.

Baseline counts: [`docs/plans/checklist_quality_gates_baseline.md`](../plans/checklist_quality_gates_baseline.md).

**Deferred / not in MVP:** [`docs/plans/checklist_quality_gates_deferred.md`](../plans/checklist_quality_gates_deferred.md)
(`bloc_lint`, file length, rebuild scoping, context read/watch, deferred-route heuristic,
startup-in-build, lifecycle observer, `CHECK_THEME` filter, warn→fail promotion; lib-wide sync-io **rejected**).

**Router companion inside checklist:** After static checks, `./bin/checklist` may run `./bin/router_feature_validate` when changed files match [`.cursor/rules/router-feature-validation.mdc`](../.cursor/rules/router-feature-validation.mdc) globs (same rules as `tool/check_router_trigger_precision.sh`). Expect extra time when router/auth UI changes. Skip locally: `CHECKLIST_SKIP_ROUTER_VALIDATE=1`.

**Fixture proof (per new gate):**

```bash
# Navigation (fail) — bad=1, suppressed=0
bash tool/check_navigation_outside_presentation.sh --paths tool/fixtures/navigation_outside_presentation/domain/bad.dart
bash tool/check_navigation_outside_presentation.sh --paths tool/fixtures/navigation_outside_presentation/domain/suppressed.dart

# Sync-io presentation (fail) — bad=1, suppressed=0
bash tool/check_sync_io_in_presentation.sh --paths tool/fixtures/sync_io_in_presentation/presentation/bad.dart
bash tool/check_sync_io_in_presentation.sh --paths tool/fixtures/sync_io_in_presentation/presentation/suppressed.dart

# Warn gates — always exit 0; fixture bad emits count/sample, suppressed is ignored
bash tool/check_remote_image_cache_hints.sh --paths tool/fixtures/remote_image_cache_hints/presentation/bad.dart
bash tool/check_remote_image_cache_hints.sh --paths tool/fixtures/remote_image_cache_hints/presentation/suppressed.dart
bash tool/check_cubit_subscription_cancel.sh --paths tool/fixtures/cubit_subscription_cancel/presentation/bad_cubit.dart
bash tool/check_cubit_subscription_cancel.sh --paths tool/fixtures/cubit_subscription_cancel/presentation/suppressed_cubit.dart
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
- **`check_widget_identity.sh`**: Flags common widget identity traps (missing stable `key:` in builder row returns, builder-by-index over prebuilt widget lists, `AnimatedSwitcher` children without explicit keyed identity, and dynamic `children:` lists that instantiate local `TextEditingController`/`FocusNode` owner widgets without keys). Prefer stable domain IDs via `ValueKey('row-$id')`; use `ListView(children: ...)` for static prebuilt widget lists. Suppress only with `// widget_identity:ignore <reason>` on the same or previous line.
- **`check_perf_missing_repaint_boundary.sh`**: Warns when heavy widgets lack `RepaintBoundary`
- **`check_perf_unnecessary_rebuilds.sh`**: Heuristic check for `setState()` calls that might cause unnecessary rebuilds/blinking (warns but doesn't fail)
- **`check_concurrent_modification.sh`**: Detects potential concurrent modification errors when iterating over collections from getters/properties
- **`check_live_state_list_indexing.sh`**: Prevents presentation builders from indexing live `state.items[index]`/`state.items.elementAt(index)` directly. Snapshot state list into local immutable list, use that snapshot for `itemCount`, and guard stale indexes before indexing.

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
- **`check_offline_first_remote_merge.sh`**: Regression tests ensuring offline-first repos don't overwrite newer unsynced local state with older remote (see Offline-first remote merge below). Standalone runs always execute; inside `./bin/checklist`, script auto-skips on local change sets that don't touch offline-first surfaces, but still runs in CI or when relevant files changed.
