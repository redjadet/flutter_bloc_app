# Senior quality hotspot audit — 2026-05-12

Point-in-time audit per plan *Senior-grade hotspot quality audit*. Hotspot scope only; behavior-preserving changes unless explicitly classified otherwise.

## Cursor execution mode (plan)

- Coordinator owns this audit doc, classification, validation matrix.
- **Team benefit (local tracker):** add to [`tasks/cursor/todo.md`](../../tasks/cursor/todo.md) when that file is used in your clone: *Benefit: team — independent hotspot scoring can run in parallel after seed commands complete* (that path is gitignored in this repo).

## Inputs and commands

### Hotspot recompute (run 2026-05-12)

**Churn (top paths, `lib` + `test`, excludes `*.freezed.dart`, `*.g.dart`, `lib/l10n/`):**

```bash
git log --format= --name-only -- lib test \
  | rg '\.dart$' \
  | rg -v '(\.freezed\.dart$|\.g\.dart$|^lib/l10n/)' \
  | sort | uniq -c | sort -nr | head -40
```

Notable vs plan seed: `lib/core/di/injector.dart` (43), `lib/app.dart` (40), `lib/features/counter/presentation/counter_cubit.dart` (38) rank high; plan’s explicit hotspot set retained for scoring depth. Watchlist for next audit: those three if they rise further.

**Largest hand-written Dart (`lib/`, excludes generated + l10n):**

```bash
find lib -name '*.dart' \
  ! -name '*.freezed.dart' ! -name '*.g.dart' ! -path '*/l10n/*' \
  -print0 | xargs -0 wc -l | sort -nr | head -40
```

Top `.part.dart` files align with plan (case_study_session_cubit_actions, walletconnect, offline_first_todo_repository_impl, secret_config_impl, etc.).

### Seed checks (machine log)

Full stdout/stderr and per-command exit codes: [`_senior_quality_hotspots_seed_2026-05-12.log`](_senior_quality_hotspots_seed_2026-05-12.log) (same directory; filename prefixed with `_`).

Summary: **all listed scripts exit 0**; `./tool/analyze.sh` exit 0 (`No issues found!` before this audit’s single edit). Scripts run:

| Script | Result |
| ------ | ------ |
| `tool/check_ai_generated_code_smells.sh` | pass (`no-targets`) |
| `tool/check_context_mounted.sh` | pass |
| `tool/check_cubit_isclosed.sh` | pass |
| `tool/check_dialog_controller_dispose.sh` | pass |
| `tool/check_concurrent_modification.sh` | pass |
| `tool/check_compute_lifecycle.sh` | pass |
| `tool/check_lifecycle_error_handling.sh` | pass |
| `tool/check_direct_getit.sh` | pass |
| `tool/check_no_hive_openbox.sh` | pass |
| `tool/check_raw_timer.sh` | pass |
| `tool/check_raw_future_delayed.sh` | pass |
| `tool/check_raw_print.sh` | pass |
| `tool/check_memory_missing_dispose.sh` | pass |
| `tool/check_perf_nonbuilder_lists.sh` | pass |
| `tool/check_live_state_list_indexing.sh` | pass |
| `tool/check_widget_identity.sh` | pass |
| `tool/check_hardcoded_colors.sh` | pass |
| `tool/check_missing_localizations.sh` | pass |
| `./tool/analyze.sh` | pass (pre-change) |

Evidence run (plan: `check_hardcoded_strings` for presentation/shared/app): `bash tool/check_hardcoded_strings.sh` → exit 0 (no violations).

## Confirmed hotspot list (scored)

1. `lib/features/counter/presentation/pages/counter_page.dart`
2. `lib/features/example/presentation/widgets/example_page_body.dart`
3. `lib/features/chat/presentation/widgets/chat_list_view.dart`
4. `lib/features/chat/presentation/widgets/chat_message_list.dart`
5. `lib/features/todo_list/presentation/pages/todo_list_page.dart`
6. `lib/features/settings/presentation/pages/settings_page.dart`
7. `lib/features/profile/presentation/pages/profile_page.dart`
8. `lib/features/search/presentation/pages/search_page.dart`
9. `lib/features/chat/presentation/pages/chat_page.dart`
10. `lib/features/counter/presentation/widgets/counter_sync_banner.dart`
11. `lib/core/di/injector_registrations.dart`
12. `lib/app/router/routes.dart`
13. `lib/core/router/app_routes.dart`
14. `lib/shared/sync/background_sync_coordinator.dart`
15. `lib/shared/utils/error_handling.dart`
16. `lib/shared/sync/pending_sync_repository.dart`
17. `lib/core/config/secret_config.dart`
18. `lib/features/todo_list/presentation/cubit/todo_list_cubit.dart`
19. `lib/features/todo_list/presentation/cubit/todo_list_cubit_methods.dart`
20. `lib/features/todo_list/data/offline_first_todo_repository.dart`
21. `lib/features/counter/data/rest_counter_repository_internal.dart`
22. `lib/features/case_study_demo/presentation/cubit/case_study_session_cubit_actions.part.dart`
23. `lib/features/walletconnect_auth/presentation/pages/walletconnect_auth_page_impl.part.dart`
24. `lib/features/todo_list/data/offline_first_todo_repository_impl.part.dart`
25. `lib/features/iot_demo/data/supabase_iot_demo_repository_impl.part.dart`
26. `lib/core/config/secret_config_impl.part.dart`
27. `lib/features/case_study_demo/presentation/pages/case_study_history_detail_page_impl.part.dart`
28. `lib/shared/utils/platform_adaptive_sheets.dart`
29. `lib/shared/utils/retry_policy.dart`

## Rubric (short)

- **Repo canon:** Clean architecture seams, Cubit state ownership, `get_it` at composition only, typed BLoC access, theme/design tokens, offline-first merge semantics, stream/timer safety.
- **Senior Flutter:** `mounted` / `isClosed`, no raw `Timer`/`Future.delayed` in forbidden places, no `Hive.openBox` outside service, no presentation GetIt, builder lists, dispose subscriptions, no swallowed errors, l10n for user strings, no stray `print`.

## Per-file findings

Convention: **Class** = `SAFE_TO_FIX_NOW` | `NEEDS_TEST_FIRST` | `BACKLOG_ONLY`. Spot checks: `rg` for `context.read`/`BlocProvider.of` (none in scored presentation hotspots); seed scripts green repo-wide.

| # | File | Severity | Class | Notes |
| --- | ------ | -------- | ----- | ----- |
| 1 | counter_page.dart | LOW | — | Matches churn leader; typed cubit access; no seed hits. |
| 2 | example_page_body.dart | LOW | — | No automated hits; structure consistent with example feature. |
| 3 | chat_list_view.dart | LOW | — | Large but focused; no non-builder list heuristic hit. |
| 4 | chat_message_list.dart | LOW | — | Stream/list patterns; tests exist (`test/chat_message_list_test.dart`). |
| 5 | todo_list_page.dart | LOW | — | No direct GetIt in presentation. |
| 6 | settings_page.dart | LOW | — | Auth-gated routes elsewhere; no change in this pass. |
| 7 | profile_page.dart | LOW | — | Same. |
| 8 | search_page.dart | LOW | — | Retry/search stacks use shared policy elsewhere. |
| 9 | chat_page.dart | LOW | — | No lifecycle script hits. |
| 10 | counter_sync_banner.dart | LOW | — | `mounted` checks; `onError` on listen; disposable bag. |
| 11 | injector_registrations.dart | LOW | — | Composition root; keep splits **BACKLOG** if file keeps growing. |
| 12 | routes.dart | LOW | — | Router churn; auth policy tested separately. |
| 13 | app_routes.dart | LOW | — | Policy surface; large edits = design review. |
| 14 | background_sync_coordinator.dart | LOW | — | TimerService + explicit subscription lifecycle. |
| 15 | error_handling.dart | LOW | — | `context.mounted` guards; ErrorHandling patterns. |
| 16 | pending_sync_repository.dart | LOW | — | Documented class; Hive schema fingerprint enforced. |
| 17 | secret_config.dart | LOW | **SAFE** | Missing library-level doc for shared entrypoint → added `library` + doc (Batch 1). |
| 18 | todo_list_cubit.dart | LOW | — | `isClosed` pattern enforced repo-wide. |
| 19 | todo_list_cubit_methods.dart | LOW | — | Split part for size; further split **BACKLOG**. |
| 20 | offline_first_todo_repository.dart | LOW | — | Offline-first; merge semantics **BACKLOG** on change. |
| 21 | rest_counter_repository_internal.dart | LOW | — | Internal REST helpers; no raw print. |
| 22 | case_study_session_cubit_actions.part.dart | MED | **BACKLOG** | ~385 LOC part; extract phases or sub-cubits needs design + tests. |
| 23 | walletconnect_auth_page_impl.part.dart | MED | **BACKLOG** | Large UI part; visual regression risk. |
| 24 | offline_first_todo_repository_impl.part.dart | MED | **BACKLOG** | Data correctness; any extract needs integration tests. |
| 25 | supabase_iot_demo_repository_impl.part.dart | MED | **BACKLOG** | Demo but sensitive; treat like production for refactors. |
| 26 | secret_config_impl.part.dart | MED | **BACKLOG** | Logic-heavy; test matrix before moves. |
| 27 | case_study_history_detail_page_impl.part.dart | MED | **BACKLOG** | UI + navigation; widget tests first. |
| 28 | platform_adaptive_sheets.dart | LOW | — | Shared adaptive UI; shrinkWrap audit already tracked elsewhere. |
| 29 | retry_policy.dart | LOW | — | Documents `Future.delayed` allow-list when `TimerService` null; intentional. |

## Appendix: Plan §3 finding records (`file:line`, proof, fix sketch)

Anchor `*:1` = whole-file review (no single-line rubric violation). Proof for all hotspots includes the seed bundle ([`_senior_quality_hotspots_seed_2026-05-12.log`](_senior_quality_hotspots_seed_2026-05-12.log)) plus `./tool/analyze.sh` (no issues). Additional per-row proof kept minimal where identical.

| File | Line | Severity | Class | Reason | Proof command | Fix sketch |
| ---- | ---- | -------- | ----- | ------ | ------------- | ---------- |
| `lib/features/counter/presentation/pages/counter_page.dart` | :1 | LOW | — | Churn hotspot; typed access; seed green | `./tool/analyze.sh` | none |
| `lib/features/example/presentation/widgets/example_page_body.dart` | :1 | LOW | — | Example body; seed green | `./tool/analyze.sh` | none |
| `lib/features/chat/presentation/widgets/chat_list_view.dart` | :1 | LOW | — | List patterns OK vs `check_perf_nonbuilder_lists` | `bash tool/check_perf_nonbuilder_lists.sh` | none |
| `lib/features/chat/presentation/widgets/chat_message_list.dart` | :1 | LOW | — | Has widget tests | `flutter test test/chat_message_list_test.dart` | none |
| `lib/features/todo_list/presentation/pages/todo_list_page.dart` | :1 | LOW | — | No presentation GetIt | `bash tool/check_direct_getit.sh` | none |
| `lib/features/settings/presentation/pages/settings_page.dart` | :1 | LOW | — | Seed green | `./tool/analyze.sh` | none |
| `lib/features/profile/presentation/pages/profile_page.dart` | :1 | LOW | — | Seed green | `./tool/analyze.sh` | none |
| `lib/features/search/presentation/pages/search_page.dart` | :1 | LOW | — | Seed green | `./tool/analyze.sh` | none |
| `lib/features/chat/presentation/pages/chat_page.dart` | :1 | LOW | — | Seed green | `./tool/analyze.sh` | none |
| `lib/features/counter/presentation/widgets/counter_sync_banner.dart` | :1 | LOW | — | `mounted` + `onError` on listen | `bash tool/check_context_mounted.sh` | none |
| `lib/core/di/injector_registrations.dart` | :1 | LOW | — | Composition root | `./tool/analyze.sh` | split registrations **BACKLOG** |
| `lib/app/router/routes.dart` | :1 | LOW | — | Router surface | `./bin/router_feature_validate` (if router edits) | none |
| `lib/core/router/app_routes.dart` | :1 | LOW | — | Policy definitions | `./tool/analyze.sh` | none |
| `lib/shared/sync/background_sync_coordinator.dart` | :1 | LOW | — | TimerService + streams | `bash tool/check_raw_timer.sh` | none |
| `lib/shared/utils/error_handling.dart` | :1 | LOW | — | `context.mounted` guards | `bash tool/check_context_mounted.sh` | none |
| `lib/shared/sync/pending_sync_repository.dart` | :1 | LOW | — | Hive via base; fingerprint | `bash tool/check_no_hive_openbox.sh` | none |
| `lib/core/config/secret_config.dart` | 1–4 | LOW | **SAFE** (applied) | Missing library doc → `library;` + summary | `dart analyze lib/core/config/secret_config.dart` | done (B1) |
| `lib/features/todo_list/presentation/cubit/todo_list_cubit.dart` | :1 | LOW | — | `isClosed` discipline repo-wide | `bash tool/check_cubit_isclosed.sh` | none |
| `lib/features/todo_list/presentation/cubit/todo_list_cubit_methods.dart` | :1 | LOW | — | Part file size | manual read | extract methods **BACKLOG** |
| `lib/features/todo_list/data/offline_first_todo_repository.dart` | :1 | LOW | — | Offline-first | `test/features/todo_list/data/offline_first_todo_repository_test.dart` | none |
| `lib/features/counter/data/rest_counter_repository_internal.dart` | :1 | LOW | — | Internal REST | `./tool/analyze.sh` | none |
| `lib/features/case_study_demo/presentation/cubit/case_study_session_cubit_actions.part.dart` | :1 | MED | **BACKLOG_ONLY** | ~385 LOC; hard to test splits | read + size | phased extract + tests |
| `lib/features/walletconnect_auth/presentation/pages/walletconnect_auth_page_impl.part.dart` | :1 | MED | **BACKLOG_ONLY** | Large UI part | read + size | widget/golden tests first |
| `lib/features/todo_list/data/offline_first_todo_repository_impl.part.dart` | :1 | MED | **BACKLOG_ONLY** | Data correctness risk | integration tests | defer |
| `lib/features/iot_demo/data/supabase_iot_demo_repository_impl.part.dart` | :1 | MED | **BACKLOG_ONLY** | Demo + Supabase | integration tests | defer |
| `lib/core/config/secret_config_impl.part.dart` | :1 | MED | **BACKLOG_ONLY** | Logic-heavy | unit tests matrix | defer |
| `lib/features/case_study_demo/presentation/pages/case_study_history_detail_page_impl.part.dart` | :1 | MED | **BACKLOG_ONLY** | UI + navigation | widget tests | defer |
| `lib/shared/utils/platform_adaptive_sheets.dart` | :1 | LOW | — | No shrinkWrap in presentation lists repo-wide | `bash tool/check_perf_shrinkwrap_lists.sh` | optional slivers **BACKLOG** |
| `lib/shared/utils/retry_policy.dart` | :1 | LOW | — | Documented `Future.delayed` fallback | `bash tool/check_raw_future_delayed.sh` | none |

**Repository note:** `.gitignore` contains `docs/audits/` for *untracked* noise; tracked audit files (like this one) are added with `git add -f docs/audits/<file>`.

## Classification summary

- **SAFE_TO_FIX_NOW applied:** 1 — library documentation on `secret_config.dart` (with `library;` to satisfy `dangling_library_doc_comments`).
- **NEEDS_TEST_FIRST:** 0 applied this pass (no narrow test-only edits queued).
- **BACKLOG_ONLY:** oversized `.part.dart` / potential splits / injector & router growth (see backlog).

## Approved fix batches

### Batch 1 (applied)

| ID | Finding | Files | Validation |
| -- | ------- | ----- | ---------- |
| B1 | Library doc for secret config entrypoint | `lib/core/config/secret_config.dart` | `dart analyze lib/core/config/secret_config.dart` |

## Validation log

| When | Command | Result |
| ---- | ------- | ------ |
| After B1 | `dart format lib/core/config/secret_config.dart` | 0 changes |
| After B1 | `dart analyze lib/core/config/secret_config.dart` | No issues |
| Final | `git diff --check` on touched paths (see list under “Changed files” in Final report) | PASS |
| Final | `./tool/analyze.sh` (full package) | No issues found |
| Final | `./bin/checklist-fast` | Skipped: incompatible with `lib/` edits (narrow-docs-only fast path). |
| Final | `bash tool/check_hardcoded_strings.sh` | exit 0 — no hard-coded user-facing strings (presentation/shared/app scan). |
| Final | `CHECKLIST_RUN_COVERAGE=0 ./bin/checklist --explain` | **PASS** — delivery checklist complete (shared/core lane per validation matrix after `lib/core/config` touch). |
| Plan closeout | `npx markdownlint-cli2` on changed docs | 0 errors |
| Plan closeout | `bash tool/check_docs_gardening.sh --paths ...` over changed docs | pass |
| Plan closeout | `CHECKLIST_RUN_COVERAGE=0 ./bin/checklist --explain` (after doc closeout) | **PASS** — includes `normalize_doc_links` + `flutter analyze` + regression subset |

**Recommended follow-up:** `./bin/checklist-fast` only on clean tree or docs-only diffs; full `./bin/checklist` before ship when touching sync/DI broadly.

## Backlog (deferred)

| Item | Owner suggestion | Risk | Effort | Proof needed |
| ---- | ---------------- | ---- | ------ | ------------ |
| Split `case_study_session_cubit_actions.part.dart` | Feature owner | High | L | Cubit/widget tests + manual case-study flow |
| Split walletconnect / IoT / todo repository `.part` files | Feature owner | High | L | Integration + device tests |
| Track `injector.dart` + `counter_cubit.dart` churn | Platform | Med | S | Re-run churn quarterly; extract registrations if >N LOC |
| Optional shrinkWrap → slivers in adaptive sheets | UI | Low | M | [`shrinkwrap_slivers_audit.md`](shrinkwrap_slivers_audit.md) + widget perf |
| Repo-wide `check_hardcoded_strings.sh` triage | Tech debt | Low | M | Triage output; fix or allow-list intentionally demo strings |

## Final report

- **Changed files:** `lib/core/config/secret_config.dart`, [`AGENTS.md`](../../AGENTS.md) (lean map link), [`docs/agent_knowledge_base.md`](../agent_knowledge_base.md) (operator prefs + continual-learning), [`docs/changes/README.md`](../changes/README.md) (index), [`docs/changes/2026-05-12_senior_quality_hotspots_audit.md`](../changes/2026-05-12_senior_quality_hotspots_audit.md) (durable summary), [`audits/README.md`](README.md) (index), [`audits/senior_quality_hotspots_2026-05-12.md`](senior_quality_hotspots_2026-05-12.md), `docs/audits/_senior_quality_hotspots_seed_2026-05-12.log` (force-track with `git add -f` because `docs/audits/` is in `.gitignore`). Local-only: [`tasks/cursor/todo.md`](../../tasks/cursor/todo.md) (also gitignored) holds the plan’s team benefit one-liner when present.
- **Fixed findings:** B1 (dangling doc resolved via `library;` + summary doc).
- **Residual risk:** Large `.part.dart` files remain primary maintainability hotspots; no behavioral changes this pass.
- **Blockers:** None.
