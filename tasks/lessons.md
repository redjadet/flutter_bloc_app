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
  `lib/features/case_study_demo/presentation/widgets/case_study_video_tile.dart`
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
  `lib/features/online_therapy_demo/presentation/cubit/client_booking_cubit.dart`
  `tool/check_mutation_success_after_guard.sh`
  `docs/changes/2026-06-15_mutation-success-guard.md`

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
  `lib/features/chat/presentation/cubit/chat_cubit_history_actions.dart`
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
  `lib/features/graphql_demo/presentation/pages/graphql_demo_page.dart`

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
